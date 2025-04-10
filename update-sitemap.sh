#!/bin/bash

BASE_URL="https://privacyjam.com"
OUTPUT="sitemap.xml.new"

echo '<?xml version="1.0" encoding="UTF-8"?>' > $OUTPUT
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> $OUTPUT

# Find all .html files excluding hidden or special directories
find . -type f -name "*.html" ! -path "*/.*" | while read file; do
  # Remove leading ./ and prepend domain
  url="${file#./}"
  echo "  <url>" >> $OUTPUT
  echo "    <loc>${BASE_URL}/${url}</loc>" >> $OUTPUT
  echo "  </url>" >> $OUTPUT
done

echo '</urlset>' >> $OUTPUT

echo "✅ Sitemap generated to $OUTPUT"
