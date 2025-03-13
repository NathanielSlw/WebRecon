#!/bin/bash
source config.sh

# Exemple d'utilisation :
# bash 3_urls_gathering.sh
# bash 3_urls_gathering.sh "CookieName=CookieValue"
# bash 3_urls_gathering.sh "CookieName=CookieValue" "specific-domain.com"

urls_crawling_and_cleaning() {
    local ALL_URLS_FILE="$URLS_DIR/all_urls.txt"
    local HTTPX_200_URLS="$URLS_DIR/httpx_200_urls.txt"

    local COOKIE_HEADER="$1"  # Paramètre optionnel pour le header personnalisé (ex: cookie)
    local TARGET_DOMAIN="$2"  # Domaine spécifique pour appliquer le cookie

    print_message "$GREEN" "[🌐] URLS Gathering avec gau (passive) & Katana (active)..."

    # Extraction de la première colonne uniquement (les URLs) du fichier HTTPX_200_FILE
    cut -d ' ' -f 1 $HTTPX_200_FILE | anew $HTTPX_200_URLS

    # Récupération des URLs avec gau et katana en parallèle
    print_message "$GREEN" "[🔍] Extraction des URLs avec gau..."
    cat $HTTPX_200_URLS | xargs -I {} gau --blacklist png,jpg,gif,svg,css,woff,ttf,ico --threads 10 {} | anew $ALL_URLS_FILE > /dev/null

    # Si un custom header est fourni
    if [[ -n "$COOKIE_HEADER" ]]; then
        # Si un domaine spécifique est fourni, appliquer le cookie seulement pour ce domaine
        if [[ -n "$TARGET_DOMAIN" ]]; then
            # Filtrer les URLs qui appartiennent au domaine spécifique
            print_message "$GREEN" "[🍪] Crawling avec Katana et cookie sur le domaine $TARGET_DOMAIN..."
            cat $HTTPX_200_URLS | grep "$TARGET_DOMAIN" | xargs -I {} katana -list {} -jc -kf -headers "$COOKIE_HEADER" | anew $ALL_URLS_FILE > /dev/null
        else
            # Si aucun domaine spécifique, appliquer le cookie à toutes les URLs
            print_message "$GREEN" "[🍪] Crawling avec Katana et cookie sur tous les domaines..."
            katana -list $HTTPX_200_URLS -jc -kf -headers "$COOKIE_HEADER" | anew $ALL_URLS_FILE > /dev/null
        fi
    else
        print_message "$GREEN" "[🔍] Crawling avec Katana..."
        katana -list $HTTPX_200_URLS -jc -kf | anew $ALL_URLS_FILE > /dev/null
    fi

    # Vérification des URLs live avec httpx
    print_message "$GREEN" "[🌐] Vérification des URLs actives avec httpx..."
    cat $ALL_URLS_FILE | httpx -o $URLS_LIVE_FILE

    # Nettoyage des URLs avec uro
    print_message "$GREEN" "[🧹] Nettoyage des URLs avec uro..."
    cat $URLS_LIVE_FILE | uro --whitelist php js html asp > $CLEANS_URLS_FILE

    # Statistiques
    local total_urls=$(wc -l < $ALL_URLS_FILE)
    local live_urls=$(wc -l < $URLS_LIVE_FILE)
    local clean_urls=$(wc -l < $CLEANS_URLS_FILE)
    
    print_message "$CYAN" "[📊] Statistiques:"
    print_message "$CYAN" "  - URLs trouvées: $total_urls"
    print_message "$CYAN" "  - URLs actives: $live_urls"
    print_message "$CYAN" "  - URLs nettoyées: $clean_urls"

    # Suppression du fichier temporaire
    rm -f $ALL_URLS_FILE

    print_message "$CYAN" "[✅] URL Crawling terminé ! Résultats stockés dans $URLS_DIR"
}

get_juicy_files() {
    print_message "$GREEN" "[🔍] Récupération de fichiers juicy / sensibles..."

    cat $URLS_LIVE_FILE | grep -E "\.json|\.xml|\.csv|\.sql|\.conf|\.log|\.bak|\.backup|\.swp|\.old|\.zip|\.tar|\.gz|\.7z|\.rar|\.txt|\.cache|\.secret|\.db|\.yml|\.config" | anew $JUICY_URLS_FILE

    if [[ ! -s "$JUICY_URLS_FILE" ]]; then
        print_message "$RED" "[❌] Aucun fichier juicy trouvé !"
        return 1
    fi

    local juicy_count=$(wc -l < $JUICY_URLS_FILE)
    print_message "$CYAN" "[✅] $juicy_count fichiers juicy identifiés et stockés dans $JUICY_URLS_FILE"
}


get_js_files() {
    print_message "$GREEN" "[🔍] Récupération des fichiers JS..."

    cat $URLS_LIVE_FILE | grep -E "\.js" | anew $JS_URLS_FILE
    
    if [[ ! -s "$JS_URLS_FILE" ]]; then
        print_message "$RED" "[❌] Aucune URL JS trouvée !"
        return 1
    fi

    local js_count=$(wc -l < $JS_URLS_FILE)
    print_message "$CYAN" "[✅] $js_count fichiers JS identifiés et stockés dans $JS_URLS_FILE"

}

get_php_files() {
    print_message "$GREEN" "[🔍] Récupération des fichiers PHP..."

    cat $URLS_LIVE_FILE | grep -E "\.php" | anew $PHP_URLS_FILE

    if [[ ! -s "$PHP_URLS_FILE" ]]; then
        print_message "$RED" "[❌] Aucune URL PHP trouvée !"
        return 1
    fi

    local php_count=$(wc -l < $PHP_URLS_FILE)
    print_message "$CYAN" "[✅] $php_count fichiers PHP identifiés et stockés dans $PHP_URLS_FILE"

}

3_urls_gathering_and_processing() {
    local COOKIE_HEADER="$1"  # Paramètre pour passer le cookie si souhaité
    local TARGET_DOMAIN="$2"  # Domaine spécifique

    # Appeler la fonction avec ou sans cookie, et spécifier le domaine cible
    urls_crawling_and_cleaning "$COOKIE_HEADER" "$TARGET_DOMAIN"

    get_juicy_files
    get_js_files
    get_php_files
}

# Appel de la fonction avec les arguments passés
3_urls_gathering_and_processing "$1" "$2"


