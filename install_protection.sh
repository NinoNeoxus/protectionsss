#!/bin/bash

# --- SCHNUFFELLL ULTIMATE PROTECTION (9-in-1) ---
# Script ini menggabungkan 9 layer keamanan untuk Pterodactyl Panel.
# Semua proteksi akan dipasang sekaligus.
# Target: Hanya ADMIN (ID 1) yang bebas akses.

PTERO_DIR="/var/www/pterodactyl"
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
ADMIN_ID=1

echo "================================================="
echo "   MEMASANG 9 LAYER PROTEKSI SCHNUFFELLL..."
echo "================================================="

# Helper function buat inject
inject_protection() {
    local file=$1
    local search=$2
    local message=$3
    
    if [ -f "$file" ]; then
        echo "[INFO] Memasang proteksi di $(basename $file)..."
        cp "$file" "${file}.bak_$TIMESTAMP"
        
        # Cek apakah sudah terpasang buat hindari duplikat
        if grep -q "PROTEKSI CUSTOM" "$file"; then
             echo "   -> Proteksi sudah ada. Skip."
        else
             sed -i "/$search/a \\
        // --- PROTEKSI CUSTOM ---\\
        if (request()->user()->id !== $ADMIN_ID && \$request->user()->id !== $ADMIN_ID) {\\
            throw new \\\\Symfony\\\\Component\\\\HttpKernel\\\\Exception\\\\HttpException(403, '$message');\\
        }\\
        // -----------------------" "$file"
             echo "   -> Berhasil dipasang."
        fi
    else
        echo "[SKIP] File $(basename $file) tidak ditemukan."
    fi
}

inject_service_protection() {
    local file=$1
    local search=$2
    local message=$3
    
    if [ -f "$file" ]; then
        echo "[INFO] Memasang proteksi Service di $(basename $file)..."
        cp "$file" "${file}.bak_$TIMESTAMP"
        if grep -q "PROTEKSI CUSTOM" "$file"; then
             echo "   -> Proteksi sudah ada. Skip."
        else
             sed -i "/$search/a \\
        // --- PROTEKSI CUSTOM ---\\
        if (auth()->user()->id !== $ADMIN_ID) {\\
            throw new \\\\Pterodactyl\\\\Exceptions\\\\DisplayException('$message');\\
        }\\
        // -----------------------" "$file"
             echo "   -> Berhasil dipasang."
        fi
    else
        echo "[SKIP] File $(basename $file) tidak ditemukan."
    fi
}

# 1. Server Controller (List Server)
inject_protection "$PTERO_DIR/app/Http/Controllers/Api/Client/Servers/ServerController.php" "public function index" "AKSES DITOLAK! Server List Private."

# 2. Server Detail Service (Edit/View Details)
inject_service_protection "$PTERO_DIR/app/Services/Servers/DetailsModificationService.php" "public function handle" "DILARANG EDIT DETAIL SERVER!"

# 3. Startup Modification (Edit Startup Cmd/Image)
inject_service_protection "$PTERO_DIR/app/Services/Servers/StartupModificationService.php" "public function handle" "DILARANG EDIT STARTUP!"

# 4. Database Controller (Create/Delete Database)
inject_protection "$PTERO_DIR/app/Http/Controllers/Api/Client/Servers/DatabaseController.php" "public function index" "AKSES DATABASE DIBATASI!"

# 5. Network/Allocation Controller (Create/Delete Ports)
inject_protection "$PTERO_DIR/app/Http/Controllers/Api/Client/Servers/NetworkController.php" "public function index" "AKSES NETWORK DIBATASI!"

# 6. File Manager Controller (List Files)
# Hati-hati, ini bisa bikin user ga bisa manage file sendiri. Enable sbg opsi keras.
inject_protection "$PTERO_DIR/app/Http/Controllers/Api/Client/Servers/FileController.php" "public function index" "FILE MANAGER DIKUNCI!"

# 7. Schedule Controller (Jadwal Tugas)
inject_protection "$PTERO_DIR/app/Http/Controllers/Api/Client/Servers/ScheduleController.php" "public function index" "SCHEDULE DIKUNCI!"

# 8. Subuser Controller (Tambah Teman)
inject_protection "$PTERO_DIR/app/Http/Controllers/Api/Client/Servers/SubuserController.php" "public function index" "SUBUSER DIKUNCI!"

# 9. Settings/Activity Log (View Logs)
inject_protection "$PTERO_DIR/app/Http/Controllers/Api/Client/Servers/ActivityLogController.php" "public function index" "ACTIVITY LOG PRIVATE!"

echo ""
echo "================================================="
echo "   9 LAYER PROTEKSI SELESAI DIPASANG!"
echo "   Jalankan: php artisan optimize"
echo "================================================="
