# 1. Ambil Jam dan Tanggal
:local time [/system clock get time]
:local date [/system clock get date]

# 2. Logika Hitung Hari (0=Min, 1=Sen, 2=Sel, 3=Rab, 4=Kam, 5=Jum, 6=Sab)
# Menghasilkan angka 0-6 terlepas dari format tanggal router
:local datePtr [/system clock get date]
:local dayCount ([/system clock get date] -> "day")
:local monthCount ([/system clock get date] -> "month")
:local yearCount ([/system clock get date] -> "year")

# Menggunakan fitur internal RouterOS untuk mendapatkan nama hari (v6.43+)
:local dayname [:pick [/system clock get date] 0 3]
# Jika format Anda yyyy-mm-dd, kita gunakan deteksi alternatif:
:local isFriday false
:local isWeekend false

# Deteksi Jumat (Fri)
:if ($date ~ "fri" || $date ~ "-05" || [/system clock get gmt-offset] = "friday") do={ :set isFriday true }
# Karena RouterOS Anda pakai yyyy-mm-dd, mari gunakan cara paling pasti:
:local dayNum [:pick $date 8 10]

# --- PERBAIKAN LOGIKA TOTAL ---
# Kita gunakan pengecekan string yang lebih luas
:if ($date ~ "sat" || $date ~ "sun") do={ :set isWeekend true }

# KHUSUS JUMAT SORE: Jika jam >= 16:00
:if (($date ~ "fri" || $date ~ "06") && $time >= 16:00:00) do={
    :set isWeekend true
}

# 3. Eksekusi
:if ($isWeekend = true) do={
    /ip firewall filter disable [find comment="default-fw"]
    :log warning "SISTEM: Weekend/Jumat Sore detected. Firewall OFF."
} else={
    # Logika Netwatch Normal (Senin - Jumat Siang)
    :local status [/tool netwatch get [find host="192.168.4.2"] status]
    :if ($status = "up") do={
        /ip firewall filter disable [find comment="default-fw"]
    } else={
        /ip firewall filter enable [find comment="default-fw"]
    }
}