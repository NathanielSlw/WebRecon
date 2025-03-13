#!/bin/bash

# Vérifier si un domaine est fourni en argument
if [ -z "$1" ]; then
    echo -e "\e[31m[X] Usage: $0 target.com\e[0m"
    exit 1
fi

DOMAIN=$1
export DOMAIN

# Charger les configurations
source config.sh

# 1. Subdomains Enumeration
print_separator
print_message "$LIGHT_BLUE" "[+] 1. Recherche de sous-domaines pour : $DOMAIN"
bash 1_subdomains_enum.sh

# 2. HTTPX Analysis
print_separator
print_message "$LIGHT_BLUE" "[+] 2. Analyse HTTPX et Catégorisaton des résultats"
bash 2_httpx_analysis.sh

# 3. URL Gathering
print_separator
print_message "$LIGHT_BLUE" "[+] 3. URL Gathering & Processing on Live Hosts (200 OK)"
bash 3_urls_gathering.sh

# 4. Extract Interesting Pages
print_separator
print_message "$LIGHT_BLUE" "[+] 4. Extraction des pages intéressantes pour analyse ultérieure"
bash 4_extract_interesting_pages.sh

# 5. Vulnerabilities Scanning
print_separator
print_message "$LIGHT_BLUE" "[+] 4. Analyse ciblée des vulnérabilités"
#bash 5_vulns_scanning.sh