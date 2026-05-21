#!/bin/bash
# YouTube uploader wrapper — called from Finder Quick Action
# Usage: upload.sh <video_file>

DIR="/Users/denis/Projects/youtube-uploader"
BINARY="$DIR/youtubeuploader"
SECRETS="$DIR/client_secrets.json"
TOKEN="$DIR/token.json"
CONFIG="$DIR/config.json"
LOG="$DIR/upload.log"
DB="$DIR/uploaded.json"

FILE="$1"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

notify() {
    /opt/homebrew/bin/terminal-notifier -title "$1" -message "$2" -sound Glass -appIcon "/System/Applications/Photos.app/Contents/Resources/AppIcon.icns"
}

if [ -z "$FILE" ]; then
    notify "YouTube" "Ошибка: файл не передан"
    exit 1
fi

if [ ! -f "$SECRETS" ]; then
    notify "YouTube" "Нет client_secrets.json — см. инструкцию в ~/Projects/youtube-uploader/SETUP.md"
    exit 1
fi

# Title = filename without extension
TITLE=$(basename "$FILE" | sed 's/\.[^.]*$//')
FILE_SIZE_BYTES=$(stat -f "%z" "$FILE" 2>/dev/null)
FILE_CREATED=$(stat -f "%SB" -t "%Y-%m-%d %H:%M" "$FILE" 2>/dev/null)
FILE_SIZE=$(du -sh "$FILE" 2>/dev/null | cut -f1)

# Duplicate check by MD5 hash
[ ! -f "$DB" ] && echo "[]" > "$DB"
notify "YouTube" "Проверяю файл: $TITLE..."
FILE_MD5=$(md5 -q "$FILE" 2>/dev/null)
EXISTING_URL=$(python3 - <<EOF
import json
db = json.load(open("$DB"))
match = next((e for e in db if e.get("md5") == "$FILE_MD5"), None)
print(match["url"] if match else "")
EOF
)

if [ -n "$EXISTING_URL" ]; then
    echo "$EXISTING_URL" | pbcopy
    log "ДУБЛИКАТ: $TITLE уже загружен → $EXISTING_URL"
    notify "YouTube — Дубликат!" "$TITLE уже загружен. Ссылка скопирована: $EXISTING_URL"
    exit 0
fi

# Read playlist ID from config
PLAYLIST_ID=""
if [ -f "$CONFIG" ]; then
    PLAYLIST_ID=$(python3 -c "import json; d=open('$CONFIG').read(); print(json.loads(d).get('playlist_id',''))" 2>/dev/null)
fi

# Build args
ARGS=(-filename "$FILE" -title "$TITLE" -privacy unlisted -secrets "$SECRETS" -cache "$TOKEN")
[ -n "$PLAYLIST_ID" ] && ARGS+=(-playlistID "$PLAYLIST_ID")

START_TIME=$(date +%s)

log "Начало загрузки: $FILE"
log "Файл создан: $FILE_CREATED | Размер: $FILE_SIZE"
notify "YouTube Upload" "Начинаю загрузку: $TITLE"

# Run uploader, capture output
OUTPUT=$("$BINARY" "${ARGS[@]}" 2>&1)
EXIT_CODE=$?

ELAPSED=$(( $(date +%s) - START_TIME ))
DURATION="${ELAPSED}с"
[ $ELAPSED -ge 60 ] && DURATION="$(( ELAPSED / 60 ))м $(( ELAPSED % 60 ))с"

log "$OUTPUT"

if [ $EXIT_CODE -ne 0 ]; then
    log "ОШИБКА (код $EXIT_CODE)"
    notify "YouTube — Ошибка" "$OUTPUT"
    exit $EXIT_CODE
fi

# Extract video ID from output
VIDEO_ID=$(echo "$OUTPUT" | grep -o 'Video ID: [A-Za-z0-9_-]*' | awk '{print $3}')
if [ -n "$VIDEO_ID" ]; then
    VIDEO_URL="https://youtu.be/$VIDEO_ID"
    echo "$VIDEO_URL" | pbcopy
    UPLOADED_AT=$(date '+%Y-%m-%d %H:%M')

    # Save to DB
    python3 - <<EOF
import json
db = json.load(open("$DB"))
db.append({"name": "$TITLE", "md5": "$FILE_MD5", "size": "$FILE_SIZE_BYTES", "url": "$VIDEO_URL", "uploaded": "$UPLOADED_AT"})
json.dump(db, open("$DB", "w"), ensure_ascii=False, indent=2)
EOF

    log "━━━ ГОТОВО: $TITLE | $FILE_SIZE | создан $FILE_CREATED | загружен $UPLOADED_AT | время загрузки $DURATION | $VIDEO_URL"
    notify "YouTube — Готово!" "$TITLE ($FILE_SIZE, $DURATION) — ссылка скопирована"
else
    log "━━━ ГОТОВО (без ID): $TITLE | $FILE_SIZE | создан $FILE_CREATED | загрузка $DURATION"
    notify "YouTube — Готово!" "$TITLE загружено"
fi
