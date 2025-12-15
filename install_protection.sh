#!/bin/bash

# Warna-warni
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}    SCHNUFFELLL PROTECTOR - V3 (FIX INDENTASI)      ${NC}"
echo -e "${CYAN}       Sekarang pasti nempel di sela-sela spasi     ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo ""

# --- FUNGSI UTAMA (UPDATED REGEX) ---
pasang_proteksi() {
    local FILE_TARGET=$1
    local FUNGSI_TARGET=$2 
    local NAMA_FITUR=$3

    echo -e "${YELLOW}🔄 Memproses Proteksi ${NAMA_FITUR}...${NC}"

    if [ ! -f "$FILE_TARGET" ]; then
        echo -e "${RED}❌ GAGAL: File tidak ditemukan: $FILE_TARGET${NC}"
        return
    fi

    # Cek Udah Diprotek Belum?
    if grep -q "SCHNUFFELLL-PROTECT" "$FILE_TARGET"; then
        echo -e "${CYAN}⚠️  File ini sudah terproteksi. Skip.${NC}"
    else
        # --- LOGIC BARU (BACA SPASI) ---
        # Menggunakan regex '^[[:space:]]*{' untuk menangkap kurung kurawal yang menjorok
        
        sed -i "/public function $FUNGSI_TARGET/,/^[[:space:]]*{/ { 
            /^[[:space:]]*{/a \\
        \\\\t\\\\t\/\/ [SCHNUFFELLL-PROTECT] START\\
        \\\\t\\\\tif (auth()->user()->id !== 1) {\\
        \\\\t\\\\t\\\\tabort(403, 'AKSES DITOLAK: HANYA OWNER (ID 1) YANG BOLEH AKSES ${NAMA_FITUR}.');\\
        \\\\t\\\\t}\\
        \\\\t\\\\t\/\/ [SCHNUFFELLL-PROTECT] END
        }" "$FILE_TARGET"

        echo -e "${GREEN}✅ SUKSES: Codingan berhasil disuntik ke $NAMA_FITUR!${NC}"
    fi
    echo "----------------------------------------------------"
}

# ==========================================================
# DAFTAR TARGET
# ==========================================================

# 1. Anti Delete Server
pasang_proteksi "/var/www/pterodactyl/app/Services/Servers/ServerDeletionService.php" "handle" "1. Anti Delete Server"

# 2. Anti User Modify
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Admin/UserController.php" "index" "2. Anti User Modify"

# 3. Anti Location
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Admin/LocationController.php" "index" "3. Anti Location"

# 4. Anti Nodes
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php" "index" "4. Anti Nodes"

# 5. Anti Nests
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Admin/Nests/NestController.php" "index" "5. Anti Nests"

# 6. Anti Settings
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Admin/Settings/IndexController.php" "index" "6. Anti Settings"

# 7. Anti Server Files (API)
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/FileController.php" "index" "7. Anti Server Files"

# 8. Anti Server Controller (API)
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/ServerController.php" "index" "8. Anti Server Controller"

# 9. Anti Server Modification
pasang_proteksi "/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php" "handle" "9. Anti Server Modification"

# ==========================================================
# BERSIHIN CACHE (PENTING BIAR UPDATE)
echo -e "${YELLOW}🧹 Membersihkan Cache Panel...${NC}"
cd /var/www/pterodactyl
php artisan view:clear
php artisan config:clear
php artisan route:clear

echo ""
echo -e "${CYAN}🎉 SELESAI! SILAKAN CEK DI AKUN TUMBAL. 🎉${NC}"
