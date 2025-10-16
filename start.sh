#!/bin/bash
sleep 1
kquitapp5 plasmashell & # Отключаем shell
sleep 1
xinput set-prop 9 "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1 & # Калебруем тачскрин
sleep 1
xinput map-to-output 9 HDMI-1 & # Отключаем верхний монитор от тачскрина
sleep 3
/sbin/shutdown -h 17:45 & # Выключаем компьютер пао времени
sleep 1
while ! ping -c 1 172.19.13.222 &> /dev/null # Ждем, пока хост не станет доступным
do
    sleep 3  # Подождите 3 секунды перед повторной проверкой
done
/opt/yandex/browser/yandex-browser --incognito --noerrdialogs --kiosk --window-position=0,0 --disable-extensions --disable-infobars --disable-notifications --disable-popup-blocking http://172.19.13.222/kiosk_top & # Запускаем Яндекс браузер с сайтом в режиме инкогнито, без отчетов об ошибоках, без всплывающий окон, с директорией видеокодеков
sleep 1
/usr/bin/chromium-browser --incognito --noerrdialogs --kiosk --disable-pinch --overscroll-history-navigation=0 --window-position=0,1920 http://172.19.13.222/kiosk_bottom?kiosk=132 & # Запускаем браузер хромиум с сайтом в режиме инкогнито, отключаем масштабирование, без отчетов об ошибоках