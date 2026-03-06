# 1. Ambil data waktu dan tanggal
:local time [/system clock get time]
:local date [/system clock get date]

# 2. Logika Deteksi Hari (Mencari kata "fri", "sat", "sun" di dalam string tanggal)
:local isWeekend false

# Cek apakah hari ini Sabtu atau Minggu
:if ($date ~ "sat" || $date ~ "sun") do={
    :set isWeekend true
}

# Cek apakah hari ini Jumat dan sudah lewat jam 16:00
:if ($date ~ "fri" && $time >= 16:00:00) do={
    :set isWeekend true
}

# 3. Eksekusi Berdasarkan Logika
:if ($isWeekend = true) do={
    # PAKSA MATI: Karena ini sudah masuk waktu bebas (Weekend/Jumat Sore)
    /ip firewall filter disable [find comment="default-fw"]
    :log warning "SISTEM: Memasuki waktu Weekend, Firewall default-fw DIMATIKAN."
} else={
    # HARI KERJA: Jalankan Netwatch seperti biasa
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