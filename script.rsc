# ================================
# Auto Firewall by Aji
# ================================

:local findRule [/ip firewall filter find where chain=forward src-address="192.168.5.0/24" in-interface="ether3-LAN" action="drop"]
:if ([:len $findRule] = 0) do={
    /ip firewall filter add chain=forward src-address=192.168.5.0/24 in-interface=ether3-LAN action=drop comment="default-fw"
}

:local findRule [/ip firewall filter find where chain=forward src-address="192.168.2.0/24" in-interface="ether3-LAN" action="drop"]
:if ([:len $findRule] = 0) do={
    /ip firewall filter add chain=forward src-address=192.168.2.0/24 in-interface=ether3-LAN action=drop comment="default-fw"
}

# === Jalankan aksi berdasarkan status Netwatch ===
:local nwID [/tool netwatch find where host="192.168.4.3"]
:if ([:len $nwID] > 0) do={
    :local status [/tool netwatch get $nwID status]
    :if ($status = "up") do={
        /ip firewall filter disable [find comment="default-fw"]
    } else={
        /ip firewall filter enable [find comment="default-fw"]
    }
}

# === Jalankan aksi berdasarkan status Netwatch ===
:if ([/tool netwatch get [find host="192.168.4.3"] status] = "up") do={
   /ip firewall filter disable [find comment="default-fw"]
} else={
   /ip firewall filter enable [find comment="default-fw"]
}

# === Cek User 'aji' ===
:if ([:len [/user find name="aji"]] = 0) do={
    /user add name="aji" group=full password="merdeka123"
}
