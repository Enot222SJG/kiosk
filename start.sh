#!/bin/bash

# Функция для проверки наличия команд
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Проверка необходимых команд
for cmd in xrandr xinput ping; do
    if ! command_exists "$cmd"; then
        echo "Ошибка: команда $cmd не найдена" >&2
        exit 1
    fi
done

# Закрытие plasmashell (с проверкой)
if command_exists kquitapp5; then
    kquitapp5 plasmashell || echo "Не удалось закрыть plasmashell" >&2
    sleep 1
else
    echo "kquitapp5 не найден, пропускаем закрытие plasmashell" >&2
fi

# Настройка дисплеев
xrandr --output HDMI-1 --below VGA-1 --rotate left || {
    echo "Ошибка настройки дисплеев" >&2
    exit 1
}
sleep 1

# Настройка тачскрина (с проверкой устройства)
device_id=9
if xinput list | grep -q "id=$device_id"; then
    xinput set-prop $device_id "Coordinate Transformation Matrix" 1 0 0 0 1 0 0 0 1
    xinput map-to-output $device_id VGA-1
    xinput set-prop $device_id "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1
    xinput map-to-output $device_id HDMI-1
else
    echo "Устройство с ID $device_id не найдено" >&2
fi

# Запланированное выключение
if [ -x /sbin/shutdown ]; then
    /sbin/shutdown -h 17:45 &
else
    echo "shutdown не найден, пропускаем запланированное выключение" >&2
fi

# Ожидание доступности сервера
while ! ping -c 1 -W 3 172.19.13.222 &> /dev/null; do
    sleep 3
done

# Запуск браузеров (с проверкой)
if [ -x "/opt/yandex/browser/yandex-browser" ]; then
    /opt/yandex/browser/yandex-browser --incognito --noerrdialogs --kiosk \
        --window-position=0,0 --disable-extensions --disable-infobars \
        --disable-notifications --disable-popup-blocking \
        http://172.19.13.222/kiosk_top &
else
    echo "Yandex Browser не найден" >&2
fi

sleep 1

if command_exists chromium-browser; then
    chromium-browser --incognito --noerrdialogs --kiosk --disable-pinch \
        --overscroll-history-navigation=0 --window-position=0,1920 \
        http://172.19.13.222/kiosk_bottom?kiosk=133 &
elif command_exists /usr/bin/chromium-browser; then
    /usr/bin/chromium-browser --incognito --noerrdialogs --kiosk --disable-pinch \
        --overscroll-history-navigation=0 --window-position=0,1920 \
        http://172.19.13.222/kiosk_bottom?kiosk=133 &
else
    echo "Chromium Browser не найден" >&2
fi
