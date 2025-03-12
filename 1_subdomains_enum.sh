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
    print_message "$GREEN" "[🔍] Extraction de crt.sh..."
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

# Fonction pour afficher la fin du scan
finish_scan() {
    print_message "$CYAN" "[✅] Scan terminé !"
    print_message "$CYAN" "📁 Tous les résultats sont dans $SUBDOMAIN_DIR/"
}


1_subdomain_enumeration() {
	subfinder_func
	assetfinder_func
	crtsh_func
	#altdns_func
	check_live_subs_func
	# subdomain_takeover_func
    # request_smuggling
	finish_scan
}

1_subdomain_enumeration


# --------------------------------------------------------------------------------------------

# Fonction pour vérifier le takeover des sous-domaines
subdomain_takeover_func() {
    print_message "$RED" "[⚠️] Vérification du takeover de sous-domaines..."
    subzy run --targets $ALL_SUBS --hide_fails --vuln | anew $VULN_SUBS_TAKEOVER
}

request_smuggling() {
    print_message "$GREEN" "[🔍] HTTP Request Smuggling en cours..."
    cat $LIVE_SUBS | $HOME/Tools/smuggler/smuggler.py | tee -a $OUTPUT_DIR/smuggler.txt
}

vulnerabilities_scanning() {
    subdomain_takeover_func
    request_smuggling
}