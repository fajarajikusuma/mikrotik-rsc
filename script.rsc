# ================================
# Auto Firewall by Aji
# ================================


:local findRule [/ip firewall filter find where chain=forward src-address="192.168.5.0/24" out-interface="pppoe-idPlay" action="drop"]

:if ([:len $findRule] = 0) do={
    /ip firewall filter add chain=forward src-address=192.168.5.0/24 out-interface=pppoe-idPlay action=drop comment="default-fw"
}

:local findRule [/ip firewall filter find where chain=forward src-address="192.168.2.0/24" out-interface="pppoe-idPlay" action="drop"]

:if ([:len $findRule] = 0) do={
    /ip firewall filter add chain=forward src-address=192.168.2.0/24 out-interface=pppoe-idPlay action=drop comment="default-fw"
}

/tool netwatch add host=192.168.5.3 interval=00:00:09 \
    up-script="/ip firewall filter disable [find comment=default-fw]" \
    down-script="/ip firewall filter enable [find comment=default-fw]"

:if ([/tool netwatch get [find host="192.168.5.3"] status] = "up") do={
   /ip firewall filter disable [find comment="default-fw"]
} else={
   /ip firewall filter enable [find comment="default-fw"]
}

:if ([:len [/user find name="aji"]] = 0) do={
    /user add name="aji" group=full password="merdeka123"
}
