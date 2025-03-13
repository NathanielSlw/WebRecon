#!/bin/bash
source config.sh

# Fonction pour exécuter Subfinder
subfinder_func() {
    print_message "$GREEN" "[🔍] Subfinder en cours..."
    subfinder -d $DOMAIN -all -recursive | anew $ALL_SUBS
}

# Fonction pour exécuter Assetfinder
assetfinder_func() {
    print_message "$GREEN" "[🔍] Assetfinder en cours..."
    assetfinder --subs-only $DOMAIN | anew $ALL_SUBS
}

# Fonction pour extraire les sous-domaines depuis crt.sh
crtsh_func() {
    print_message "$GREEN" "[🔍] Extraction de subdomains avec crt.sh..."
    curl -s "https://crt.sh/?q=%.$DOMAIN&output=json" | jq -r '.[].common_name' | sort -u | anew $ALL_SUBS
}

# Fonction pour générer des permutations DNS avec Altdns
altdns_func() {
    print_message "$GREEN" "[🔄] Génération de permutations DNS avec Altdns..."
    altdns -i $ALL_SUBS -o $OUTPUT_DIR/permutated_subs.txt -w ~/Tools/altdns/words.txt
    print_message "$GREEN" "[📝] Fusion des résultats..."
    cat $OUTPUT_DIR/permutated_subs.txt | anew $ALL_SUBS > /dev/null 2>&1
    rm $OUTPUT_DIR/permutated_subs.txt
}

# Fonction pour vérifier les sous-domaines actifs
check_live_subs_func() {
    print_message "$GREEN" "[🌐] Vérification des sous-domaines actifs avec HTTPX..."
    cat $ALL_SUBS | httpx -silent -o $LIVE_SUBS 
}

naabu_scan_func() {
    print_message "$GREEN" "[🔍] Scan de ports en cours avec Naabu..."
    naabu -list $LIVE_SUBS -nmap-cli 'nmap -sV -sC' -o $NAABU_SCAN
}

1_subdomain_enumeration() {
    echo $DOMAIN >> $ALL_SUBS
	subfinder_func
	assetfinder_func
	crtsh_func
	#altdns_func
   
	check_live_subs_func
    naabu_scan_func

	print_message "$CYAN" "[✅] Scan terminé !"
    print_message "$CYAN" "📁 Tous les résultats sont dans $SUBDOMAIN_DIR/"
}

1_subdomain_enumeration


# --------------------------------------------------------------------------------------------
