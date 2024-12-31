from pymongo import MongoClient
import os
import json
from datetime import datetime
import pytz
from collections import defaultdict

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

password = 'tEsTBd.2024'
uri = f"mongodb://maelleB:{password}@projetlinux-shard-00-00.oujjt.mongodb.net:27017,projetlinux-shard-00-01.oujjt.mongodb.net:27017,projetlinux-shard-00-02.oujjt.mongodb.net:27017/?ssl=true&replicaSet=atlas-rvoyfr-shard-0&authSource=admin&retryWrites=true&w=majority&appName=projetLinux"

# Créer un client MongoDB
client = MongoClient(uri)

# Tester la connexion avec un ping
try:
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print("Error:", e)

db = client["data_linux"]
collection = db["prix_et_facteurs"]

# Fonction pour insérer des données dans MongoDB
def inserer_donnees():
    try:
        # Récupérer les données de chaque source
        prix_or = lire_or_prix_via_verification("or_prix")
        prix_oil = lire_oil_price_via_verification("oil_price")
        prix_gaz = lire_gaz_prix_via_verification("commoditeGazNaturel")
        prix_ble = lire_prix_ble_via_verification("commoditeBle")
        prix_mais = lire_prix_mais_via_verification("commoditeMais")
        taux_usd_euro = lire_usd_to_euro_via_verification("usd_to_euro")

        donnees_par_date = defaultdict(dict)

        # Ajouter les prix de l'or
        for entry in prix_or:
            date = entry["date"]
            donnees_par_date[date]["or_prix"] = entry["prix_or"]
            print(f"Ajout prix or: {date} - {entry['prix_or']}")  
        # Ajouter les prix du pétrole
        for entry in prix_oil:
            date = entry["date"]
            donnees_par_date[date]["oil_price"] = entry["prix_petrole"]
            print(f"Ajout prix pétrole: {date} - {entry['prix_petrole']}")  

        # Ajouter les prix du gaz
        for entry in prix_gaz:
            date = entry["date"]
            donnees_par_date[date]["gaz_naturel"] = entry["prix_gaz"]
            print(f"Ajout prix gaz: {date} - {entry['prix_gaz']}")  

        # Ajouter les prix du blé
        for entry in prix_ble:
            date = entry["date"]
            donnees_par_date[date]["wheat"] = entry["prix_ble"]
            print(f"Ajout prix blé: {date} - {entry['prix_ble']}")  

        # Ajouter les prix du maïs
        for entry in prix_mais:
            date = entry["date"]
            donnees_par_date[date]["corn"] = entry["prix_mais"]
            print(f"Ajout prix maïs: {date} - {entry['prix_mais']}")  

        # Ajouter les taux de change USD -> EUR
        for entry in taux_usd_euro:
            date = entry["date"]
            donnees_par_date[date]["taux_$"] = entry["taux_usd_euro"]
            print(f"Ajout taux USD/EUR: {date} - {entry['taux_usd_euro']}")  
        
        # Préparer les documents à insérer
        for date, valeurs in donnees_par_date.items():
            # Créer le document à insérer
            document = {
                "date": date,
                "taux_$": valeurs.get("taux_$", None),  # Si absent, laisser None
                "facteurs": {
                    "gaz_naturel": valeurs.get("gaz_naturel", None),
                    "oil_price": valeurs.get("oil_price", None),
                    "or_prix": valeurs.get("or_prix", None),
                    "wheat": valeurs.get("wheat", None),
                    "corn": valeurs.get("corn", None)
                }
            }
            print(f"Document préparé pour insertion : {document}")  # Débogage

            # Vérifier si le document avec cette date et ces facteurs existe déjà
            for facteur, valeur in document["facteurs"].items():
                if valeur is not None:  # Nous ne vérifions que les facteurs qui ont une valeur (non-None)
                    # Vérifier l'existence dans la base de données
                    query = {"date": date, f"facteurs.{facteur}": {"$exists": True}}
                    print(f"Vérification dans la base de données avec la requête : {query}")  # Débogage

                    if collection.find_one(query):
                        print(f"Les données pour le facteur '{facteur}' à la date {date} existent déjà dans la base de données. Ignorer l'insertion.")
                        break  # Si un facteur existe déjà pour cette date, on ne procède pas à l'insertion
                    else:
                        # Insérer si l'entrée n'existe pas
                        collection.insert_one(document)
                        print(f"Données insérées pour la date {date} et le facteur '{facteur}' avec succès.")

