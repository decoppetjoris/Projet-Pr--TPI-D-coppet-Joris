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
    
}

# fonction qui sert a ecrire dans le CSV
function WriteCSV($Data) {
    
}

# fonction qui sert a ecrire un message dans le fichier de log
function WriteLog($message) {

}

# verifier si le fichier de log existe
if(){
    # s'il n'existe pas le créer

}else{
    # s'il existe, le créer

} 

#récuperer les datas
$Data = GetData;

# ecrire les datas dans le CSV
WriteCSV $Data;
