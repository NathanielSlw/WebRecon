#!/bin/bash
source config.sh

# SSRF Candidates --------------------------------------------------------------------------------------------
get_ssrf_candidates() {
    print_message "$GREEN" "[🔍] Recherche de SSRF candidates..."
    cat $CLEANS_URLS_FILE | grep -Ei "url=|uri=|redirect=|link=|file=|page=|to=|u=|forward=|next=" | anew $SSRF_CANDIDATES
}

# AUTHENTICATION PAGES --------------------------------------------------------------------------------------------
get_authentication_pages() {
    print_message "$GREEN" "[🔍] Recherche de pages d'authentification..."
    cat $CLEANS_URLS_FILE | grep -Ei "/(login|signin|auth|register|signup|reset|forgot|verify|session|password|create-account|recover|password-reset|2fa|otp|verify|xml|upload|data|api/signup|api/login|api/2fa)" | anew $AUTH_PAGES
}

get_register_pages() {
    print_message "$GREEN" "[🔍] Recherche de pages de register..."
    cat $AUTH_PAGES | grep -Ei "/(register|signup|create-account|api/signup)" | anew $REGISTER_PAGES
}

get_login_pages() {
    print_message "$GREEN" "[🔍] Recherche de pages de login..." 
    cat $AUTH_PAGES | grep -Ei "/(login|auth|session|signin|api/login)" | anew $LOGIN_PAGES
}

get_reset_password_pages() {
    print_message "$GREEN" "[🔍] Recherche de pages de reset & forgot password..." 
    cat $AUTH_PAGES | grep -Ei "/(reset|forgot-password|recover|password-reset)" | anew $RESET_PASSWORD_PAGES
}

get_otp_2fa_pages() {
    print_message "$GREEN" "[🔍] Recherche de pages de 2FA & OTP Endpoints..." 
    cat $AUTH_PAGES | grep -Ei "/(2fa|auth/verify|api/2fa|otp|verify)" | anew $OTP_2FA_PAGES
}

# WORDPRESS PAGES --------------------------------------------------------------------------------------------

get_wordpress_pages() {
    print_message "$GREEN" "[🔍] Recherche de pages Wordpress..."
    cat $CLEANS_URLS_FILE | grep -Ei "/(wp-admin|wp-login|wp-content|wp-includes|wp-json|wp-login.php|wp-admin.php|wp-content.php|wp-includes.php|xmlrpc.php)" | anew $WORDPRESS_PAGES
}

4_extract_interesting_pages() {    
    get_ssrf_candidates
    get_authentication_pages
    get_register_pages
    get_login_pages
    get_reset_password_pages
    get_otp_2fa_pages
    get_wordpress_pages
}

4_extract_interesting_pages