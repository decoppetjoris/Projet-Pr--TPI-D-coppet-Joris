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
        
    }
    $DataDate
    #Heure
    $DataHeure
    #Nom
    $DataNom
    #Utilisateur connecté
    $DataUser
    #Modèle
    $DataModele
    #SN
    $DataSn
    #MAC
    $DataMac
    #IP
    $DataIp

    # Calculer les datas
    #Depuis combien de temps le PC est allume

    #Depuis combien de temps la session est ouverte

    #La latence de la passerelle

    #Le temps d'ouverture d'un fichier Word

    #Le temps d'ouverture d'un fichier Excel

    #Le taux de transfert d'un fichier sur le LAN

    # Mettre toutes les datas dans une var
    $Data
}

# fonction qui sert a ecrire dans le CSV
function WriteCSV($CSVData) {
    
}

# fonction qui sert a ecrire un message dans le fichier de log
Function WriteLog {
    #Le Param pour le message
    Param ([string]$LogString)
    #Ecrit le message dans le fichier de Log
    $LogString | Out-File -FilePath $LogPath -Append
}

# Cree le chemin pour le fichier de log
$LogPath = "Log\$(get-date -f yyyy.dd.MM_HH.mm).log"

# Met en place le chemin pour le fichier CSV qui contient les données
<#
#récuperer les datas
$Info = GetData;

# ecrire les datas dans le CSV
WriteCSV $Info;
#>