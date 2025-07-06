#!/bin/bash

SITE_URL="https://privacyjam.com"
BLOG_DIR="../blog"
ARCHIVE_DIR="../blog/archive"
RSS_FILE="../blog/rss.xml"
FEED_TITLE="privacyjam Blog"
FEED_DESC="Updates and posts from privacyjam about privacy, Tor, and digital freedom."
FEED_LINK="$SITE_URL/blog.html"

TMP_DIR=$(mktemp -d)
declare -A ADDED_LINKS

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

extract_title() {
  grep -m1 '<title>' "$1" | \
    sed -E 's/.*<title>([^<]*)<\/title>.*/\1/' | \
    sed -E 's/ ?\| ?[Pp]rivacy[ ]?[Jj]am$//' | \
    sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//'
}

extract_date() {
  local raw_date
  raw_date=$(grep -i '<meta name="date"' "$1" | sed -E 's/.*content="([^"]*)".*/\1/')
  date -R -d "$raw_date" 2>/dev/null || date -R -r "$1"
}

add_entries_from_dir() {
  local dir_path="$1"
  find "$dir_path" -type f -name "*.html" | while read -r file; do
    [ ! -f "$file" ] && continue
    [ "$(basename "$file")" == "search.html" ] && continue
    [ "$(realpath "$file")" == "$(realpath "$0")" ] && continue

    REL_PATH=$(realpath --relative-to="$(realpath ..)" "$file")
    LINK="$SITE_URL/$REL_PATH"
    [[ ${ADDED_LINKS["$LINK"]+_} ]] && continue
    ADDED_LINKS["$LINK"]=1

    TITLE=$(extract_title "$file")
    PUBDATE=$(extract_date "$file")
    SORT_KEY=$(date -u -d "$PUBDATE" +%s 2>/dev/null || date -u -r "$file" +%s)

    cat <<ITEM > "$TMP_DIR/$SORT_KEY.xml"
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

for entry in $(ls -r "$TMP_DIR"); do
  cat "$TMP_DIR/$entry" >> "$RSS_FILE"
done

rm -r "$TMP_DIR"

cat <<EOF >> "$RSS_FILE"
</channel>
</rss>
EOF

echo "RSS feed generated at $RSS_FILE"
