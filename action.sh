#!/system/bin/sh
# VPN Hotspot - Seletor por Botões Físicos

# Função para ler os botões
keycheck() {
    (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep -q "KEY_VOLUMEUP") && return 10
    (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep -q "KEY_VOLUMEDOWN") && return 11
    return 12
}

echo "==========================="
echo "🔥 VPN HOTSPOT SELECTOR"
echo "==========================="
echo "DENTRO DE 5 SEGUNDOS APERTE:"
echo ""
echo "➕ VOLUME UP   : REATIVAR TUDO"
echo "➖ VOLUME DOWN : FIX MTU 1280"
echo ""

# Aguarda a tecla ser pressionada
keycheck &
KPID=$!
(sleep 5 && kill -9 $KPID 2>/dev/null) &

wait $KPID
RESULT=$?

case $RESULT in
    10)
        echo "🚀 REATIVANDO FIREWALL..."
        sysctl -w net.ipv4.ip_forward=1
        iptables -t nat -I POSTROUTING -o tun+ -j MASQUERADE
        iptables -t mangle -I POSTROUTING -j TTL --ttl-set 64
        iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
        echo "✅ CONCLUÍDO!"
        ;;
    11)
        echo "🔧 APLICANDO FIX MTU 1280..."
        ip link set wlan0 mtu 1280 2>/dev/null
        ip link set wlan.ap0 mtu 1280 2>/dev/null
        echo "✅ MTU REDUZIDO!"
        ;;
    *)
        echo "⏱️ TEMPO ESGOTADO."
        ;;
esac
