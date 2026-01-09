#!/system/bin/sh
LOG="/data/adb/vpn-hotspot.log"
echo "$(date) - 🗑️ Desinstalando v4.8..." >> $LOG

# Remove apenas as regras que o módulo inseriu
iptables -t nat -D POSTROUTING -o tun+ -j MASQUERADE 2>/dev/null
iptables -t nat -D POSTROUTING -o wg+ -j MASQUERADE 2>/dev/null
iptables -t mangle -D POSTROUTING -j TTL --ttl-set 64 2>/dev/null

# Limpa arquivos temporarios
rm -rf /data/adb/vpn-hotspot
rm -f /data/adb/vpn-hotspot.log

# O Android restaura o ip_forward nativamente ao desligar o hotspot
exit 0
