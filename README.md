# Script pour renommer les photos à leur date de création EXIF 

## Auteur
* v 1.0 
* Févier 2018
* Thomas Cellerier

## Exécution
./rename_photos_bydate.sh

## Description
* MAC OS uniquement
* Tri et renomme les photos/vidéos au format 20180129-001.jpg en 2 étapes :
  * 1. Copie tous les fichiers vers le format YYYYMMDD_HHMMSS (date EXIF et sinon date création fichier) dans un sous-dossier 
  * 2. Renomme les fichiers créés en étape 1 au format YYYYMMDD-nnn (fichiers qui sont donc correctement triés à partir de leur nom)
 
## Fontionnalités clefs
* Si le fichier est une live vidéo .mov Apple, le nom définitif de la vidéo est identique au nom de la photo correspondante
* Si le fichier renommé existe déjà, on incrémente le compteur nnn
