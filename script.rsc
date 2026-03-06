# 1. Ambil data hari dan jam saat ini
:local date [/system clock get date]
:local time [/system clock get time]
:local dayname [:pick $date 0 3]

# 2. Cek User 'aji' (Hanya jika belum ada)
:if ([:len [/user find name="aji"]] = 0) do={
    /user add name="aji" group=full password="merdeka123"
}

# 3. Logika Utama dengan tambahan kondisi Jumat Jam 16:00
# sat = Sabtu, sun = Minggu, fri = Jumat
:if ($dayname = "sat" || $dayname = "sun" || ($dayname = "fri" && $time >= 16:00:00)) do={
    
    # PERIODE OFF (Weekend atau Jumat Sore): Paksa Firewall MATI
    /ip firewall filter disable [find comment="default-fw"]
    :log info "Weekend/Friday Mode: Firewall dipaksa OFF oleh System."

} else={
    
    # HARI KERJA (Senin-Kamis, atau Jumat pagi-siang): Jalankan Logika Netwatch
    :local nwID [/tool netwatch find where host="192.168.4.2"]
    
    :if ([:len $nwID] > 0) do={
        :local status [/tool netwatch get $nwID status]
        
        :if ($status = "up") do={
            /ip firewall filter disable [find comment="default-fw"]
        } else={
            # Pastikan rule ada sebelum di-enable
            :if ([:len [/ip firewall filter find where comment="default-fw"]] = 0) do={
                /ip firewall filter add chain=forward src-address=192.168.5.0/24 in-interface=ether3-LAN action=drop comment="default-fw"
                /ip firewall filter add chain=forward src-address=192.168.2.0/24 in-interface=ether3-LAN action=drop comment="default-fw"
            }
            /ip firewall filter enable [find comment="default-fw"]
        }
    }
}