#!/bin/bash
source config.sh


get_info_and_categorize_httpx(){
    print_message "$GREEN" "[🌐] Catégorisation des résultats HTTPX..."

    # Exécution de httpx avec les options demandées
    cat $LIVE_SUBS | httpx -title -status-code -content-length -tech-detect -content-type -location > $HTTPX_FILE
    
    # Catégorisation des résultats HTTPX
    declare -A status_files=(
        ["301|302"]=$HTTPX_301_302_FILE
        ["401"]=$HTTPX_401_FILE
        ["403"]=$HTTPX_403_FILE
        ["200"]=$HTTPX_200_FILE
    )

    # Nettoyage des fichiers de sortie avant l'écriture
    for file in "${status_files[@]}" "$HTTPX_OTHER"; do
        > "$file"
    done

    # Filtrer et catégoriser les statuts HTTP avec grep -P
    for code in "${!status_files[@]}"; do
        grep -P "^\S+\s+\[.*?(${code}).*?\]" "$HTTPX_FILE" >> "${status_files[$code]}"
    done

    # Extraction des lignes restantes (autres codes HTTP)
    combined_regex=$(printf "|%s" "${!status_files[@]}")
    combined_regex=${combined_regex:1}  # Supprime le premier "|"
    grep -vP "^\S+\s+\[.*?(${combined_regex}).*?\]" "$HTTPX_FILE" >> "$HTTPX_OTHER"

    # Affichage d'un résumé des résultats
    print_message "$CYAN" "[📊] Résumé des statuts HTTP extraits :"
    for code in "${!status_files[@]}"; do
        count=$(wc -l < "${status_files[$code]}")
        printf "%-20s : %d\n" "${code//|/, }" "$count"
    done
    printf "%-20s : %d\n" "Autres statuts" "$(wc -l < "$HTTPX_OTHER")"

    print_message "$CYAN" "[✅] Catégorisation terminée ! Résultats stockés dans $HTTPX_DIR"
}

bypass_403_testing() {
    local output_file="$VULN_DIR/bypass_403_results.txt"
    local input_file="$HTTPX_DIR/httpx_403.txt"

    print_message "$GREEN" "[🔓] Tentative de Bypass des 403..."
    > "$output_file" # Vider le fichier avant d'ajouter les nouveaux résultats

    while read -r url; do
        print_message "$CYAN" "[➡️] Test sur : $url"
        ~/Tools/nomore403/nomore403 -u "$url" -f ~/Tools/nomore403/payloads/ --no-banner --status 200,301,302 | tee -a "$output_file"
    done < <(cut -d ' ' -f 1 "$input_file")

    print_message "$CYAN" "[✅] Bypass terminé ! Résultats enregistrés dans $output_file"
}

2_httpx_analysis_and_categorization() {
    get_info_and_categorize_httpx
    bypass_403_testing
}

2_httpx_analysis_and_categorization