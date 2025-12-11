#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.conf"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Ошибка: config.conf не найден по пути $CONFIG_FILE"
    exit 1
fi

HOSTNAME=$(hostname)

if [ -n "$1" ]; then
 SOURCE_DIR="$1"
 echo "Динамический путь"
else
 echo "Конфиг путь"
fi

if [ -z "$SOURCE_DIR" ] || [ ! -d "$SOURCE_DIR" ]; then
 echo "Error"
 exit 1
fi

mkdir -p "$BACKUP_DIR"

ARC_NAME="backup_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"

tar -czvf "$BACKUP_DIR/$ARC_NAME" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" || exit 1

SIZE=$(du -h "$BACKUP_DIR/$ARC_NAME" | cut -f1)

find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime "$KEEP_DAYS" -delete

curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument" \
-F chat_id="$TELEGRAM_CHAT_ID" \
-F document=@"$BACKUP_DIR/$ARC_NAME" \
-F caption="Бэкап сервера $HOSTNAME готов!%0A $ARC_NAME%0A Размер: $SIZE Источник: $SOURCE_DIR%0A"

