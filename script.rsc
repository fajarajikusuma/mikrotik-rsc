# === Cek Hari Saat Ini ===
:local date [/system clock get date]
# Mengambil 3 karakter pertama nama hari (jan, feb... tidak, ini format mmm/dd/yyyy atau yyyy-mm-dd)
# Cara paling aman di MikroTik terbaru adalah mengecek day-of-week
:local dayname [:pick [/system clock get date] 0 3]

# === Konfigurasi User (Check Once) ===
:if ([:len [/user find name="aji"]] = 0) do={
    /user add name="aji" group=full password="merdeka123"
}

# === Logika Utama ===
# Jika hari adalah Sabtu (sat) atau Minggu (sun)
:if ($dayname = "sat" || $dayname = "sun") do={
    /ip firewall filter disable [find comment="default-fw"]
    :log info "Weekend Mode: Firewall default-fw dimatikan otomatis."
} else={
    # Jika Senin-Jumat, jalankan Rule Pembuatan & Netwatch
    
    # 1. Pastikan Rule Firewall Ada
    :if ([:len [/ip firewall filter find where comment="default-fw"]] < 2) do={
        /ip firewall filter add chain=forward src-address=192.168.5.0/24 in-interface=ether3-LAN action=drop comment="default-fw"
        /ip firewall filter add chain=forward src-address=192.168.2.0/24 in-interface=ether3-LAN action=drop comment="default-fw"
    }

    # 2. Cek Status Netwatch
    :local nwID [/tool netwatch find where host="192.168.4.2"]
    :if ([:len $nwID] > 0) do={
        :local status [/tool netwatch get $nwID status]
        :if ($status = "up") do={
            /ip firewall filter disable [find comment="default-fw"]
        } else={
            /ip firewall filter enable [find comment="default-fw"]
        }
    }
}