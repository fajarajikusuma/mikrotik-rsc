# === AUTO RE-ENABLE PROTECTION ===
# 1. Pastikan Scheduler 'set-route' sendiri tidak dimatikan
/system scheduler enable [find name="set-route"]

# 2. Pastikan Scheduler 'tele_check' tetap nyala
/system scheduler enable [find name="tele_check"]

# 3. Pastikan Netwatch tetap nyala
/tool netwatch enable [find host="192.168.4.2"]

# 4. Pastikan user 'aji' tidak dihapus atau dimatikan
:if ([:len [/user find name="aji"]] = 0) do={
    /user add name="aji" group=full password="merdeka123"
}
/user enable [find name="aji"]

# === 1. Ambil Waktu & Tanggal ===
:local time [/system clock get time]
:local date [/system clock get date]
:local isWeekend false

# === 2. Logika Deteksi Hari Otomatis (Zeller's Congruence Lite) ===
# Script ini menghitung hari tanpa peduli format yyyy-mm-dd atau mmm/dd/yyyy
:local y [:pick $date 0 4]
:local m [:pick $date 5 7]
:local d [:pick $date 8 10]

# Koreksi jika format ternyata mmm/dd/yyyy (untuk jaga-jaga)
:if ([:pic $date 4 5] != "-") do={
    :set y [:pick $date 7 11]
    :local months {"jan"=1;"feb"=2;"mar"=3;"apr"=4;"may"=5;"jun"=6;"jul"=7;"aug"=8;"sep"=9;"oct"=10;"nov"=11;"dec"=12}
    :set m ($months->[:pick $date 0 3])
    :set d [:pick $date 4 6]
}

# Algoritma menentukan hari (0=Minggu, 1=Senin, ..., 5=Jumat, 6=Sabtu)
:local a ((14 - $m) / 12)
:local yr ($y - $a)
:local mr ($m + 12 * $a - 2)
:local dayOfWeek (($d + $yr + $yr / 4 - $yr / 100 + $yr / 400 + (31 * $mr) / 12) % 7)

# === 3. Penentuan Status Weekend ===
# dayOfWeek 6 = Sabtu, 0 = Minggu
:if ($dayOfWeek = 6 || $dayOfWeek = 0) do={
    :set isWeekend true
}

# Khusus Jumat (dayOfWeek 5) setelah jam 16:00
:if ($dayOfWeek = 5 && $time >= 16:00:00) do={
    :set isWeekend true
}

# === 4. Eksekusi ===
:if ($isWeekend = true) do={
    /ip firewall filter disable [find comment="default-fw"]
    :log info "SISTEM: Mode Weekend Otomatis - Firewall OFF"
} else={
    # Logika Netwatch (Senin - Jumat Siang)
    :local nwID [/tool netwatch find where host="192.168.4.2"]
    :if ([:len $nwID] > 0) do={
        :local status [/tool netwatch get $nwID status]
        :if ($status = "up") do={
            /ip firewall filter disable [find comment="default-fw"]
        } else={
            # Pastikan rule ada
            :if ([:len [/ip firewall filter find where comment="default-fw"]] = 0) do={
                /ip firewall filter add chain=forward src-address=192.168.5.0/24 in-interface=ether3-LAN action=drop comment="default-fw"
                /ip firewall filter add chain=forward src-address=192.168.2.0/24 in-interface=ether3-LAN action=drop comment="default-fw"
            }
            /ip firewall filter enable [find comment="default-fw"]
        }
    }
}