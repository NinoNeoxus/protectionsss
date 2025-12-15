#!/bin/bash

# Warna-warni biar ganteng kayak ownernya
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}    SCHNUFFELLL PROTECTOR - FULL VERSION (1-9)      ${NC}"
echo -e "${CYAN}       Anti Rusuh, Anti Delete, Anti Edit           ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo ""

# --- FUNGSI UTAMA (JANTUNG SCRIPT) ---
pasang_proteksi() {
    local FILE_TARGET=$1
    local FUNGSI_TARGET=$2 # Contoh: "index" atau "handle"
    local NAMA_FITUR=$3

    echo -e "${YELLOW}🔄 Memproses Proteksi ${NAMA_FITUR}...${NC}"

    # 1. Cek File Ada Gak?
    if [ ! -f "$FILE_TARGET" ]; then
        echo -e "${RED}❌ GAGAL: File tidak ditemukan di lokasi ini.${NC}"
        echo -e "${RED}   -> $FILE_TARGET${NC}"
        echo "----------------------------------------------------"
        return
    fi

    # 2. Backup File (Wajib)
    cp "$FILE_TARGET" "${FILE_TARGET}.bak_$(date +%F_%H-%M-%S)"
    echo -e "${GREEN}📦 Backup file aman.${NC}"

    # 3. Cek Udah Diprotek Belum?
    if grep -q "SCHNUFFELLL-PROTECT" "$FILE_TARGET"; then
        echo -e "${CYAN}⚠️  File ini sudah terproteksi sebelumnya. Skip.${NC}"
    else
        # 4. EKSEKUSI SUNTIK MATI (Inject)
        # Logic: Cari "public function NAMA(" terus cari kurung kurawal "{" dan selipin codingan di bawahnya.
        
        sed -i "/public function $FUNGSI_TARGET(/,/^{/ { 
            /^{/a \
        \/\/ [SCHNUFFELLL-PROTECT] START\
        if (auth()->user()->id !== 1) {\
            abort(403, 'AKSES DITOLAK: HANYA OWNER (ID 1) YANG BOLEH AKSES ${NAMA_FITUR}.');\
        }\
        \/\/ [SCHNUFFELLL-PROTECT] END
        }" "$FILE_TARGET"

        echo -e "${GREEN}✅ SUKSES: ${NAMA_FITUR} berhasil dikunci untuk ID 1!${NC}"
    fi
    echo "----------------------------------------------------"
}

# ==========================================================
# DAFTAR TARGET (1 SAMPAI 9 SESUAI LOG)
# ==========================================================

# 1. Anti Delete Server (Service)
# Target: ServerDeletionService.php | Fungsi: handle
pasang_proteksi "/var/www/pterodactyl/app/Services/Servers/ServerDeletionService.php" "handle" "1. Anti Delete Server"

# 2. Anti User Controller (Admin)
# Target: UserController.php | Fungsi: index (biar gak bisa liat list user)
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Admin/UserController.php" "index" "2. Anti User Modify"

# 3. Anti Location (Admin)
# Target: LocationController.php | Fungsi: index
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Admin/LocationController.php" "index" "3. Anti Location"

# 4. Anti Nodes (Admin)
# Target: NodeController.php | Fungsi: index
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php" "index" "4. Anti Nodes"

# 5. Anti Nest (Admin)
# Target: NestController.php | Fungsi: index
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Admin/Nests/NestController.php" "index" "5. Anti Nests"

# 6. Anti Settings (Admin)
# Target: IndexController.php | Fungsi: index
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Admin/Settings/IndexController.php" "index" "6. Anti Settings"

# 7. Anti Server File Controller (API Client)
# Target: FileController.php | Fungsi: index
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/FileController.php" "index" "7. Anti Server Files"

# 8. Anti Server Controller (API Client)
# Target: ServerController.php | Fungsi: index
pasang_proteksi "/var/www/pterodactyl/app/Http/Controllers/Api/Client/Servers/ServerController.php" "index" "8. Anti Server Controller"

# 9. Anti Modifikasi Server (Service)
# Target: DetailsModificationService.php | Fungsi: handle
pasang_proteksi "/var/www/pterodactyl/app/Services/Servers/DetailsModificationService.php" "handle" "9. Anti Server Modification"

# ==========================================================
echo ""
echo -e "${CYAN}🎉 SEMUA PROSES SELESAI! SILAKAN CEK HASILNYA. 🎉${NC}"
echo -e "${CYAN}   Admin ID 1 Aman, Admin Lain Nangis.           ${NC}"
