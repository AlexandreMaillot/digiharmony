#!/bin/bash

# Script pour merger tous les fichiers .mdc de docs/rules en un seul fichier roles.md

RULES_DIR="docs/rules"
OUTPUT_FILE="docs/rules/roles.md"

# Créer le fichier de sortie (vide au début)
> "$OUTPUT_FILE"

# Ajouter un en-tête
cat >> "$OUTPUT_FILE" << 'EOF'
# Règles du Projet

Ce fichier contient toutes les règles du projet, fusionnées depuis les fichiers individuels.

---

EOF

# Trouver tous les fichiers .mdc, les trier et les merger
find "$RULES_DIR" -type f -name "*.mdc" | sort | while read -r file; do
    # Obtenir le chemin relatif depuis docs/rules
    rel_path="${file#$RULES_DIR/}"
    
    # Ajouter un séparateur avec le nom du fichier
    echo "" >> "$OUTPUT_FILE"
    echo "## Fichier: $rel_path" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Ajouter le contenu du fichier
    cat "$file" >> "$OUTPUT_FILE"
    
    # Ajouter un séparateur à la fin
    echo "" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

echo "✅ Fichier $OUTPUT_FILE créé avec succès!"
echo "📊 Nombre de fichiers fusionnés: $(find "$RULES_DIR" -type f -name "*.mdc" | wc -l | tr -d ' ')"
