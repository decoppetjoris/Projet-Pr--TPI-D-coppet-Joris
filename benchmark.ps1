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
        $DataDate = Get-Date -UFormat "%Y.%d.%A"
    }catch{
        WriteLog "Erreur, la date n a pas ete generee correctement"
        Exit
    }

    #Heure
    try{
        $DataHeure = Get-Date -UFormat "%T"
    }catch{
        WriteLog "Erreur, l heure n a pas ete generee correctement"
        Exit
    }

    #Nom
    try{
        $DataNom = $env:COMPUTERNAME
    }catch{
        WriteLog "Erreur, le nom de l'ordinateur n a pas ete generee correctement"
        Exit
    }
    
    #Utilisateur connecté
    try{
        $DataUser = $env:UserName
    }catch{
        WriteLog "Erreur, le nom de l utilisateur connecte n a pas ete generee correctement"
        Exit
    }
    
    #Modèle
    try{
        $DataModele = (Get-WmiObject -Class:Win32_ComputerSystem).Model
    }catch{
        WriteLog "Erreur, le model du pc n a pas pu etre recupere"
        Exit
    }
    
    #SN
    try{
        $DataSn = (Get-WmiObject -Class:Win32_BIOS).SerialNumber
    }catch{
        WriteLog "Erreur, le sn du pc n a pas pu etre recupere"
        Exit
    }
    
    #MAC
    try{
        $DataMac
    }catch{
        WriteLog "Erreur, la Mac du pc n a pas pu etre recupere"
        Exit
    }
    
    #IP
    try{
        $DataIp
    }catch{
        WriteLog "Erreur, l adresse IP du pc n a pas pu etre recupere"
        Exit
    }
    

    # Calculer les datas
    #Depuis combien de temps le PC est allume

    #Depuis combien de temps la session est ouverte

    #La latence de la passerelle

    #Le temps d'ouverture d'un fichier Word

    #Le temps d'ouverture d'un fichier Excel

    #Le taux de transfert d'un fichier sur le LAN

    # Mettre toutes les datas dans une var
    $Data = $DataDate + ";" + $DataHeure + ";" + $DataNom + ";" + $DataUser + ";" + $DataModele + ";" + $DataSn + ";" + $DataMac + ";" + $DataIp

    return $Data
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
        Exite
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

$Info = GetData

WriteCSV $Info

WriteLog "sdfuigoiufhiou"
