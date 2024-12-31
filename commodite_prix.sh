#!/bin/bash

API_KEY="JGMZ9B5FYMT4JE4K"

# Répertoires pour enregistrer les données de chaque commodité
BASE_DIR=$(dirname "$(realpath "$0")")
DOSSIER_GAZ_NATUREL="$BASE_DIR/commoditeGazNaturel"
DOSSIER_BLE="$BASE_DIR/commoditeBle"
DOSSIER_MAIS="$BASE_DIR/commoditeMais"

# Créer les dossiers s'ils n'existent pas
mkdir -p "$DOSSIER_GAZ_NATUREL"
mkdir -p "$DOSSIER_BLE"
mkdir -p "$DOSSIER_MAIS"

HORAIRE_ACTU=$(date +"%Y-%m-%d_%H-%M")

# Fonction pour récupérer les données et les enregistrer dans le dossier approprié
fetch_data() {
    local commodite=$1
    local fonction=$2
    local fichier_prefixe=$3
    local dossier=$4


    URL="https://www.alphavantage.co/query?function=${fonction}&interval=daily&datatype=json&apikey=${API_KEY}"

    # Chemin du fichier de sortie
    FICHIER_CHEMIN="${dossier}/${fichier_prefixe}_${HORAIRE_ACTU}.json"

    curl --silent --request GET --url "$URL" --output "$FICHIER_CHEMIN"

    echo "Données pour $commodite enregistrées dans $FICHIER_CHEMIN"
}

# Récupérer les prix et les enregistrer dans le dossier approprié
fetch_data "Gaz Naturel" "NATURAL_GAS" "natural_gas" "$DOSSIER_GAZ_NATUREL"
fetch_data "Blé" "WHEAT" "wheat" "$DOSSIER_BLE"
fetch_data "Maïs" "CORN" "corn" "$DOSSIER_MAIS"

# Log global
echo "Mise à jour des données de matières premières effectuée à $HORAIRE_ACTU" >> "${DOSSIER_GAZ_NATUREL}/commodite_prix.log"
echo "Mise à jour des données de matières premières effectuée à $HORAIRE_ACTU" >> "${DOSSIER_BLE}/commodite_prix.log"
echo "Mise à jour des données de matières premières effectuée à $HORAIRE_ACTU" >> "${DOSSIER_MAIS}/commodite_prix.log"
