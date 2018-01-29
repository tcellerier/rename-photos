# Script pour renommer les photos à leur date de création EXIF 


## Auteur
* v 1.0 
* Févier 2018
* Thomas Cellerier
* MAC OS uniquement

# Description
* Tri et renomme les photos/vidéos en 2 étapes :
  * 1. Copie toutes les photos au format YYYYMMDD_HHMMSS (date EXIF et sinon date création fichier).
  
  * 2. Renomme les photos créées en a au format YYYYMMDD-nnn en fonction de l'ordre de l'étape a.
    

     
# Fontionnalités clefs
* Si le fichier est une live vidéo .mov Apple, le nom définitif de la vidéo est identique au nom de la photo correspondante
*  Si le fichier renommé existe déjà, on incrémente le nom ("- n")
