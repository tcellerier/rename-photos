#!/bin/bash 

## v 1.3
## July 2019
## Thomas Cellerier
## MAC OS uniquement

#####################################################################################################
##### Script pour renommer les photos avec leur date de création EXIF (format 20180129-001.jpg) #####
#####################################################################################################

## Utilisation: 
#    Argument optionnel pour indiquer le répertoire à traiter. Ex: ./rename_photos_bydata.sh /tmp/photos/

## Tri et renomme les photos/vidéos au format 20180129-001.jpg en 2 étapes tout en gardant les fichiers originaux dans un sous répertoire :
##  a. Copie tous les fichiers vers le format YYYYMMDD_HHMMSS (date EXIF et sinon date création fichier)  
##      Si le fichier est une live vidéo .mov, l'heure utilisée est celle de la photo correspondante au même nom
##      Si le fichier renommé existe déjà, on incrémente le nom "YYYYMMDD_HHMMSS - n"
##  b. Renomme les fichiers créés en étape 1 au format YYYYMMDD-nnn (fichiers qui sont donc correctement triés à partir de leur nom)
##      Si le fichier est une live vidéo .mov, on n'incrémente pas le numéro du fichier
##.     Si le fichier renommé existe déjà, on incrémente le compteur


## Paramètres ##
format_photo="%Y%m%d_%H%M%S"
backup_folder="_original"
################

clear
if [ "$1" = "" ] ; then
    echo -e "Type the full path of the photos/videos:"
    read folder_photos
else
    echo -e "Full path of the photos/videos: $1"
    folder_photos=$1
fi


cd "$folder_photos"
if [ $? -ne 0 ] || [ "$folder_photos" = "" ] ; then
    echo -e "  !! Error folder !!\n"
    exit
fi

echo -e "\nAre you sure to proceed with step 1 for this folder? [y]/n\n(copy files to format YYYYMMDD_HHMMSS) "
read confirm_step1
confirm_step1=`echo $confirm_step1 | tr '[:upper:]' '[:lower:]'`

if [ "$confirm_step1" = "" ] || [ "$confirm_step1" = "y" ] || [ "$confirm_step1" = "yes" ] ; then

    echo -e "###########################################################"
    echo -e "###### Step 1. Copy files to a unique datetime format #####"
    echo -e "######                 YYYYMMDD_HHMMSS                #####"
    echo -e "###########################################################\n"

    mkdir $backup_folder
    IFS=$'\n' # Split du 'for' sur les fins de lignes et non les espaces
    for file in `ls -p | egrep -v /$`; do # Liste tous les fichiers (non dossiers)

        file_name=${file%.*} # jusqu'au dernier point
        file_ext=${file##*.} # après le dernier point
        file_ext=$(echo "$file_ext" | tr '[:upper:]' '[:lower:]') # minuscule
        file_datetime=$(date -f'%F %T %z' -j "$(mdls -name kMDItemContentCreationDate -raw $file)" +${format_photo}) # Convertion au bon fuseau horaire (sinon par défaut en UTC). Marche pour l'Exif des photos mais aussi pour n'importe quel fichier

        # Exception pour les Live Vidéos Apple dont le timestamp est souvent faux. On utilise alors le timestamp de la photo correspondante.
        #  règle : Le nom du fichier (sans extension) doit être identique au fichier précédent et le 2è fichier un .mov
        if [ "$file_name" = "$file_name_prev" ] && [ "$file_ext" = "mov" ]; then
            file_datetime=$file_datetime_prev
        fi

        file_new="${file_datetime}.${file_ext}"

        # Verification que le fichier n'existe pas déjà
        count_unique=1 # compteur incrémental d'unicité
        while [ -e "${file_new}" ]; do
            file_new="${file_datetime} - ${count_unique}.${file_ext}"
            count_unique=$((count_unique+1))
        done

        echo "$file -> ${file_new}"
        cp -p "${file}" "${backup_folder}/${file}"
        mv "${file}" "${file_new}"

        file_name_prev=$file_name
        file_datetime_prev=$file_datetime
    done
else

    mkdir $backup_folder
    IFS=$'\n' # Split du 'for' sur les fins de lignes et non les espaces
    for file in `ls -p | egrep -v /$`; do # Liste tous les fichiers (non dossiers)
        cp -p "${file}" "${backup_folder}/${file}"
    done

fi


# pause
echo -e "\n###########################################################"
echo -e "\nPress Enter to continue to step 2 or Ctrl-c to stop here\n(sort and rename files by date)"
read

echo -e "##################################################"
echo -e "##### Step 2. Sort and rename files by date ######"
echo -e "#####              YYYYMMDD-nnn             ######"
echo -e "##################################################\n"


IFS=$'\n' # Split du for sur les fins de lignes et non les espaces
for file in `ls -p ./ | egrep -v /$`; do

    file_date=${file:0:8} # 8 premiers charactères du fichier
    file_name=${file%.*} # jusqu'au dernier point
    file_ext=${file##*.} # après le dernier point
    file_ext=$(echo "$file_ext" | tr '[:upper:]' '[:lower:]') # minuscule

    # Si on est sur le même timestamp et si c'est une vidéo mov live video => on n'incrémente pas le compteur
    if [ "$file_name" = "$file_name_prev" ] && [ "$file_ext" = "mov" ]; then
        count_date=$count_date
    # Sinon si on est sur le même jour, on incrémente le compteur
    elif [ "$file_date" = "$file_date_prev" ]; then
        count_date=$((count_date+1))
    # Sinon (=nouveau jour), on redémarre le compteur à 0
    else
        count_date=1
    fi

    printf -v count_date_format "%03d" $count_date # Mise au format 3 chiffres du compteur
    file_new="${file_date}-${count_date_format}.${file_ext}"

    # Verification que le fichier n'existe pas déjà
    while [ -e "${file_new}" ]; do
        count_date=$((count_date+1))
        printf -v count_date_format "%03d" $count_date # Mise au format 3 chiffres du compteur
        file_new="${file_date}-${count_date_format}.${file_ext}"
    done

    echo "$file -> $file_new"
    mv "${file}" "${file_new}"

    file_date_prev=$file_date
    file_name_prev=$file_name

done

echo -e "\n##################################################"
