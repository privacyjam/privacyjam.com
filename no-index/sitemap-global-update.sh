#!/bin/bash

# This script updates the sitemap using files from the directory above where it is located
# It clears and writes a new sitemap file one level up

BASE_URL="https://privacyjam.com"  # Domain
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # Absolute path of the script
TARGET_DIR="$(realpath "$SCRIPT_DIR/..")"
OUTPUT="$SCRIPT_DIR/../sitemap.xml"

echo "Generating sitemap from: $TARGET_DIR"
echo "Saving sitemap to: $OUTPUT"

# Start new sitemap
echo '<?xml version="1.0" encoding="UTF-8"?>' > "$OUTPUT"
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> "$OUTPUT"

# Loop through .html files
find "$TARGET_DIR" -type f -name "*.html" ! -path "*/.*" | while read -r file; do
  # Get relative path
  relative_path="${file#$TARGET_DIR/}"

  # Write each URL
  echo "  <url>" >> "$OUTPUT"
  echo "    <loc>${BASE_URL}/${relative_path}</loc>" >> "$OUTPUT"
  echo "  </url>" >> "$OUTPUT"
done

echo '</urlset>' >> "$OUTPUT"
echo "✅ Sitemap generated at: $OUTPUT"
