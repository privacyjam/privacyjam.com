#!/bin/bash

SITE_URL="https://privacyjam.com"
BLOG_DIR="blog"
ARCHIVE_DIR="$BLOG_DIR/archive"
RSS_FILE="$BLOG_DIR/rss.xml"
FEED_TITLE="privacyjam Blog"
FEED_DESC="Updates and posts from privacyjam about privacy, Tor, and digital freedom."
FEED_LINK="$SITE_URL/blog.html"

# Start RSS feed
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

# Function to extract <title>
extract_title() {
  grep -m1 '<title>' "$1" | sed -e 's/<[^>]*>//g' | sed 's/ | privacyjam//'
}

# Function to extract <meta name="date">
extract_date() {
  local raw_date
  raw_date=$(grep -i '<meta name="date"' "$1" | sed -E 's/.*content="([^"]*)".*/\1/')
  date -R -d "$raw_date" 2>/dev/null || date -R -r "$1"
}

# Add blog entries
add_entries_from_dir() {
  for f in "$1"/*.html; do
    [ "$(basename "$f")" == "template.html" ] && continue
    TITLE=$(extract_title "$f")
    LINK="$SITE_URL/${f}"
    PUBDATE=$(extract_date "$f")
    cat <<ITEM >> "$RSS_FILE"
  <item>
    <title>$TITLE</title>
    <link>$LINK</link>
    <pubDate>$PUBDATE</pubDate>
    <guid>$LINK</guid>
  </item>
ITEM
  done
}

add_entries_from_dir "$BLOG_DIR"
add_entries_from_dir "$ARCHIVE_DIR"

# Close RSS
cat <<EOF >> "$RSS_FILE"
</channel>
</rss>
EOF

echo "✅ RSS feed generated at $RSS_FILE"
