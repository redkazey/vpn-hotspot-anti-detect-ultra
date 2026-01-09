#!/system/bin/sh
# VPN Hotspot Anti-Detect v4.7 - FINAL 2026

MODDIR=${0%/*}
LOG="/data/adb/vpn-hotspot.log"
log() { echo "$(date) - $1" >> "$LOG"; }

sleep 30
log "🚀 Iniciando Proteção Total..."

# 1. BLOQUEIO TOTAL DE IPV6 (Segurança contra detecção da operadora)
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6
echo 1 > /proc/sys/net/ipv6/conf/wlan0/disable_ipv6

# 2. ENCAMINHAMENTO IPV4
sysctl -w net.ipv4.ip_forward=1

# 3. ANTI-DETECÇÃO (TTL 64)
# Aplica no tráfego que sai e no que entra para total invisibilidade
iptables -t mangle -I POSTROUTING -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -j TTL --ttl-set 64

# 4. MASCARAMENTO (NAT)
iptables -t nat -I POSTROUTING -o tun+ -j MASQUERADE
iptables -t nat -I POSTROUTING -o wg+ -j MASQUERADE

# 5. SEQUESTRO DE DNS (Evita página de recarga da operadora)
# Redireciona consultas DNS para o Google através da VPN
iptables -t nat -I PREROUTING -p udp --dport 53 -j DNAT --to-destination 8.8.8.8
iptables -t nat -I PREROUTING -p tcp --dport 53 -j DNAT --to-destination 8.8.8.8

# 6. MSS CLAMPING (O segredo da velocidade no YouTube/TikTok)
# Força os pacotes a caberem no túnel sem fragmentação
iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# 7. PERMISSÕES DE FLUXO
iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -I FORWARD -i wlan+ -j ACCEPT
iptables -I FORWARD -o wlan+ -j ACCEPT

# 8. AJUSTE DE MTU PARA REDES 4G/5G EM 2026
for interface in wlan0 wlan1 wlan.ap0; do
    ip link set dev $interface mtu 1280 2>/dev/null
done

log "✅ Sistema pronto. Navegação liberada."

while true; do
    [ "$(cat /proc/sys/net/ipv4/ip_forward)" != "1" ] && sysctl -w net.ipv4.ip_forward=1
    sleep 60
done &
