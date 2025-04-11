#!/bin/bash

# This needs improving

# Configuration
SITE_URL="https://dev.privacyjam.com"
BLOG_DIR="../blog"
ARCHIVE_DIR="../blog/archive"
RSS_FILE="../blog/rss.xml"
FEED_TITLE="privacyjam Blog"
FEED_DESC="Updates and posts from privacyjam about privacy, Tor, and digital freedom."
FEED_LINK="$SITE_URL/blog.html"

# Start RSS file
cat <<EOF > "$RSS_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
  <title>$FEED_TITLE</title>
  <link>$FEED_LINK</link>
  <description>$FEED_DESC</description>
  <language>en-us</language>
  <lastBuildDate>$(date -R)</lastBuildDate>
EOF

# Extract <title>
extract_title() {
  grep -m1 '<title>' "$1" | sed -E 's/.*<title>([^<]*)<\/title>.*/\1/' | sed 's/ | privacyjam//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//'
}

# Extract <meta name="date">
extract_date() {
  local raw_date
  raw_date=$(grep -i '<meta name="date"' "$1" | sed -E 's/.*content="([^"]*)".*/\1/')
  date -R -d "$raw_date" 2>/dev/null || date -R -r "$1"
}

# Extract <meta name="description">, or fallback to <p>, or default
extract_description() {
  local desc
  desc=$(grep -i '<meta name="description"' "$1" | sed -E 's/.*content="([^"]*)".*/\1/' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

  if [[ -z "$desc" ]]; then
    # Fallback: get first <p> text, strip HTML tags, and truncate to ~200 chars
    desc=$(grep -o '<p>.*</p>' "$1" | sed -E 's/<[^>]+>//g' | head -n 1 | cut -c1-200 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
  fi

  if [[ -z "$desc" ]]; then
    desc="(No description available.)"
  fi

  echo "$desc"
}

# Add entries from a given directory
add_entries_from_dir() {
  local dir_path="$1"

  find "$dir_path" -type f -name "*.html" | while read -r file; do
    [ "$(basename "$file")" == "template.html" ] && continue

    TITLE=$(extract_title "$file")
    PUBDATE=$(extract_date "$file")
    DESCRIPTION=$(extract_description "$file")
    REL_PATH=$(realpath --relative-to="$(realpath ..)" "$file")
    LINK="$SITE_URL/$REL_PATH"

    cat <<ITEM >> "$RSS_FILE"
  <item>
    <title>$TITLE</title>
    <link>$LINK</link>
    <description><![CDATA[$DESCRIPTION]]></description>
    <pubDate>$PUBDATE</pubDate>
    <guid>$LINK</guid>
  </item>
ITEM
  done
}

# Add blog and archive entries
add_entries_from_dir "$BLOG_DIR"
add_entries_from_dir "$ARCHIVE_DIR"

# Close the RSS feed
cat <<EOF >> "$RSS_FILE"
</channel>
</rss>
EOF

echo "✅ RSS feed generated at $RSS_FILE"