# Supprimer les fichiers JSON après l'insertion
        fichier_mais = "commoditeMais"
        fichier_taux = "usd_to_euro"
        fichier_oil = "oil_price"
        fichier_or = "or_prix"
        fichier_gaz = "commoditeGazNaturel"
        fichier_ble = "commoditeBle"  
        supprimer_fichiers_json(fichier_mais)
        supprimer_fichiers_json(fichier_taux)
        supprimer_fichiers_json(fichier_oil)
        supprimer_fichiers_json(fichier_or)
        supprimer_fichiers_json(fichier_gaz)
        supprimer_fichiers_json(fichier_ble)

    except Exception as e:
        print(f"Erreur lors de l'insertion des données : {e}")


def supprimer_fichiers_json(dossier):
    """
    Supprime tous les fichiers JSON dans le dossier spécifié.
    :param dossier: Chemin du dossier contenant les fichiers JSON à supprimer.
    """
    if not os.path.exists(dossier):
        print(f"Le dossier '{dossier}' n'existe pas.")
        return

    # Parcourt les fichiers dans le dossier
    for fichier in os.listdir(dossier):
        if fichier.endswith(".json"):
            chemin_fichier = os.path.join(dossier, fichier)
            try:
                os.remove(chemin_fichier)
                print(f"Fichier supprimé : {fichier}")
            except Exception as e:
                print(f"Erreur lors de la suppression de '{fichier}': {e}")

def lire_fichiers_json(dossier):
    """
    Parcourt les fichiers JSON dans le dossier donné et charge leur contenu.
    :param dossier: Chemin du dossier contenant les fichiers JSON.
    :return: Liste des données chargées depuis les fichiers JSON.
    """
    donnees = []

    # Vérifie si le dossier existe
    if not os.path.exists(dossier):
        print(f"Le dossier '{dossier}' n'existe pas.")
        return donnees

    # Parcourt les fichiers dans le dossier
    for fichier in os.listdir(dossier):
        # Vérifie l'extension JSON
        if fichier.endswith(".json"):
            chemin_fichier = os.path.join(dossier, fichier)
            try:
                # Ouvre et charge le fichier JSON
                with open(chemin_fichier, 'r', encoding='utf-8') as f:
                    contenu = json.load(f)
                    donnees.append({
                        "fichier": fichier,
                        "contenu": contenu
                    })
                print(f"Fichier chargé : {fichier}")
            except Exception as e:
                print(f"Erreur lors de la lecture de '{fichier}': {e}")

    return donnees


def lire_prix_mais_via_verification(dossier):
    """
    Lit les données du prix du mais depuis les fichiers JSON dans le dossier spécifié.
    Utilise la fonction lire_fichiers_json pour charger les fichiers JSON au préalable.
    :param dossier: Chemin du dossier contenant les fichiers JSON.
    :return: Liste des 3 dernières données à insérer dans la base de données, une par date unique dans chaque fichier.
    """
    donnees = lire_fichiers_json(dossier)  # Utilisation de lire_fichiers_json pour charger les fichiers
    donnees_a_ajouter = []

    # Parcourt tous les fichiers et ajoute les données à la liste donnees_a_ajouter
    for fichier_data in donnees:
        fichier = fichier_data["fichier"]
        contenu = fichier_data["contenu"]
        dates_et_prix = {}  # Un dictionnaire pour stocker les prix par date (on garde une seule entrée par date)

        try:
            # Vérifier que le contenu contient bien la clé 'data'
            if "data" in contenu:
                # Extraire les données (prix et dates)
                for entry in contenu["data"]:
                    if "date" in entry and "value" in entry:
                        date_str = entry["date"]
                        prix = entry["value"]
                        
                        if prix == ".":
                            prix = None  
                        else:
                            try:
                                prix = float(prix)  
                            except ValueError:
                                print(f"Valeur invalide '{prix}' pour la date '{date_str}' dans le fichier '{fichier}'.")
                                continue  
                        
                        # Si un prix est trouvé, on ajoute dans le dictionnaire
                        if prix is not None:
                            date_obj = datetime.strptime(date_str, "%Y-%m-%d")
                            date_obj = pytz.timezone("Europe/Paris").localize(date_obj)

                            # On garde la dernière entrée pour chaque date (si une date apparaît plusieurs fois)
                            dates_et_prix[date_obj] = prix

        except Exception as e:
            print(f"Erreur lors du traitement du fichier '{fichier}': {e}")

        # Trier les dates par ordre décroissant (du plus récent au plus ancien)
        sorted_dates = sorted(dates_et_prix.keys(), reverse=True)

        for date in sorted_dates[:3]:
            # Formater la date sans l'heure ni le fuseau horaire
            date_formatee = date.strftime("%Y-%m-%d")
            donnees_a_ajouter.append({"date": date_formatee, "prix_mais": dates_et_prix[date]})

    return donnees_a_ajouter

