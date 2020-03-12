<#
.SYNOPSIS

Fait un benchmark du PC sur lequel est lance le script

.DESCRIPTION

Le script va enregister dans un fichier CSV des données qui permettent d'identifier le PC et des données qui servent à savoir l'état du PC

Les données qui servent à identifier le PC sont la date, l'heure, le nom du PC, l'utilisateur connecté, le modèle, le SN, la MAC et l'IP

Les données qui servent à connaitre l'état du PC sont le temps d'allumage, le temps que la session et ouverte, la latence de la passerelle, le temps d'ouverture d'un fichier Word, le temps d'ouverture d'un fichier Excel et le taux de transfert sur le Lan

.OUTPUTS

Ecrit dans le log et/ou dans le CSV

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
        # Prend la date d aujourd hui
        $DataDate = Get-Date -f yyyy.dd.MM
    }catch{
        WriteLog "Erreur, la date n a pas ete generee correctement"
    }
    $Data = $DataDate
    #Heure
    try{
        # Prend l heure du moment
        $DataHeure = Get-Date -UFormat "%T"
    }catch{
        WriteLog "Erreur, l heure n a pas ete generee correctement"
    }
    $Data += ";" + $DataHeure
    #Nom
    try{
        # Prend le nom du PC
        $DataNom = $env:COMPUTERNAME
    }catch{
        WriteLog "Erreur, le nom de l'ordinateur n a pas ete generee correctement"
    }
    $Data += ";" + $DataNom
    #Utilisateur connecté
    try{
        # Prend le nom de l'utilisateur connecte
        $DataUser = $env:UserName
    }catch{
        WriteLog "Erreur, le nom de l utilisateur connecte n a pas ete generee correctement"
    }
    $Data += ";" + $DataUser
    #Modèle
    try{
        # Prend le modele du PC
        $DataModele = (Get-WmiObject -Class:Win32_ComputerSystem).Model
    }catch{
        WriteLog "Erreur, le model du pc n a pas pu etre recupere"
    }
    $Data += ";" + $DataModele
    #SN
    try{
        # Prend le numéro de serie du PC
        $DataSn = (Get-WmiObject -Class:Win32_BIOS).SerialNumber
    }catch{
        WriteLog "Erreur, le sn du pc n a pas pu etre recupere"
    }
    $Data += ";" + $DataSn
    #MAC
    try{
        # Prend les informations des cartes réseau du PC
        $DataAllMac = get-wmiobject -class "Win32_NetworkAdapterConfiguration" |Where{$_.IpEnabled -Match "True"}  
        # Pour chaque carte réseau
        foreach ($DataAllMacItem in $DataAllMac) {
            # si la carte réseau n est pas une carte virtuelle
            if($DataAllMacItem.Description -notlike "*Virtual*"){
                # Prend l adresse MAC
                $DataMac = $DataAllMacItem.MACAddress
            }
        } 
    }catch{
        WriteLog "Erreur, la Mac du pc n a pas pu etre recupere"
    }
    $Data += ";" + $DataMac
    #IP
    try{
        # Ping le PC une fois et sort l'adresse IP qui a été ping
        $DataIp = $(Test-Connection -ComputerName (hostname) -Count 1).IPV4Address
    }catch{
        WriteLog "Erreur, l adresse IP du pc n a pas pu etre recupere"
    }
    $Data += ";" + $DataIp

    # Calculer les datas
    #Depuis combien de temps le PC est allume
    try{
        # Prend des information sur le PC (Windows)
        $os = Get-WmiObject -Class win32_operatingsystem
        # Calcule la difference de temps entre maintenant et la dernière fois que le PC a été allumé
        $CalcTempsAlumPc = New-TimeSpan -End $(get-date) -Start $os.ConvertToDateTime($os.LastBootUpTime)
    }catch{
        WriteLog "Erreur, impossible de savoir depuis combien de temps le PC est allume"
    }
    $Calc = $CalcTempsAlumPc.ToString()
    #Depuis combien de temps la session est ouverte
    try{
        # Fait un quser (query user) pour avoir des informations sur les utilisateurs ayant une session active/inactive
        $QuserData = quser
        # Pour chanque des sessions
        ForEach ($Quser in $QuserData){
            # Verifie si le nom de la session est la meme que celle sur laquelle le script se lance
            if ($Quser.SubString(1, 20).Trim() -like $env:UserName){
                # Calcule la difference de temps entre maintenant et la date/heure d'ouverture de la session
                $CalcTempsAlumSession = New-TimeSpan -End $(get-date) -Start $Quser.SubString(65)
            }
        }
    }catch{
        WriteLog "Erreur, impossible de savoir depuis combien de temps la session est active"
    }
    $Calc += ";" + $CalcTempsAlumSession
    #La latence de la passerelle
    try{
        # Fait un ping unique de google.ch et prend la latence de la passerelle
        $CalcLatPass = (Test-Connection -ComputerName google.ch -Count 1).ResponseTime
    }catch{
        WriteLog "Erreur, la latence de la passerelle n'a pas pu être calculee"
    }
    $Calc += ";" + $CalcLatPass
    #Le temps d'ouverture d'un fichier Word
    try{
        #Calcule le temps des commandes qui sont lancée dans la commande
        $CalcTempWord  = Measure-Command -Expression {
            #Cree une variable avec comme objet word
            $Word = New-Object -ComObject Word.Application
            #ouvre un fichier specifique
            $Word.Documents.Open("$Path\Fichier a ouvrir\fichier a ourvir par le script.doc",$True,$True)
            #Attend que le document soit pret
            $word.Ready
        }
        
        #ferme le document word qui vient d etre ouvert
        #Prends toutes les instances de fichier Word qui sont ouvert
        Get-Process winword | foreach { 
            # Si le document a été ouvert il y a moin de 10 seconde
            if ((($(get-date) - $_.StartTime).Seconds) -lt 10) {
                # Ferme le fichier
                Stop-Process $_.ID
            }
        }
    }catch{
        WriteLog "Erreur, le temps d ouverture du fichier word n'a pas pu être calcule"
    }
    $Calc += ";" + $CalcTempWord
    #Le temps d'ouverture d'un fichier Excel
    try{
        #Calcule le temps des commandes qui sont lancée dans la commande
        $CalcTempExcel  = Measure-Command -Expression {
            #Cree une variable avec comme objet excel
            $excel = New-Object -ComObject excel.Application
            #ouvre un fichier specifique
            $excel.Workbooks.Open("$Path\Fichier a ouvrir\fichier a ouvrir par le script.xlsx",$True,$True)
            #Attend que le document soit pret
            $excel.Ready
        }
        
        #ferme le document excel qui vient d etre ouvert
        #Prends toutes les instances de fichier excel qui sont ouvert
        Get-Process excel | foreach { 
            # Si le document a été ouvert il y a moin de 10 seconde
            if ((($(get-date) - $_.StartTime).Seconds) -lt 10) {
                # Ferme le fichier
                Stop-Process $_.ID
            }
        }
    }catch{
        WriteLog "Erreur, le temps d ouverture du fichier excel n'a pas pu être calcule"
    }
    $Calc += ";" + $CalcTempExcel
    #Le taux de transfert d'un fichier sur le LAN
    try{
        # Stock les infos du fichier dans une var
        $item = get-item "$Path\Fichier a ouvrir\text1.txt"
        #Calcule le temps d'execution de la commande
        $time = Measure-Command -Expression {
            #Copie le fichier sur le Lan
            Copy-Item -literalpath "$Path\Fichier a ouvrir\text1.txt" "X:\temps\text2.txt"
        } 
        #Calcule le taux de transfert
        $CalcTauxTransfert = ($item.length/1024/1024) / $time.TotalSeconds
    }catch{
        WriteLog "Erreur, le taux de transfert d'un fichier sur le Lan n a pas pu etre calcule"
    }
    $Calc += ";" +  $CalcTauxTransfert

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
        $Data | add-content -path $CsvPath
    }catch{
        WriteLog "Erreur, l ecriture dans le fichier CSV n a pas fonctionne"
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
#Prend le chemin du script
$Path = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)

# Cree le chemin pour le fichier de log
$LogPath = "$Path\Log\$(get-date -f yyyy.dd.MM.HH.mm).log"

# Met en place le chemin pour le fichier CSV qui contient les données
$CsvPath = "$Path\Data\data.csv"
if(-Not (Test-Path($CsvPath))){
    #Creation du fichier avec les entetes
    "Date;Heure;Nom du PC;Utilisateur connecté;Modèle du PC;le Serial Number;l'adresse MAC;l'adresse IP;Depuis combien de temps le PC est allume;Depuis combien de temps la session est ouverte;La latence de la passerelle;Le temps d'ouverture d'un fichier Word;Le temps d'ouverture d'un fichier Excel;Le taux de transfert d'un fichier sur le LAN [M/s]" | add-content -path $CsvPath
}

# Lance la fonction qui calcul les donnees
$info = GetData

#Ecrit les donnees dans le fichier CSV
WriteCSV $info
