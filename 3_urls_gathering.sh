#!/bin/bash
source config.sh

urls_crawling_and_cleaning() {
    local ALL_URLS_FILE="$URLS_DIR/all_urls.txt"
    local HTTPX_200_URLS="$URLS_DIR/httpx_200_urls.txt"

    print_message "$GREEN" "[🌐] URLS Gathering avec gau & katana..."

    # Extraction de la première colonne uniquement (les URLs) du fichier HTTPX_200_FILE
    cut -d ' ' -f 1 $HTTPX_200_FILE >> $HTTPX_200_URLS

    # Récupération des URLs avec gau et katana en parallèle
    cat $HTTPX_200_URLS | xargs -I {} gau --blacklist png,jpg,gif,svg,css,woff,ttf,ico --threads 10 {} >> $ALL_URLS_FILE
    katana -list $HTTPX_200_URLS -jc >> $ALL_URLS_FILE
    sort -u -o "$ALL_URLS_FILE" "$ALL_URLS_FILE"

    # Vérification des URLs live avec httpx
    cat $ALL_URLS_FILE | httpx -o $URLS_LIVE_FILE

    # Nettoyage des URLs avec uro
    cat $URLS_LIVE_FILE | uro --whitelist php js html asp > $CLEANS_URLS_FILE

    # Suppression du fichier temporaire
    rm -f $ALL_URLS_FILE

    print_message "$CYAN" "[✅] URL Crawling terminé ! Résultats stockés dans $URLS_DIR"
}

get_js_files() {
    print_message "$GREEN" "[🔍] Récupération des fichiers JS..."

    cat $URLS_LIVE_FILE | grep -E "\.js" | anew $JS_URLS_FILE
    
    if [[ ! -s "$JS_URLS_FILE" ]]; then
        print_message "$RED" "[❌] Aucune URL JS trouvée !"
        return 1
    fi

    print_message "$CYAN" "[✅] Récupération des fichiers JS terminée ! Résultats stockés dans $JS_URLS_FILE"
}

get_php_files() {
    print_message "$GREEN" "[🔍] Récupération des fichiers PHP..."

    cat $URLS_LIVE_FILE | grep -E "\.php" | anew $PHP_URLS_FILE

    if [[ ! -s "$PHP_URLS_FILE" ]]; then
        print_message "$RED" "[❌] Aucune URL PHP trouvée !"
        return 1
    fi

    print_message "$CYAN" "[✅] Récupération des fichiers PHP terminée ! Résultats stockés dans $PHP_URLS_FILE"
}

3_urls_gathering_and_processing() {
    urls_crawling_and_cleaning
    get_js_files
    get_php_files
}

3_urls_gathering_and_processing