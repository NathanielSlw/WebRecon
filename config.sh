
# ORGANISATION FICHIERS --------------------------------------------------------------------------------------------------------------
OUTPUT_DIR="$HOME/BugBounty/$DOMAIN"

# Création des dossiers pour organiser les résultats
SUBDOMAIN_DIR="$OUTPUT_DIR/1_subdomains"
HTTPX_DIR="$OUTPUT_DIR/2_httpx_analysis"
URLS_DIR="$OUTPUT_DIR/3_urls"
VULN_DIR="$OUTPUT_DIR/vulnerabilities"
INTERESTING_PAGES="$OUTPUT_DIR/4_extract_interesting_pages"

mkdir -p "$SUBDOMAIN_DIR" "$HTTPX_DIR" "$VULN_DIR" "$URLS_DIR" "$MANUAL_TESTING_DIR"

# Subdomains Enumeration - Fichiers de sortie 
ALL_SUBS="$SUBDOMAIN_DIR/all_subdomains.txt"
LIVE_SUBS="$SUBDOMAIN_DIR/live_subdomains.txt"
VULN_SUBS_TAKEOVER="$VULN_DIR/vulnerable_subs_takeover.txt"
NAABU_SCAN="$SUBDOMAIN_DIR/naabu_scan.txt"

# HTTPX Analysis - Fichiers de sortie 
HTTPX_FILE="$HTTPX_DIR/httpx_live.txt"
HTTPX_200_FILE="$HTTPX_DIR/httpx_200.txt"
HTTPX_301_302_FILE="$HTTPX_DIR/httpx_301_302_redirects.txt"
HTTPX_401_FILE="$HTTPX_DIR/httpx_401.txt"
HTTPX_403_FILE="$HTTPX_DIR/httpx_403.txt"
HTTPX_OTHER="$HTTPX_DIR/httpx_autres.txt"
GOWITNESS_FOLDER="$HTTPX_DIR/gowitness/" 

# URLS Gathering - Fichiers de sortie
HTTPX_200_URLS="$URLS_DIR/httpx_200_urls.txt"
URLS_LIVE_FILE="$URLS_DIR/all_urls_live.txt"
CLEANS_URLS_FILE="$URLS_DIR/clean_urls.txt"
JUICY_URLS_FILE="$URLS_DIR/juicy_urls.txt"
JS_URLS_FILE="$URLS_DIR/js_urls.txt"
PHP_URLS_FILE="$URLS_DIR/php_urls.txt"

# Extract Interesting pages for further manual & automatic analysis
SSRF_CANDIDATES="$INTERESTING_PAGES/ssrf_candidates.txt"
AUTH_PAGES="$INTERESTING_PAGES/authentication_pages.txt"
REGISTER_PAGES="$INTERESTING_PAGES/register_pages.txt"
LOGIN_PAGES="$INTERESTING_PAGES/login_pages.txt"
RESET_PASSWORD_PAGES="$INTERESTING_PAGES/reset_password_pages.txt"
OTP_2FA_PAGES="$INTERESTING_PAGES/otp_2fa_pages.txt"
# --------------------------------------------------------------------------------------------------------------

# Définition des couleurs pour les messages
RED='\e[31m'
GREEN='\e[32m'
CYAN='\e[36m'
LIGHT_BLUE='\e[94m'
NC='\e[0m' # Reset

# Fonction pour afficher les messages avec une couleur donnée
print_message() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

print_separator() {
    echo -e "\n${LIGHT_BLUE}====================================================================================================${NC}"
}