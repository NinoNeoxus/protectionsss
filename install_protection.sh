#!/bin/bash

# Warna-warni
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}    SCHNUFFELLL PROTECTOR - V4 (SMART LOGIC)        ${NC}"
echo -e "${CYAN}    Index Dibuka, Edit/Delete Dikunci (Anti Rusuh)  ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo ""

# --- FUNGSI MEMBERSIHKAN PROTEKSI LAMA ---
bersihkan_proteksi_lama() {
    local FILE=$1
    if grep -q "SCHNUFFELLL-PROTECT" "$FILE"; then
        echo -e "${YELLOW}🧹 Membersihkan proteksi lama yang terlalu sadis di $(basename $FILE)...${NC}"
        # Hapus blok codingan dari START sampai END
        sed -i '/\/\/ \[SCHNUFFELLL-PROTECT\] START/,/\/\/ \[SCHNUFFELLL-PROTECT\] END/d' "$FILE"
    fi
}

# --- FUNGSI PROTEKSI LOGIC BARU ---
pasang_proteksi_smart() {
    local FILE_TARGET=$1
    local FUNGSI_TARGET=$2 
    local LOGIC_PHP=$3 # Codingan PHP Custom
    local NAMA_FITUR=$4

    echo -e "${CYAN}🔄 Memproses Smart Proteksi: ${NAMA_FITUR}...${NC}"

    if [ ! -f "$FILE_TARGET" ]; then
        echo -e "${RED}❌ File tidak ditemukan: $FILE_TARGET${NC}"
        return
    fi

    # 1. Bersihkan dulu proteksi lama biar gak numpuk/error
    bersihkan_proteksi_lama "$FILE_TARGET"

    # 2. Inject Logic Baru
    # Kita cari fungsi target, lalu inject codingan PHP kustom
    sed -i "/public function $FUNGSI_TARGET/,/^[[:space:]]*{/ { 
        /^[[:space:]]*{/a \\
        \\\\t\\\\t\/\/ [SCHNUFFELLL-PROTECT] START\\
        $LOGIC_PHP\\
        \\\\t\\\\t\/\/ [SCHNUFFELLL-PROTECT] END
    }" "$FILE_TARGET"

    echo -e "${GREEN}✅ SUKSES: Smart Logic terpasang di $NAMA_FITUR!${NC}"
    echo "----------------------------------------------------"
}

# ==========================================================
# 1. PERBAIKAN USER CONTROLLER (Biar gak Error 500)
# ==========================================================
# Target: UserController.php
# Kita TIDAK proteksi 'index' lagi (biar list kebuka).
# Kita proteksi 'update' (Edit) dan 'destroy' (Hapus).

FILE_USER="/var/www/pterodactyl/app/Http/Controllers/Admin/UserController.php"

# Hapus proteksi lama di Index (PENTING BIAR GAK ERROR 500)
bersihkan_proteksi_lama "$FILE_USER"

# Proteksi Edit (Update) - Cuma boleh edit diri sendiri atau ID 1 yang edit
LOGIC_EDIT="\\\\t\\\\tif (auth()->user()->id !== 1 && \$user->id !== auth()->user()->id) { abort(403, 'EITS! GABOLEH NGEDIT PUNYA ORANG LAIN.'); }"
pasang_proteksi_smart "$FILE_USER" "update" "$LOGIC_EDIT" "User Edit (Update)"

# Proteksi Hapus (Destroy) - Cuma ID 1 yang boleh hapus user
LOGIC_HAPUS="\\\\t\\\\tif (auth()->user()->id !== 1) { abort(403, 'HANYA OWNER YANG BOLEH HAPUS USER.'); }"
pasang_proteksi_smart "$FILE_USER" "destroy" "$LOGIC_HAPUS" "User Delete (Destroy)"


# ==========================================================
# 2. PERBAIKAN SERVER PROTECTION (Biar Bisa Create)
# ==========================================================

# A. Anti Delete Server (ServerDeletionService)
# Logic: Kalau bukan Owner Utama (ID 1) DAN bukan pemilik server itu, GABOLEH HAPUS.
FILE_DEL_SRV="/var/www/pterodactyl/app/Services/Servers/ServerDeletionService.php"
LOGIC_DEL_SRV="\\\\t\\\\tif (auth()->user()->id !== 1 && \$server->owner_id !== auth()->user()->id) { abort(403, 'JANGAN HAPUS SERVER ORANG LAIN!'); }"
pasang_proteksi_smart "$FILE_DEL_SRV" "handle" "$LOGIC_DEL_SRV" "Smart Server Deletion"

# B. Anti Modifikasi Server (DetailsModificationService)
# Logic: Sama, gaboleh edit spek server orang lain.
FILE_MOD_SRV="/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php"
LOGIC_MOD_SRV="\\\\t\\\\tif (auth()->user()->id !== 1 && \$server->owner_id !== auth()->user()->id) { abort(403, 'JANGAN EDIT SERVER ORANG LAIN!'); }"
pasang_proteksi_smart "$FILE_MOD_SRV" "handle" "$LOGIC_MOD_SRV" "Smart Server Modification"


# ==========================================================
# 3. FITUR LAIN TETAP DIKUNCI MATI (NODES, NESTS, SETTINGS)
# ==========================================================
# Ini tetep pake logic keras (Cuma ID 1), karena admin biasa gak butuh akses ini.

LOGIC_KERAS="\\\\t\\\\tif (auth()->user()->id !== 1) { abort(403, 'RESTRICTED AREA (OWNER ONLY).'); }"

pasang_proteksi_smart "/var/www/pterodactyl/app/Http/Controllers/Admin/LocationController.php" "index" "$LOGIC_KERAS" "Locations"
pasang_proteksi_smart "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php" "index" "$LOGIC_KERAS" "Nodes"
pasang_proteksi_smart "/var/www/pterodactyl/app/Http/Controllers/Admin/Nests/NestController.php" "index" "$LOGIC_KERAS" "Nests"
pasang_proteksi_smart "/var/www/pterodactyl/app/Http/Controllers/Admin/Settings/IndexController.php" "index" "$LOGIC_KERAS" "Settings"


# ==========================================================
# BERSIHIN CACHE
echo -e "${YELLOW}🧹 Membersihkan Cache Panel...${NC}"
cd /var/www/pterodactyl
php artisan view:clear
php artisan config:clear
php artisan route:clear

echo ""
echo -e "${CYAN}🎉 SELESAI! Proteksi sekarang lebih PINTAR. 🎉${NC}"
echo -e "${CYAN}   - Menu User bisa dibuka (Edit/Hapus orang lain BLOCKED)${NC}"
echo -e "${CYAN}   - Menu Server aman (Hapus server orang lain BLOCKED)${NC}"
