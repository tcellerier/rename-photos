#!/bin/bash 

## v 1.0 
## Févier 2018
## Thomas Cellerier

##################################################################################################
##### Script pour renommer les photos à leur date de création EXIF (format 20180129-001.jpg) #####
##################################################################################################

## 2 étapes
##  a. Copie toutes les photos au format YYYYMMDD_HHMMSS (date EXIF et sinon date création fichier) 
##      Si le fichier est une live vidéo .mov, l'heure utilisée est celle de la photo au même nom
##      Si le fichier renommé existe déjà, on incrémente le nom YYYYMMDD_HHMMSS - n
##  b. Renomme les photos crées en a au format YYYYMMDD-nnn en fonction de l'ordre de l'étape a.
##.     Si le fichier est une live vidéo .mov, on n'incrémente pas le numéro du fichier


## Paramètres ##
format_photo="%Y%m%d_%H%M%S"
output_folder="_output"
################

clear
echo -e "Type the folder of the photos:"
read folder_photos

cd "$folder_photos"
if [ $? -ne 0 ] || [ "$folder_photos" = "" ] ; then
    echo -e "\n !! Error folder !!\n"
    exit
fi

echo -e "Are you sure to continue with this folder?"
read

echo -e "###########################################################"
echo -e "######### Step 1. Copy files to a datetime format #########"
echo -e "################        YYYYMMDD_HHMMSS       #############"
echo -e "###########################################################"

mkdir $output_folder
IFS=$'\n' # Split du 'for' sur les fins de lignes et non les espaces
for file in `ls -p | egrep -v /$`; do # Liste tous les fichiers (non dossiers)

    file_name=${file%.*} # jusqu'au dernier point
    file_ext=${file##*.} # après le dernier point
    file_ext=$(echo "$file_ext" | tr '[:upper:]' '[:lower:]') # minuscule
    file_datetime=$(date -f'%F %T %z' -j "$(mdls -name kMDItemContentCreationDate -raw $file)" +${format_photo}) # Convertion au bon fuseau horaire (sinon par défaut en UTC). Marche pour l'Exif des photos mais aussi pour n'importe quel fichier

    # Exception pour les Live Vidéos Apple dont le timestamp est souvent faux. On utilise alors le timestamp de la photo correspondante.
    #  règle : Le nom du fichier sans extension est identique au fichier précédent et  le 2è fichier est un "live view" .mov
    if [ "$file_name" = "$file_name_prev" ] && [ "$file_ext" = "mov" ]; then
        file_datetime=$file_datetime_prev
    fi

    file_new="${file_datetime}.${file_ext}"

    # Verification que le fichier n'existe pas déjà
    count_unique=1 # compteur incrémental d'unicité
    while [ -e "${output_folder}/${file_new}" ]; do
        file_new="${file_datetime} - ${count_unique}.${file_ext}"
        count_unique=$((count_unique+1))
    done

    echo "$file -> ${output_folder}/${file_new}"
    cp -p "${file}" "${output_folder}/${file_new}"

    file_name_prev=$file_name
    file_datetime_prev=$file_datetime
done

# pause
echo -e "\nReturn to continue to step 2 or Ctrl-c to stop there"
read

echo -e "##################################################"
echo -e "##### Step 2. Sort and rename files by date ######"
echo -e "##########         YYYYMMDD-nnn        ###########"
echo -e "##################################################"


# 2/2 On trie les photos par jour
IFS=$'\n' # Split du for sur les fins de lignes et non les espaces
date_prev=""
count_date=001
for file in `ls -p ./${output_folder}/ | egrep -v /$`; do

    date=${file:0:8}
    file_name=${file%.*} # jusqu'au dernier point
    file_ext=${file##*.} # après le dernier point
    file_ext=$(echo "$file_ext" | tr '[:upper:]' '[:lower:]') # minuscule

    # Si on est sur le même timestamp et c'est une vidéo mov live video
    if [ "$file_name" = "$file_name_prev" ] && [ "$file_ext" = "mov" ]; then
        count_date=$count_date
    # Sinon si on est sur le même jour, on incrémente le compteur
    elif [ "$date" = "$date_prev" ]; then
        count_date=$((count_date+1))
    # Sinon on recommence le compteur à 0
    else
        count_date=1
    fi

    printf -v count_date_format "%03d" $count_date # Mise au format 3 chiffres 
    file_new="${date}-${count_date_format}.${file_ext}"

    # Verification que le fichier n'existe pas déjà
    count_unique=1 # compteur incrémental d'unicité
    while [ -e "${output_folder}/${file_new}" ]; do
        file_new="${date}-${count_date_format} - ${count_unique}.${file_ext}"
        count_unique=$((count_unique+1))
    done

    echo "$file -> $file_new"
    mv "${output_folder}/${file}" "${output_folder}/${file_new}"

    date_prev=$date
    file_name_prev=$file_name

done

echo -e "##################################################"
echo -e "##################################################"
