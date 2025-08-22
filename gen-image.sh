#!/usr/bin/env bash
set -euo pipefail

# gen-image.sh - Enhanced pi-gen build script for Distiller platform
# Features: Random hostname generation, build management, logging, and more

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Default values
BASE_CONFIG="config-distiller-prod"
BUILD_METHOD="native"  # native or docker
HOSTNAME_PREFIX="distiller"
RANDOM_SUFFIX=""
CLEAN_BUILD=0
CONTINUE_BUILD=0
SKIP_IMAGES=0
SKIP_STAGES=""
COMPRESSION="xz"
CHECK_DEPS=1
VERBOSE=0
DEV_MODE=0
ARCHIVE_BUILD=1
BUILD_LOG_DIR="${DIR}/build-logs"
CUSTOM_HOSTNAME=""
PRESERVE_CONTAINER=0
PARALLEL_JOBS=$(nproc)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to generate random suffix
generate_random_suffix() {
    local length=${1:-4}
    local chars='abcdefghijklmnopqrstuvwxyz0123456789'
    local suffix=""
    
    # Try using /dev/urandom first
    if [[ -r /dev/urandom ]]; then
        suffix=$(tr -dc "${chars}" < /dev/urandom | head -c "${length}")
    else
        # Fallback to $RANDOM
        for ((i=0; i<length; i++)); do
            suffix="${suffix}${chars:RANDOM%${#chars}:1}"
        done
    fi
    
    echo "${suffix}"
}