def lire_prix_ble_via_verification(dossier):
    """
    Lit les données du prix du blé depuis les fichiers JSON dans le dossier spécifié.
    Utilise la fonction lire_fichiers_json pour charger les fichiers JSON au préalable.
    :param dossier: Chemin du dossier contenant les fichiers JSON.
    :return: Liste des 3 dernières données à insérer dans la base de données, une par date unique dans chaque fichier.
    """
    donnees = lire_fichiers_json(dossier)  # Utilisation de lire_fichiers_json pour charger les fichiers
    donnees_a_ajouter = []

    # Parcourt tous les fichiers et ajoute les données à la liste donnees_a_ajouter
    for fichier_data in donnees:
        fichier = fichier_data["fichier"]
        contenu = fichier_data["contenu"]
        dates_et_prix = {}  # Un dictionnaire pour stocker les prix par date (on garde une seule entrée par date)

        try:
            # Vérifier que le contenu contient bien la clé 'data'
            if "data" in contenu:
                # Extraire les données (prix et dates)
                for entry in contenu["data"]:
                    if "date" in entry and "value" in entry:
                        date_str = entry["date"]
                        prix = entry["value"]
                        

                        if prix == ".":
                            prix = None  
                        else:
                            try:
                                prix = float(prix)  
                            except ValueError:
                                print(f"Valeur invalide '{prix}' pour la date '{date_str}' dans le fichier '{fichier}'.")
                                continue  
                        

                        if prix is not None:
                            date_obj = datetime.strptime(date_str, "%Y-%m-%d")
                            date_obj = pytz.timezone("Europe/Paris").localize(date_obj)

                            # On garde la dernière entrée pour chaque date (si une date apparaît plusieurs fois)
                            dates_et_prix[date_obj] = prix

        except Exception as e:
            print(f"Erreur lors du traitement du fichier '{fichier}': {e}")

        # Trier les dates par ordre décroissant (du plus récent au plus ancien)
        sorted_dates = sorted(dates_et_prix.keys(), reverse=True)

        for date in sorted_dates[:3]:
            # Formater la date sans l'heure ni le fuseau horaire
            date_formatee = date.strftime("%Y-%m-%d")
            donnees_a_ajouter.append({"date": date_formatee, "prix_ble": dates_et_prix[date]})

    return donnees_a_ajouter

def lire_gaz_prix_via_verification(dossier):
    """
    Lit les données de prix du gaz naturel depuis les fichiers JSON dans le dossier spécifié.
    Utilise la fonction lire_fichiers_json pour charger les fichiers JSON au préalable.
    :param dossier: Chemin du dossier contenant les fichiers JSON.
    :return: Liste des 3 dernières données à insérer dans la base de données, une par date unique dans chaque fichier.
    """
    donnees = lire_fichiers_json(dossier)  # Utilisation de lire_fichiers_json pour charger les fichiers
    donnees_a_ajouter = []

    # Parcourt tous les fichiers et ajoute les données à la liste donnees_a_ajouter
    for fichier_data in donnees:
        fichier = fichier_data["fichier"]
        contenu = fichier_data["contenu"]
        dates_et_prix = {}  # Un dictionnaire pour stocker les prix par date (on garde une seule entrée par date)

        try:
            # Vérifier que le contenu contient bien la clé 'data'
            if "data" in contenu:
                # Extraire les données (prix et dates)
                for entry in contenu["data"]:
                    if "date" in entry and "value" in entry:
                        date_str = entry["date"]
                        prix = entry["value"]
                        
                        if prix == ".":
                            prix = None  
                        else:
                            try:
                                prix = float(prix)  
                            except ValueError:
                                print(f"Valeur invalide '{prix}' pour la date '{date_str}' dans le fichier '{fichier}'.")
                                continue  
                        
                        if prix is not None:
                            date_obj = datetime.strptime(date_str, "%Y-%m-%d")
                            date_obj = pytz.timezone("Europe/Paris").localize(date_obj)

                            # On garde la dernière entrée pour chaque date (si une date apparaît plusieurs fois)
                            dates_et_prix[date_obj] = prix

        except Exception as e:
            print(f"Erreur lors du traitement du fichier '{fichier}': {e}")

        # Trier les dates par ordre décroissant (du plus récent au plus ancien)
        sorted_dates = sorted(dates_et_prix.keys(), reverse=True)

        for date in sorted_dates[:16]:
            date_formatee = date.strftime("%Y-%m-%d")
            donnees_a_ajouter.append({"date": date_formatee, "prix_gaz": dates_et_prix[date]})

    return donnees_a_ajouter

