#!/bin/bash

TARGET="/mnt/imis/share/kiosks/list.txt"
N=7                    # <- поставить нужный номер строки здесь
HOSTNAME="$(hostname)"
IP="$(ip -4 addr show scope global | awk '/inet/ {print $2}' | cut -d/ -f1 | head -n1)"

if [ -z "$IP" ]; then
  echo "No IP found" >&2
  exit 1
fi

NEWLINE="$HOSTNAME $IP"

mkdir -p "$(dirname "$TARGET")"

# Если файла нет — создаём файл с N-1 пустыми строками и строкой NEWLINE
if [ ! -e "$TARGET" ]; then
  for i in $(seq 1 $((N-1))); do echo ""; done > "$TARGET"
  echo "$NEWLINE" >> "$TARGET"
  exit 0
fi

# Прочитать N-ю строку
CUR="$(sed -n "${N}p" "$TARGET")"

# Если совпадает — ничего не делаем
if [ "$CUR" = "$NEWLINE" ]; then
  exit 0
fi

# Обеспечить, что файл имеет как минимум N-1 строк (дописать пустые строки при необходимости)
LINES_COUNT="$(wc -l < "$TARGET")"
if [ "$LINES_COUNT" -lt $((N-1)) ]; then
  missing=$((N-1 - LINES_COUNT))
  for i in $(seq 1 $missing); do echo "" >> "$TARGET"; done
fi

# Создаём временный файл и вставляем NEWLINE в N-ю позицию
TMP="$(mktemp "${TARGET}.tmp.XXXXXX")" || exit 1
{
  # первые N-1 строк (если их нет — sed ничего не выведет, но мы гарантировали их наличие выше)
  sed -n "1,$((N-1))p" "$TARGET"
  # новая N-я строка
  echo "$NEWLINE"
  # оставшиеся строки, начиная с N+1 (если есть)
  sed -n "$((N+1)),\$p" "$TARGET"
} > "$TMP" && mv -f "$TMP" "$TARGET"

exit 0