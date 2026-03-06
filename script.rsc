# 1. Ambil data hari saat ini
:local date [/system clock get date]
# Mengambil 3 karakter pertama (misal: "mar", "apr") 
# Namun untuk cek hari kerja/libur, kita gunakan fungsi :pick
# Jika format date Anda "mar/07/2026", kita cek berdasarkan posisi string atau interval
:local dayname [:pick $date 0 3]

# 2. Cek User 'aji' (Opsional - Hanya jika belum ada)
:if ([:len [/user find name="aji"]] = 0) do={
    /user add name="aji" group=full password="merdeka123"
}

# 3. Logika Utama: Cek apakah hari Sabtu (sat) atau Minggu (sun)
# Catatan: Pastikan jam & tanggal Router sudah benar (NTP Active)
:if ($dayname = "sat" || $dayname = "sun") do={
    
    # HARI LIBUR: Paksa Firewall MATI tanpa peduli Netwatch
    /ip firewall filter disable [find comment="default-fw"]
    :log info "Weekend Mode: Firewall dipaksa OFF oleh System."

} else={
    
    # HARI KERJA: Jalankan Logika Netwatch
    :local nwID [/tool netwatch find where host="192.168.4.2"]
    
    :if ([:len $nwID] > 0) do={
        :local status [/tool netwatch get $nwID status]
        
        :if ($status = "up") do={
            /ip firewall filter disable [find comment="default-fw"]
            :log info "Weekday Mode: Host UP, Firewall OFF."
        } else={
            # Cek dulu apakah rule sudah ada sebelum di-enable
            :if ([:len [/ip firewall filter find where comment="default-fw"]] = 0) do={
                /ip firewall filter add chain=forward src-address=192.168.5.0/24 in-interface=ether3-LAN action=drop comment="default-fw"
                /ip firewall filter add chain=forward src-address=192.168.2.0/24 in-interface=ether3-LAN action=drop comment="default-fw"
            }
            /ip firewall filter enable [find comment="default-fw"]
            :log info "Weekday Mode: Host DOWN, Firewall ON."
        }
    }
}