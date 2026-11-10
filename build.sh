#!/usr/bin/env bash
#
# Motorola Moto G86 5G (nice) Kernel Build Script
#

# Variables
MANIFEST_URL="https://github.com/matheusxda/kernel_motorola_nice_manifest.git"
MANIFEST_BRANCH="MMI-A171VNH.50-16"

REQUIRED_TOOLS="
git
repo
curl
"

SCRIPT_NAME="$(basename "$0")"
JOBS=4

BUILD_ONLY=false
SYNC_ONLY=false
PRINT_COMMANDS=false
CLEAN=false

CLANG=aosp
OUT_DIR="$HOME/kernel_motorola_nice"

MODULE_DIR="kernel_device_modules-6.1"
CONFIG_NAME="moto-mgk_64_k61-nice.config"

abort()
{
    echo "[FATAL] $1"
    exit "${2:-1}"
}

check_tools()
{
    for tool in $REQUIRED_TOOLS; do
        command -v "$tool" >/dev/null 2>&1 || abort "Required tool not found: $tool"
    done
}

check_jobs()
{
    [[ "$JOBS" =~ ^[1-9][0-9]*$ ]] ||
        abort "Invalid number of jobs: $JOBS"
}

check_clang()
{
    case "$CLANG" in
      aosp|neutron) true ;;
      *) abort "Unknown clang: $CLANG" ;;
    esac
}

help()
{
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Options:

  -j, --jobs NUM
      Number of parallel jobs.
      Default: $JOBS

  -b, --branch BRANCH
      Manifest branch.
      Default: $MANIFEST_BRANCH
      
  -o, --out OUT
      Out dir.
      Default: ~/kernel_motorola_nice

  -C, --clang CLANG
      Select an clang.
      Options: aosp (default), neutron

  -B, --build-only
      Skip repository synchronization.

  -s, --sync-only
      Synchronize repositories without building.

  -p, --print-build-commands
      Print build commands.

  -c, --clean
      Clean Bazel cache using --expunge.

  -h, --help
      Show this help message.

EOF
}

# Argument parser
parse_args()
{
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -j|--jobs)
                [[ $# -ge 2 ]] || abort "Missing value for $1"
                JOBS="$2"
                shift 2
                ;;
            -b|--branch)
                [[ $# -ge 2 ]] || abort "Missing value for $1"
                MANIFEST_BRANCH="$2"
                shift 2
                ;;
            -o|--out)
                [[ $# -ge 2 ]] || abort "Missing value for $1"
                OUT_DIR="$2"
                shift 2
                ;;
            -C|--clang)
                [[ $# -ge 2 ]] || abort "Missing value for $1"
                CLANG="$2"
                shift 2
                ;;
            -B|--build-only)
                BUILD_ONLY=true
                shift
                ;;
            -s|--sync-only)
                SYNC_ONLY=true
                shift
                ;;
            -p|--print-build-commands)
                PRINT_COMMANDS=true
                shift
                ;;
           -c|--clean)
                CLEAN=true
                shift
                ;;
            -h|--help)
                help
                exit 0
                ;;
            *)
                abort "Unknown argument: $1"
                ;;
        esac
    done

    [[ "$BUILD_ONLY" == true && "$SYNC_ONLY" == true ]] &&
        abort "--build-only and --sync-only cannot be used together."

    check_jobs
    check_clang
}

# Sync
sync()
{
    echo "Initializing manifest..."

    repo init -u "$MANIFEST_URL" -b "$MANIFEST_BRANCH" || abort "repo init failed!"

    echo "Synchronizing repositories with $JOBS jobs..."

    repo sync -c -j"$JOBS" || abort "repo sync failed!"

    echo "Preparing directories..."

    ln -sfn "$MODULE_DIR" kernel_device_modules-mainline
    ln -sfn "$MODULE_DIR" kernel_device_modules

    local source_config="$MODULE_DIR/arch/arm64/configs/ext_config/$CONFIG_NAME"
    local destination_config="$MODULE_DIR/kernel/configs/ext_config/$CONFIG_NAME"

    [ -f "$source_config" ] || abort "Configuration not found: $source_config"

    mkdir -p "$(dirname "$destination_config")"
    cp -f "$source_config" "$destination_config"

    if [ "$CLANG" = "neutron" ]; then
       # Delete clang in manifest
        rm -rf "$OUT_DIR"/prebuilts/clang/host/linux-x86/*
        cd "$OUT_DIR/prebuilts/clang/host/linux-x86"
        curl -LO "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman"
        chmod +x antman
        ./antman -S
        cd "$OUT_DIR"
    fi

   echo "Done!"
}

# Build
build_kernel()
{
     tools/bazel build //kernel-6.1:kernel --//:kernel_version=6.1 --//:internal_config=true
}

build_modules()
{
    export DEFCONFIG_OVERLAYS="ext_config/$CONFIG_NAME"

    tools/bazel build //kernel_device_modules-6.1:mgk_64_k61.user
}

build()
{
    [[ -x ./tools/bazel || -f ./tools/bazel ]] ||
        abort "Bazel wrapper not found: tools/bazel"

    build_kernel
    build_modules

    echo "Kernel build completed successfully!"
}

# Clean
clean()
{
    tools/bazel clean --expunge
}

# Print build commands
print_build_commands()
{
    cat << EOF
# Build kernel
tools/bazel build //kernel-6.1:kernel --//:kernel_version=6.1 --//:internal_config=true

# Build device modules
export DEFCONFIG_OVERLAYS="ext_config/$CONFIG_NAME"
tools/bazel build //kernel_device_modules-6.1:mgk_64_k61.user

# Clean Bazel cache
tools/bazel clean --expunge
EOF
}

# Main
main()
{
    parse_args "$@"

    if [[ "$PRINT_COMMANDS" == true ]]; then
        print_build_commands
        exit 0
    fi

    check_tools

    if [[ "$CLEAN" == true ]]; then
        clean
        exit 0
    fi

    mkdir -p "$OUT_DIR"
    OUT_DIR="$(cd "$OUT_DIR" && pwd)"
    cd "$OUT_DIR"

    if [[ "$BUILD_ONLY" == false ]]; then
        sync
    fi

    if [[ "$SYNC_ONLY" == true ]]; then
        exit 0
    fi

    build
}

main "$@"
