#!/system/bin/sh
# Monitor v4.7 - 2026 Edition
LOG="/data/adb/vpn-hotspot.log"
while true; do
    clear
    printf "🔥 MONITOR VPN HOTSPOT v4.7\n"
    printf "==============================\n"
    printf "📱 Aparelho: %s\n" "$(getprop ro.product.model)"
    printf "🕐 Hora:     %s\n\n" "$(date +%H:%M:%S)"
    
    printf "📶 Hotspot:  %s\n" "$(ip link show wlan0 | grep -q UP && echo "🟢 ATIVO" || echo "🔴 OFF")"
    printf "🔒 VPN:      %s\n" "$(ip a | grep -E "(tun|wg)[0-9]" && echo "🟢 CONECTADA" || echo "🔴 OFF")"
    printf "🔄 Forward:  %s\n" "$(cat /proc/sys/net/ipv4/ip_forward | grep -q 1 && echo "🟢 ATIVO" || echo "🔴 OFF")"
    
    printf "\n📋 LOG RECENTE:\n"
    tail -n 3 $LOG 2>/dev/null || echo "Sem logs disponiveis."
    printf "\n[Ctrl+C para sair]\n"
    sleep 3
done
