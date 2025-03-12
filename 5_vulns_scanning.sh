#!/bin/bash
source config.sh

# VULN SCANNING ON SUBDOMAINS -------------------------------------------------------------------------------------------------------------- 

# Fonction pour vérifier le subdomains takeover
subdomain_takeover_func() {
    print_message "$RED" "[⚠️] Vérification du takeover de sous-domaines..."
    subzy run --targets $ALL_SUBS --hide_fails --vuln | anew $VULN_SUBS_TAKEOVER
}

# Fonction pour vérifier le HTTP Request Smuggling 
request_smuggling() {
    print_message "$GREEN" "[🔍] HTTP Request Smuggling en cours..."
    cat $LIVE_SUBS | $HOME/Tools/smuggler/smuggler.py | tee -a $OUTPUT_DIR/smuggler.txt
}

vulnerabilities_scanning_on_subdomains() {
    print_separator
    print_message "$LIGHT_BLUE" "[+] 4. Analyse des vulnérabilités sur les sous-domaines"
    subdomain_takeover_func
    request_smuggling
}

# VULN SCANNING ON URLS -------------------------------------------------------------------------------------------------------------- 

js_vuln_analysis() {
    print_message "$GREEN" "Analyse JS ..."

    if [[ ! -s "$JS_URLS_FILE" ]]; then
        print_message "$RED" "[❌] Aucun fichier JS à analyser !"
        return 1
    fi

    # Analyse des URLs JS avec Mantra & Linkfinder
    cat $JS_URLS_FILE | mantra | tee -a $URLS_DIR/mantra.txt
    python $HOME/Tools/linkfinder.py -i $JS_URLS_FILE -o cli | tee -a $URLS_DIR/linkfinder.txt

    # Analyse des URLs JS avec Nuclei (peut être long)
    cat $JS_URLS_FILE | nuclei -t $HOME/nuclei-templates/http/exposures -c 30

    print_message "$CYAN" "[✅] Analyse JS terminée ! Résultats stockés dans $JS_URLS_FILE"
}

php_vuln_analysis() {
    print_message "$GREEN" "[🔍] Analyse des fichiers PHP..."

    if [[ ! -s "$PHP_URLS_FILE" ]]; then
        print_message "$RED" "[❌] Aucun fichier PHP à analyser !"
        return 1
    fi

    # Identifies hidden parameters in PHP endpoints with Arjun
    arjun -i $PHP_URLS_FILE | tee -a parameters.txt

    # SQL Injection avec SQLMap
    sqlmap -m $PHP_URLS_FILE --dbs --banner --batch --random-agent

    print_message "$CYAN" "[✅] Analyse PHP terminée !"
}

send_urls_to_vulnerability_scanner() {
    print_message "$GREEN" "[🛡️] Scan de vulnérabilités sur les URLs propres..."

    if [[ ! -s "$CLEANS_URLS_FILE" ]]; then
        print_message "$RED" "[❌] Aucune URL à scanner !"
        return 1
    fi

    # Scan avec Nuclei et Jaeles
    cat $CLEANS_URLS_FILE | nuclei -t cves/ -o $VULN_DIR/nuclei_results.txt
    cat $CLEANS_URLS_FILE | jaeles scan -c config.yaml

    print_message "$CYAN" "[✅] Scan de vulnérabilités terminé ! Résultats stockés dans $VULN_DIR"
}

# Vulnerability scanning sur les URLs 
vulnerability_scanning_on_urls() {
    print_separator
    print_message "$LIGHT_BLUE" "[+] 4. Analyse ciblée des vulnérabilités"

    # Analyser JS uniquement s'il y a des fichiers
    js_vuln_analysis

    # Analyser PHP uniquement s'il y a des fichiers
    php_vuln_analysis

    send_urls_to_vulnerability_scanner

}