# Function to check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    # Map of commands to check and their package names
    local -A deps_commands=(
        ["debootstrap"]="debootstrap"
        ["qemu-aarch64-static"]="qemu-user-static"
        ["parted"]="parted"
        ["zerofree"]="zerofree"
        ["zip"]="zip"
        ["mkfs.vfat"]="dosfstools"
        ["bsdtar"]="libarchive-tools"
        ["capsh"]="libcap2-bin"
        ["rsync"]="rsync"
        ["xz"]="xz-utils"
        ["file"]="file"
        ["git"]="git"
        ["curl"]="curl"
        ["bc"]="bc"
        ["gpg"]="gpg"
        ["pigz"]="pigz"
        ["xxd"]="xxd"
        ["bmaptool"]="bmap-tools"
    )
    
    # Additional packages that don't have simple command checks
    local deps_packages=(
        "quilt"
        "grep"
        "coreutils"
    )
    
    local missing_deps=()
    
    if [[ "${BUILD_METHOD}" == "native" ]]; then
        # Check commands
        for cmd in "${!deps_commands[@]}"; do
            if ! command -v "${cmd}" &> /dev/null; then
                missing_deps+=("${deps_commands[$cmd]}")
            fi
        done
        
        # Check packages that don't have simple commands
        for pkg in "${deps_packages[@]}"; do
            # Use dpkg-query for more reliable package checking
            if ! dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q "ok installed"; then
                # Skip coreutils and grep as they're always present in Linux
                if [[ "${pkg}" != "coreutils" ]] && [[ "${pkg}" != "grep" ]]; then
                    missing_deps+=("${pkg}")
                fi
            fi
        done
        
        # arch-test is optional but recommended
        if ! command -v arch-test &> /dev/null; then
            print_warning "Optional: arch-test not found (used for architecture detection)"
        fi
        
        if [[ ${#missing_deps[@]} -gt 0 ]]; then
            print_error "Missing dependencies: ${missing_deps[*]}"
            print_info "Install with: sudo apt-get install ${missing_deps[*]}"
            return 1
        fi
    else
        # Check for Docker
        if ! command -v docker &> /dev/null; then
            print_error "Docker is not installed"
            return 1
        fi
        
        # Check Docker daemon
        if ! docker ps &> /dev/null; then
            if ! sudo docker ps &> /dev/null; then
                print_error "Docker daemon is not running"
                return 1
            fi
        fi
    fi
    
    print_status "All dependencies satisfied"
    return 0
}

# Function to create temporary config with modified hostname
create_temp_config() {
    local base_config="$1"
    local hostname="$2"
    local temp_config="${DIR}/.config-temp-$$"
    
    if [[ ! -f "${base_config}" ]]; then
        print_error "Base config file not found: ${base_config}"
        return 1
    fi
    
    # Copy base config and modify hostname
    cp "${base_config}" "${temp_config}"
    
    # Update hostname in temp config
    if grep -q "^TARGET_HOSTNAME=" "${temp_config}"; then
        sed -i "s/^TARGET_HOSTNAME=.*/TARGET_HOSTNAME='${hostname}'/" "${temp_config}"
    else
        echo "TARGET_HOSTNAME='${hostname}'" >> "${temp_config}"
    fi
    
    # Update image name to include hostname suffix
    if grep -q "^IMG_NAME=" "${temp_config}"; then
        local base_img_name=$(grep "^IMG_NAME=" "${base_config}" | cut -d"'" -f2)
        sed -i "s/^IMG_NAME=.*/IMG_NAME='${base_img_name}-${hostname##*-}'/" "${temp_config}"
    fi
    
    echo "${temp_config}"
}

# Function to archive successful build
archive_build() {
    local hostname="$1"
    local timestamp=$(date '+%Y%m%d-%H%M%S')
    local archive_dir="${DIR}/archives/${timestamp}-${hostname}"
    
    if [[ ! -d "${DIR}/deploy" ]]; then
        print_warning "No deploy directory found, skipping archive"
        return 0
    fi
    
    print_status "Archiving build to ${archive_dir}"
    mkdir -p "${archive_dir}"
    
    # Copy image files
    cp -r "${DIR}/deploy/"* "${archive_dir}/" 2>/dev/null || true
    
    # Save build metadata
    cat > "${archive_dir}/build-info.txt" <<EOF
Build Date: $(date)
Hostname: ${hostname}
Config: ${BASE_CONFIG}
Build Method: ${BUILD_METHOD}
Compression: ${COMPRESSION}
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "unknown")
EOF
    
    print_status "Build archived successfully"
}

# Function to cleanup temporary files
cleanup() {
    print_status "Cleaning up temporary files..."
    rm -f "${DIR}"/.config-temp-*
    
    if [[ ${PRESERVE_CONTAINER} -eq 0 ]] && [[ "${BUILD_METHOD}" == "docker" ]]; then
        # Clean up Docker containers if not preserving
        docker rm -f pigen_work 2>/dev/null || true
    fi
}

# Function to run the build
run_build() {
    local config_file="$1"
    local build_cmd=""
    local build_opts=""
    
    # Prepare build options
    if [[ ${CLEAN_BUILD} -eq 1 ]]; then
        export CLEAN=1
        build_opts="${build_opts} CLEAN=1"
    fi
    
    if [[ ${CONTINUE_BUILD} -eq 1 ]]; then
        export CONTINUE=1
        build_opts="${build_opts} CONTINUE=1"
    fi
    
    if [[ ${SKIP_IMAGES} -eq 1 ]]; then
        export SKIP_IMAGES=1
        build_opts="${build_opts} SKIP_IMAGES=1"
    fi
    
    if [[ -n "${SKIP_STAGES}" ]]; then
        export SKIP_STAGES="${SKIP_STAGES}"
        build_opts="${build_opts} SKIP_STAGES='${SKIP_STAGES}'"
    fi
    
    if [[ ${PRESERVE_CONTAINER} -eq 1 ]]; then
        export PRESERVE_CONTAINER=1
        build_opts="${build_opts} PRESERVE_CONTAINER=1"
    fi
    
    # Set compression
    export DEPLOY_COMPRESSION="${COMPRESSION}"
    
    # Create build log directory
    mkdir -p "${BUILD_LOG_DIR}"
    local log_file="${BUILD_LOG_DIR}/build-$(date '+%Y%m%d-%H%M%S').log"
    
    print_status "Starting build with config: ${config_file}"
    print_status "Build log: ${log_file}"
    
    if [[ "${BUILD_METHOD}" == "docker" ]]; then
        print_status "Using Docker build method"
        build_cmd="${DIR}/build-docker.sh -c ${config_file}"
    else
        print_status "Using native build method"
        # Check if we can sudo without password or if we're already root
        if [[ $EUID -eq 0 ]]; then
            # Already root
            build_cmd="${DIR}/build.sh -c ${config_file}"
        elif sudo -n true 2>/dev/null; then
            # Can sudo without password
            build_cmd="sudo ${DIR}/build.sh -c ${config_file}"
        else
            # Need password for sudo
            print_warning "This build requires sudo privileges"
            print_info "You may be prompted for your password"
            build_cmd="sudo ${DIR}/build.sh -c ${config_file}"
        fi
    fi
    
    # Export log file variable for error messages
    export BUILD_LOG_FILE="${log_file}"
    
    # Run the build
    if [[ ${VERBOSE} -eq 1 ]]; then
        eval "${build_opts} ${build_cmd}" 2>&1 | tee "${log_file}"
    else
        eval "${build_opts} ${build_cmd}" &> "${log_file}"
    fi
    
    return ${PIPESTATUS[0]}
}

# Function to show usage
usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Enhanced pi-gen build script for Distiller platform with random hostname generation.

OPTIONS:
    -c, --config FILE       Base config file (default: config-distiller-prod)
    -h, --hostname NAME     Custom hostname (overrides random generation)
    -p, --prefix PREFIX     Hostname prefix (default: distiller)
    -r, --random-length N   Random suffix length (default: 4)
    -m, --method METHOD     Build method: native or docker (default: native)
    -C, --clean            Clean build (rebuild current stage)
    -R, --resume           Continue/resume previous build
    -S, --skip-images      Skip image generation (development mode)
    -s, --skip-stages LIST  Comma-separated list of stages to skip
    -z, --compression TYPE  Compression type: xz, gz, zip, none (default: xz)
    -d, --dev-mode         Development mode (skip images, no archive)
    -P, --preserve         Preserve Docker container for debugging
    -j, --jobs N           Parallel jobs for make (default: $(nproc))
    -v, --verbose          Verbose output
    -n, --no-deps-check    Skip dependency checking
    -A, --no-archive       Don't archive successful builds
    -h, --help             Show this help message

EXAMPLES:
    # Basic build with random hostname
    ${SCRIPT_NAME}
    
    # Build with custom config and Docker
    ${SCRIPT_NAME} -c config-distiller-bhv -m docker
    
    # Development build (skip images, preserve container)
    ${SCRIPT_NAME} -d -P -m docker
    
    # Clean rebuild with custom hostname
    ${SCRIPT_NAME} -C -h distiller-test01
    
    # Resume interrupted build
    ${SCRIPT_NAME} -R
    
    # Build with custom compression and verbose output
    ${SCRIPT_NAME} -z gz -v

HOSTNAME EXAMPLES:
    Default:           distiller-ab1c
    Custom prefix:     mydevice-x9y2
    Custom hostname:   production-unit-001

NOTES:
    - Random hostnames help identify individual devices in deployments
    - Build logs are saved to ${BUILD_LOG_DIR}/
    - Successful builds are archived to ${DIR}/archives/
    - Temporary config files are automatically cleaned up
    - Use -P flag to preserve Docker container for debugging failed builds

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            BASE_CONFIG="$2"
            shift 2
            ;;
        -h|--hostname)
            CUSTOM_HOSTNAME="$2"
            shift 2
            ;;
        -p|--prefix)
            HOSTNAME_PREFIX="$2"
            shift 2
            ;;
        -r|--random-length)
            RANDOM_LENGTH="$2"
            shift 2
            ;;
        -m|--method)
            BUILD_METHOD="$2"
            shift 2
            ;;
        -C|--clean)
            CLEAN_BUILD=1
            shift
            ;;
        -R|--resume)
            CONTINUE_BUILD=1
            shift
            ;;
        -S|--skip-images)
            SKIP_IMAGES=1
            shift
            ;;
        -s|--skip-stages)
            SKIP_STAGES="$2"
            shift 2
            ;;
        -z|--compression)
            COMPRESSION="$2"
            shift 2
            ;;
        -d|--dev-mode)
            DEV_MODE=1
            SKIP_IMAGES=1
            ARCHIVE_BUILD=0
            shift
            ;;
        -P|--preserve)
            PRESERVE_CONTAINER=1
            shift
            ;;
        -j|--jobs)
            PARALLEL_JOBS="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -n|--no-deps-check)
            CHECK_DEPS=0
            shift
            ;;
        -A|--no-archive)
            ARCHIVE_BUILD=0
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_status "=== Distiller Image Generator ==="
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    # Check dependencies if requested
    if [[ ${CHECK_DEPS} -eq 1 ]]; then
        if ! check_dependencies; then
            print_error "Dependency check failed"
            exit 1
        fi
    fi
    
    # Validate build method
    if [[ "${BUILD_METHOD}" != "native" ]] && [[ "${BUILD_METHOD}" != "docker" ]]; then
        print_error "Invalid build method: ${BUILD_METHOD}"
        exit 1
    fi
    
    # Validate compression type
    if [[ ! "${COMPRESSION}" =~ ^(xz|gz|zip|none)$ ]]; then
        print_error "Invalid compression type: ${COMPRESSION}"
        exit 1
    fi
    
    # Determine hostname
    if [[ -n "${CUSTOM_HOSTNAME}" ]]; then
        HOSTNAME="${CUSTOM_HOSTNAME}"
        print_info "Using custom hostname: ${HOSTNAME}"
    else
        RANDOM_SUFFIX=$(generate_random_suffix ${RANDOM_LENGTH:-4})
        HOSTNAME="${HOSTNAME_PREFIX}-${RANDOM_SUFFIX}"
        print_info "Generated hostname: ${HOSTNAME}"
    fi
    
    # Resolve base config path
    if [[ ! "${BASE_CONFIG}" =~ ^/ ]]; then
        BASE_CONFIG="${DIR}/${BASE_CONFIG}"
    fi
    
    # Create temporary config with modified hostname
    print_status "Creating temporary config with hostname: ${HOSTNAME}"
    TEMP_CONFIG=$(create_temp_config "${BASE_CONFIG}" "${HOSTNAME}")
    
    if [[ -z "${TEMP_CONFIG}" ]] || [[ ! -f "${TEMP_CONFIG}" ]]; then
        print_error "Failed to create temporary config"
        exit 1
    fi
    
    print_info "Temporary config: ${TEMP_CONFIG}"
    
    # Show build configuration
    print_status "Build Configuration:"
    print_info "  Base Config: ${BASE_CONFIG}"
    print_info "  Hostname: ${HOSTNAME}"
    print_info "  Build Method: ${BUILD_METHOD}"
    print_info "  Compression: ${COMPRESSION}"
    print_info "  Clean Build: ${CLEAN_BUILD}"
    print_info "  Continue Build: ${CONTINUE_BUILD}"
    print_info "  Skip Images: ${SKIP_IMAGES}"
    print_info "  Dev Mode: ${DEV_MODE}"
    print_info "  Parallel Jobs: ${PARALLEL_JOBS}"
    
    # Export parallel jobs
    export MAKE_OPTS="-j${PARALLEL_JOBS}"
    
    # Run the build
    BUILD_START=$(date +%s)
    
    if run_build "${TEMP_CONFIG}"; then
        BUILD_END=$(date +%s)
        BUILD_TIME=$((BUILD_END - BUILD_START))
        
        print_status "Build completed successfully in $((BUILD_TIME / 60)) minutes"
        
        # Archive if requested
        if [[ ${ARCHIVE_BUILD} -eq 1 ]]; then
            archive_build "${HOSTNAME}"
        fi
        
        # Show output location
        if [[ -d "${DIR}/deploy" ]]; then
            print_status "Build outputs:"
            ls -lh "${DIR}/deploy/"*.{img,zip,xz,gz} 2>/dev/null || true
        fi
        
        print_status "=== Build Complete: ${HOSTNAME} ==="
        exit 0
    else
        print_error "Build failed! Check log: ${BUILD_LOG_FILE:-build-logs/latest.log}"
        print_info "To debug, you can:"
        print_info "  1. Check the build log for errors"
        print_info "  2. Use -R flag to resume the build"
        print_info "  3. Use -P flag to preserve Docker container for debugging"
        exit 1
    fi
}

# Run main function
main