def lire_oil_price_via_verification(dossier):
    """
    Lit les fichiers JSON depuis un dossier, vérifie leur contenu, calcule les prix moyens
    et convertit les timestamps en dates au fuseau horaire de Paris.
    """
    donnees = lire_fichiers_json(dossier)  
    prix_petrole = []
    paris_tz = pytz.timezone("Europe/Paris")

    for fichier_data in donnees:
        fichier = fichier_data["fichier"]
        contenu = fichier_data["contenu"]
        try:
            # Vérifie la présence des clés nécessaires
            if all(k in contenu for k in ["t", "o", "c", "h", "l"]):
                timestamp = contenu["t"]
                prix_moyen = round((contenu["o"] + contenu["c"] + contenu["h"] + contenu["l"]) / 4, 2)
                date_str=timestamp.split(" ")[0]
                
                prix_petrole.append({"date": date_str, "prix_petrole": prix_moyen})
            else:
                print(f"Clés manquantes dans le fichier '{fichier}'")
        except Exception as e:
            print(f"Erreur lors du traitement de '{fichier}': {e}")

    return prix_petrole


def lire_or_prix_via_verification(dossier):
    """
    Lit les données de prix de l'or depuis le dossier 'or_prix', extrait uniquement le prix de 1 once d'or (USDXAU),
    et convertit le timestamp en date au fuseau horaire de Paris.
    Utilise la fonction lire_fichiers_json pour charger les fichiers JSON au préalable.
    """
    donnees = lire_fichiers_json(dossier)  
    prix_or = []
    paris_tz = pytz.timezone("Europe/Paris")  

    for fichier_data in donnees:
        fichier = fichier_data["fichier"]
        contenu = fichier_data["contenu"]
        
        try:
            # Vérifier que le contenu contient bien le timestamp et les taux
            if "timestamp" in contenu and "rates" in contenu:
                timestamp = contenu["timestamp"]  # Timestamp Unix
                
                prix_or_ounce = contenu["rates"].get("USDXAU", None)  
                
                if prix_or_ounce is not None:
                    prix_or_ounce = round(prix_or_ounce, 4)
                    date_utc = datetime.utcfromtimestamp(timestamp)
        
                    # Convertir la datetime UTC en datetime dans le fuseau horaire de Paris
                    date_paris = date_utc.replace(tzinfo=pytz.utc).astimezone(paris_tz)
                    date_str = date_paris.strftime('%Y-%m-%d')  
                    
                    prix_or.append({"date": date_str, "prix_or": prix_or_ounce})
            else:
                print(f"Le fichier '{fichier}' ne contient pas les clés attendues.")
        
        except Exception as e:
            print(f"Erreur lors du traitement de '{fichier}': {e}")
    
    return prix_or


def lire_usd_to_euro_via_verification(dossier):
    """
    Traite les fichiers JSON dans le dossier pour calculer la moyenne des taux (`rate`) par jour.

    - Chaque fichier contient des données horaires au format :
        {
            "symbol": "EUR/USD",
            "rate": 1.04259,
            "timestamp": "2024-12-27 22:59:00"
        }
    - Calcule la moyenne des taux de change (`rate`) par jour.

    :param dossier: Chemin du dossier contenant les fichiers JSON.
    :return: Liste de dictionnaires contenant la date et la moyenne des taux au format :
        [{"date": "YYYY-MM-DD", "taux_moyen": moyenne}]
    """
    taux_par_date = defaultdict(list)

    # Parcourir tous les fichiers du dossier
    for fichier in os.listdir(dossier):
        chemin_fichier = os.path.join(dossier, fichier)
        if os.path.isfile(chemin_fichier) and fichier.endswith(".json"):
            try:
                with open(chemin_fichier, "r") as f:
                    contenu = json.load(f)

                    # Vérification de la structure des données
                    if "symbol" in contenu and "rate" in contenu and "timestamp" in contenu:
                        date = contenu["timestamp"].split(" ")[0]  # Extraire la date 'YYYY-MM-DD'
                        taux_par_date[date].append(contenu["rate"])
                    else:
                        print(f"Structure invalide dans le fichier : {fichier}")
            except Exception as e:
                print(f"Erreur lors du traitement du fichier {fichier} : {e}")

    # Calculer la moyenne des taux pour chaque date
    moyennes_par_jour = []
    for date, taux_list in taux_par_date.items():
        moyenne = sum(taux_list) / len(taux_list)
        moyennes_par_jour.append({"date": date, "taux_usd_euro": round(moyenne, 4)})

    return moyennes_par_jour
    

inserer_donnees()
