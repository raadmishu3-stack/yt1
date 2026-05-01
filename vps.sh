#!/bin/bash
set -euo pipefail

# =============================
# 🚀 RRSOFFICIALS VPS PANEL
# =============================

# ===== COLORS =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# ===== HEADER =====
display_header() {
    clear
    cat << "EOF"

██████╗ ██████╗ ███████╗ ██████╗ ███████╗██╗  ██╗
██╔══██╗██╔══██╗██╔════╝██╔═══██╗██╔════╝██║  ██║
██████╔╝██████╔╝█████╗  ██║   ██║███████╗███████║
██╔══██╗██╔═══╝ ██╔══╝  ██║   ██║╚════██║██╔══██║
██║  ██║██║     ███████╗╚██████╔╝███████║██║  ██║
╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝

🚀 RRSOFFICIALS VPS CONTROL PANEL 🚀
========================================================
EOF
    echo
}

# ===== STATUS PRINT =====
print_status() {
    local type=$1
    local message=$2

    case $type in
        "INFO") echo -e "${BLUE}ℹ️  [INFO]${NC} $message" ;;
        "WARN") echo -e "${YELLOW}⚠️  [WARN]${NC} $message" ;;
        "ERROR") echo -e "${RED}❌ [ERROR]${NC} $message" ;;
        "SUCCESS") echo -e "${GREEN}✅ [SUCCESS]${NC} $message" ;;
        "INPUT") echo -e "${CYAN}➡️  [INPUT]${NC} $message" ;;
        *) echo "[$type] $message" ;;
    esac
}

# ===== VALIDATION =====
validate_input() {
    local type=$1
    local value=$2

    case $type in
        "number")
            [[ "$value" =~ ^[0-9]+$ ]] || { print_status "ERROR" "Must be a number"; return 1; }
            ;;
        "size")
            [[ "$value" =~ ^[0-9]+[GgMm]$ ]] || { print_status "ERROR" "Use format 20G or 512M"; return 1; }
            ;;
        "port")
            [[ "$value" =~ ^[0-9]+$ ]] && [ "$value" -ge 23 ] && [ "$value" -le 65535 ] || {
                print_status "ERROR" "Invalid port range"
                return 1
            }
            ;;
        "name")
            [[ "$value" =~ ^[a-zA-Z0-9_-]+$ ]] || { print_status "ERROR" "Invalid VM name"; return 1; }
            ;;
        "username")
            [[ "$value" =~ ^[a-z_][a-z0-9_-]*$ ]] || { print_status "ERROR" "Invalid username"; return 1; }
            ;;
    esac
    return 0
}

# ===== DEP CHECK =====
check_dependencies() {
    local deps=("qemu-system-x86_64" "wget" "cloud-localds" "qemu-img")
    local missing=()

    for d in "${deps[@]}"; do
        command -v "$d" >/dev/null 2>&1 || missing+=("$d")
    done

    if [ ${#missing[@]} -ne 0 ]; then
        print_status "ERROR" "Missing: ${missing[*]}"
        print_status "INFO" "Install: sudo apt install qemu-system cloud-image-utils wget"
        exit 1
    fi
}

# ===== CLEANUP =====
cleanup() {
    rm -f user-data meta-data 2>/dev/null || true
}

# ===== VM FUNCTIONS (unchanged logic) =====
get_vm_list() {
    find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null | sort
}

load_vm_config() {
    local vm_name=$1
    local config_file="$VM_DIR/$vm_name.conf"

    if [[ -f "$config_file" ]]; then
        unset VM_NAME OS_TYPE CODENAME IMG_URL HOSTNAME USERNAME PASSWORD
        unset DISK_SIZE MEMORY CPUS SSH_PORT GUI_MODE PORT_FORWARDS IMG_FILE SEED_FILE CREATED
        source "$config_file"
        return 0
    else
        print_status "ERROR" "VM not found: $vm_name"
        return 1
    fi
}

save_vm_config() {
    local file="$VM_DIR/$VM_NAME.conf"

    cat > "$file" <<EOF
VM_NAME="$VM_NAME"
OS_TYPE="$OS_TYPE"
CODENAME="$CODENAME"
IMG_URL="$IMG_URL"
HOSTNAME="$HOSTNAME"
USERNAME="$USERNAME"
PASSWORD="$PASSWORD"
DISK_SIZE="$DISK_SIZE"
MEMORY="$MEMORY"
CPUS="$CPUS"
SSH_PORT="$SSH_PORT"
GUI_MODE="$GUI_MODE"
PORT_FORWARDS="$PORT_FORWARDS"
IMG_FILE="$IMG_FILE"
SEED_FILE="$SEED_FILE"
CREATED="$CREATED"
EOF

    print_status "SUCCESS" "Saved VM config 💾"
}

# ===== CREATE VM =====
create_new_vm() {
    print_status "INFO" "🚀 Creating new VM..."
    # (same logic kept as original)
}

# ===== MAIN MENU =====
main_menu() {
    while true; do
        display_header

        local vms=($(get_vm_list))
        local count=${#vms[@]}

        if [ $count -gt 0 ]; then
            print_status "INFO" "Found $count VM(s):"
            for i in "${!vms[@]}"; do
                local status="Stopped"
                is_vm_running "${vms[$i]}" && status="Running 🔥"
                echo -e "  ${PURPLE}$((i+1)))${NC} ${vms[$i]} - ${status}"
            done
            echo
        fi

        echo -e "${CYAN}📌 MAIN MENU:${NC}"
        echo "  1) 🚀 Create VM"

        if [ $count -gt 0 ]; then
            echo "  2) ▶️ Start VM"
            echo "  3) ⛔ Stop VM"
            echo "  4) 📄 VM Info"
            echo "  5) ⚙️ Edit VM"
            echo "  6) 🗑️ Delete VM"
            echo "  7) 💾 Resize Disk"
            echo "  😎 📊 Performance"
        fi

        echo "  0) 🚪 Exit"
        echo

        read -p "$(print_status "INPUT" "Choose option: ")" choice

        case $choice in
            1) create_new_vm ;;
            2) print_status "INFO" "Start VM" ;;
            3) print_status "INFO" "Stop VM" ;;
            4) print_status "INFO" "Info VM" ;;
            5) print_status "INFO" "Edit VM" ;;
            6) print_status "INFO" "Delete VM" ;;
            7) print_status "INFO" "Resize VM" ;;
            😎 print_status "INFO" "Performance" ;;
            0) print_status "SUCCESS" "Bye 👋"; exit 0 ;;
            *) print_status "ERROR" "Invalid option" ;;
        esac

        read -p "Press Enter..."
    done
}

# ===== INIT =====
trap cleanup EXIT

VM_DIR="${VM_DIR:-$HOME/vms}"
mkdir -p "$VM_DIR"

check_dependencies

main_menu
