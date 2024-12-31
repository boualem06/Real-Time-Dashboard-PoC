#!/bin/bash


API_KEY="91394bd12ee3080c591d08abbf6e69fe"

# Répertoire où les données seront sauvegardées
BASE_DIR=$(dirname "$(realpath "$0")")
DOSSIER="$BASE_DIR/or_prix"

mkdir -p "$DOSSIER"

HORAIRE_ACTU=$(date +"%Y-%m-%d_%H-%M")

# Fonction pour récupérer et sauvegarder le prix de l'or
fetch_gold_price() {
    URL="https://api.metalpriceapi.com/v1/latest?api_key=${API_KEY}&base=USD&symbols=XAU"
    FICHIER_CHEMIN="${DOSSIER}/gold_price_${HORAIRE_ACTU}.json"

    curl --silent --request GET --url "$URL" --output "$FICHIER_CHEMIN"

    if [ $? -eq 0 ]; then
        echo "Prix de l'or enregistré dans $FICHIER_CHEMIN"
    else
        echo "Erreur : impossible de récupérer les données. Vérifiez votre clé API ou votre connexion Internet."
    fi
}

fetch_gold_price

echo "Mise à jour des données d'or effectuée à $HORAIRE_ACTU" >> "${DOSSIER}/gold_price.log"

