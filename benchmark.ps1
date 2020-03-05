<#
.SYNOPSIS

Fait un benchmark du PC sur lequel est lance le script

.DESCRIPTION

Le script va enregister dans un fichier CSV des données qui permettent d'identifier le PC et des données qui servent à savoir l'état du PC

Les données qui servent à identifier le PC sont la date, l'heure, le nom du PC, l'utilisateur connecté, le modèle, le SN, la MAC et l'IP

Les données qui servent à connaitre l'état du PC sont le temps d'allumage, le temps que la session et ouverte, la latence de la passerelle, le temps d'ouverture d'un fichier Word, le temps d'ouverture d'un fichier Excel et le taux de transfert sur le Lan

.OUTPUTS

Ecrit dans les logs et dans le CSV

.EXAMPLE

Command Prompt

C:\> PowerShell.exe -ExecutionPolicy Bypass ^
-File "%CD%/benchmark.ps1" ^

#>

# fontion qui sert a recuperer les donnees sur le PC
function GetData {
    # Prendre des infos sur le PC
    #Date
    try{
        $DataDate = Get-Date -f yyyy.dd.MM
    }catch{
        WriteLog "Erreur, la date n a pas ete generee correctement"
        Exit
    }
    $Data = $DataDate
    #Heure
    try{
        $DataHeure = Get-Date -UFormat "%T"
    }catch{
        WriteLog "Erreur, l heure n a pas ete generee correctement"
        Exit
    }
    $Data += ";" + $DataHeure
    #Nom
    try{
        $DataNom = $env:COMPUTERNAME
    }catch{
        WriteLog "Erreur, le nom de l'ordinateur n a pas ete generee correctement"
        Exit
    }
    $Data += ";" + $DataNom
    #Utilisateur connecté
    try{
        $DataUser = $env:UserName
    }catch{
        WriteLog "Erreur, le nom de l utilisateur connecte n a pas ete generee correctement"
        Exit
    }
    $Data += ";" + $DataUser
    #Modèle
    try{
        $DataModele = (Get-WmiObject -Class:Win32_ComputerSystem).Model
    }catch{
        WriteLog "Erreur, le model du pc n a pas pu etre recupere"
        Exit
    }
    $Data += ";" + $DataModele
    #SN
    try{
        $DataSn = (Get-WmiObject -Class:Win32_BIOS).SerialNumber
    }catch{
        WriteLog "Erreur, le sn du pc n a pas pu etre recupere"
        Exit
    }
    $Data += ";" + $DataSn
    #MAC
    try{
        $DataAllMac = get-wmiobject -class "Win32_NetworkAdapterConfiguration" |Where{$_.IpEnabled -Match "True"}  
        foreach ($DataAllMacItem in $DataAllMac) {
            if($DataAllMacItem.Description -notlike "*VMware*"){
                $DataMac = $DataAllMacItem.MACAddress
            }
        } 
    }catch{
        WriteLog "Erreur, la Mac du pc n a pas pu etre recupere"
        Exit
    }
    $Data += ";" + $DataMac
    #IP
    try{
        $DataIp = $(Test-Connection -ComputerName (hostname) -Count 1).IPV4Address
    }catch{
        WriteLog "Erreur, l adresse IP du pc n a pas pu etre recupere"
        Exit
    }
    $Data += ";" + $DataIp

    # Calculer les datas
    #Depuis combien de temps le PC est allume
    try{
        $os = Get-WmiObject -Class win32_operatingsystem
        $CalcTempsAlumPc = (get-date) - $os.ConvertToDateTime($os.LastBootUpTime)
    }catch{
        WriteLog "Erreur, impossible de savoir depuis combien de temps le PC est allume"
        Exit
    }
    $Calc = $CalcTempsAlumPc.ToString()
    #Depuis combien de temps la session est ouverte
    try{
        $QuserData = quser
        ForEach ($Quser in $QuserData){
            if ($Quser.SubString(1, 20).Trim() -like $env:UserName){
                $CalcTempsAlumSession = $Quser.SubString(65)
            }
        }
    }catch{
        WriteLog "Erreur, impossible de savoir depuis combien de temps la session est active"
        Exit
    }
    $Calc += ";" + $CalcTempsAlumSession.ToString()
    #La latence de la passerelle
    try{
        $CalcLatPass = (Test-Connection -ComputerName google.ch -Count 1).ResponseTime
    }catch{
        WriteLog "Erreur, la latence de la passerelle n'a pas pu être calculee"
        Exit
    }
    $Calc += ";" + $CalcLatPass.ToString()
    #Le temps d'ouverture d'un fichier Word
    try{
        $CalcTempWord  = Measure-Command -Expression {
            $Word = New-Object -ComObject Word.Application
            $Word.Documents.Open("C:\Projet-Pr--TPI-D-coppet-Joris\Fichier a ouvrir\fichier a ourvir par le script.doc",$True,$True)
            $word.Ready
        }
        
        #ferme le document word qui vient d etre ouvert
        Get-Process winword | foreach { 
            if ((($(get-date) - $_.StartTime).Seconds) -lt 10) {
                Stop-Process $_.ID
            }
        }
    }catch{
        WriteLog "Erreur, le temps d ouverture du fichier word n'a pas pu être calcule"
        Exit
    }
    $Calc += ";" + $CalcTempWord.ToString()
    #Le temps d'ouverture d'un fichier Excel
    try{
        $CalcTempExcel  = Measure-Command -Expression {
            $excel = New-Object -ComObject excel.Application
            $excel.Workbooks.Open("C:\Projet-Pr--TPI-D-coppet-Joris\Fichier a ouvrir\fichier a ouvrir par le script.xlsx",$True,$True)
            $excel.Ready
        }
        
        #ferme le document word qui vient d etre ouvert
        Get-Process excel | foreach { 
            if ((($(get-date) - $_.StartTime).Seconds) -lt 10) {
                Stop-Process $_.ID
            }
        }
    }catch{
        WriteLog "Erreur, le temps d ouverture du fichier word n'a pas pu être calcule"
        Exit
    }
    $Calc += ";" + $CalcTempExcel.ToString()
    #Le taux de transfert d'un fichier sur le LAN
    $item = get-item 'C:\Projet-Pr--TPI-D-coppet-Joris\Fichier a ouvrir\text1.txt'
    $time = Measure-Command -Expression {Copy-Item -literalpath 'C:\Projet-Pr--TPI-D-coppet-Joris\Fichier a ouvrir\text1.txt' 'X:\temps\text2.txt'} 
    $CalcTauxTransfert = ($item.length/1024/1024) / $time.TotalSeconds
    $Calc += ";" +  $CalcTauxTransfert.ToString()

    # Mettre toutes les datas dans une var
    $AllData = $Data + ";" + $Calc

    return $AllData
}

# fonction qui sert a ecrire dans le CSV
function WriteCSV {
    #Met en place le parametre pour la fonction
    Param (
        [string]$Data
    )
    try{
        #Ecrit les data dans le fichier CSV
        $Data | Export-Csv -Path $CsvPath -NoTypeInformation -Delimiter ";"
    }catch{
        WriteLog "Erreur, l ecriture dans le fichier CSV n a pas fonctionne"
        Exit
    }
    
}

# fonction qui sert a ecrire un message dans le fichier de log
Function WriteLog {
    #Le parametre pour la fonction qui contient le message qui sera ecrit dans le fichier log
    Param (
        [string]$LogString
    )
    #Ecrit le message dans le fichier de Log
    $LogString | Out-File -FilePath $LogPath -Append
}

# Cree le chemin pour le fichier de log
$LogPath = "C:\Projet-Pr--TPI-D-coppet-Joris\Log\$(get-date -f yyyy.dd.MM.HH.mm).log"

# Met en place le chemin pour le fichier CSV qui contient les données
$CsvPath = "C:\Projet-Pr--TPI-D-coppet-Joris\Data\data.csv"
if(!Test-Path($CsvPath)){
    
}

$Info = GetData

WriteCSV $Info
