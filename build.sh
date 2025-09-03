#!/bin/bash

# Breach App Build Script
# This script automates the Flutter build process for multiple platforms

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BUILD_TYPE="release"
PLATFORM=""
VERSION=""
BUILD_NUMBER=""
CLEAN_BUILD=false
VERBOSE=false
SKIP_TESTS=false
BUILD_CACHE=true
PARALLEL_BUILD=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    cat << EOF
Breach App Build Script

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -p, --platform PLATFORM Build for specific platform (android, ios, web, windows, macos, linux)
    -t, --type TYPE         Build type (debug, release, profile) [default: release]
    -v, --version VERSION   App version (e.g., 1.2.3)
    -b, --build-number NUM  Build number (e.g., 123)
    -c, --clean             Clean build before building
    -V, --verbose           Verbose output
    -s, --skip-tests        Skip running tests before build
    --no-cache              Disable build cache
    --parallel              Enable parallel builds
    --all                   Build for all supported platforms

EXAMPLES:
    $0 --android --release                    # Build Android release APK
    $0 --ios --debug                         # Build iOS debug app
    $0 --web --release                       # Build web release
    $0 --all --version=1.2.3 --build-number=123  # Build all platforms with version
    $0 --android --clean --verbose           # Clean build Android with verbose output

PLATFORMS:
    android    Build Android APK/AAB
    ios        Build iOS app
    web        Build web app
    windows    Build Windows app
    macos      Build macOS app
    linux      Build Linux app

EOF
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check Flutter version
    FLUTTER_VERSION=$(flutter --version | grep -o 'Flutter [0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
    print_status "Using $FLUTTER_VERSION"
    
    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        print_error "Not in a Flutter project directory. Please run this script from the project root."
        exit 1
    fi
    
    # Check Flutter doctor
    print_status "Running Flutter doctor..."
    if ! flutter doctor --android-licenses &> /dev/null; then
        print_warning "Some Flutter doctor issues detected. Build may fail."
    fi
    
    print_success "Prerequisites check completed"
}

# Function to clean build
clean_build() {
    if [ "$CLEAN_BUILD" = true ]; then
        print_status "Cleaning build..."
        flutter clean
        flutter pub get
        print_success "Build cleaned"
    fi
}

 

# Function to build Android
build_android() {
    print_status "Building Android app..."
    
    local build_args=""
    [ "$BUILD_TYPE" = "release" ] && build_args="$build_args --release"
    [ "$BUILD_TYPE" = "debug" ] && build_args="$build_args --debug"
    [ "$BUILD_TYPE" = "profile" ] && build_args="$build_args --profile"
    [ "$BUILD_CACHE" = false ] && build_args="$build_args --no-build-cache"
    [ "$PARALLEL_BUILD" = true ] && build_args="$build_args --parallel"
    
    if [ -n "$VERSION" ]; then
        build_args="$build_args --build-name=$VERSION"
    fi
    
    if [ -n "$BUILD_NUMBER" ]; then
        build_args="$build_args --build-number=$BUILD_NUMBER"
    fi
    
    # Build APK
    print_status "Building APK..."
    if flutter build apk $build_args; then
        print_success "APK built successfully"
        
        # Show APK location
        APK_PATH=$(find build/app/outputs/flutter-apk -name "*.apk" | head -1)
        if [ -n "$APK_PATH" ]; then
            print_status "APK location: $APK_PATH"
            ls -lh "$APK_PATH"
        fi
    else
        print_error "APK build failed"
        exit 1
    fi
    
    # Build AAB for release
    if [ "$BUILD_TYPE" = "release" ]; then
        print_status "Building AAB..."
        if flutter build appbundle $build_args; then
            print_success "AAB built successfully"
            
            # Show AAB location
            AAB_PATH=$(find build/app/outputs/bundle -name "*.aab" | head -1)
            if [ -n "$AAB_PATH" ]; then
                print_status "AAB location: $AAB_PATH"
                ls -lh "$AAB_PATH"
            fi
        else
            print_warning "AAB build failed, but APK was successful"
        fi
    fi
}

# Function to build iOS
build_ios() {
    print_status "Building iOS app..."
    
    local build_args=""
    [ "$BUILD_TYPE" = "release" ] && build_args="$build_args --release"
    [ "$BUILD_TYPE" = "debug" ] && build_args="$build_args --debug"
    [ "$BUILD_TYPE" = "profile" ] && build_args="$build_args --profile"
    [ "$BUILD_CACHE" = false ] && build_args="$build_args --no-build-cache"
    
    if [ -n "$VERSION" ]; then
        build_args="$build_args --build-name=$VERSION"
    fi
    
    if [ -n "$BUILD_NUMBER" ]; then
        build_args="$build_args --build-number=$BUILD_NUMBER"
    fi
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "iOS builds can only be done on macOS"
        exit 1
    fi
    
    # Check if Xcode is installed
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode is not installed. Please install Xcode from the App Store."
        exit 1
    fi
    
    # Install CocoaPods if needed
    if [ ! -f "ios/Podfile.lock" ]; then
        print_status "Installing CocoaPods dependencies..."
        cd ios
        pod install
        cd ..
    fi
    
    # Build iOS
    if flutter build ios $build_args; then
        print_success "iOS app built successfully"
        print_status "iOS build location: build/ios/"
    else
        print_error "iOS build failed"
        exit 1
    fi
}

 


# Function to build all platforms
build_all() {
    print_status "Building for all platforms..."
    
    local platforms=("android" "ios" "web" "windows" "macos" "linux")
    local failed_platforms=()
    
    for platform in "${platforms[@]}"; do
        print_status "Building for $platform..."
        
        case $platform in
            "android")
                if build_android; then
                    print_success "$platform build completed"
                else
                    failed_platforms+=("$platform")
                fi
                ;;
            "ios")
                if build_ios; then
                    print_success "$platform build completed"
                else
                    failed_platforms+=("$platform")
                fi
                ;;
            "web")
                if build_web; then
                    print_success "$platform build completed"
                else
                    failed_platforms+=("$platform")
                fi
                ;;
            "windows")
                if build_windows; then
                    print_success "$platform build completed"
                else
                    failed_platforms+=("$platform")
                fi
                ;;
            "macos")
                if build_macos; then
                    print_success "$platform build completed"
                else
                    failed_platforms+=("$platform")
                fi
                ;;
            "linux")
                if build_linux; then
                    print_success "$platform build completed"
                else
                    failed_platforms+=("$platform")
                fi
                ;;
        esac
    done
    
    if [ ${#failed_platforms[@]} -eq 0 ]; then
        print_success "All platform builds completed successfully!"
    else
        print_warning "Some platform builds failed: ${failed_platforms[*]}"
        exit 1
    fi
}

# Function to show build summary
show_build_summary() {
    print_status "Build Summary:"
    echo "  Platform: $PLATFORM"
    echo "  Build Type: $BUILD_TYPE"
    echo "  Version: ${VERSION:-$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)}"
    echo "  Build Number: ${BUILD_NUMBER:-$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f2)}"
    echo "  Clean Build: $CLEAN_BUILD"
    echo "  Skip Tests: $SKIP_TESTS"
    echo "  Build Cache: $BUILD_CACHE"
    echo "  Parallel Build: $PARALLEL_BUILD"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -b|--build-number)
            BUILD_NUMBER="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -V|--verbose)
            VERBOSE=true
            shift
            ;;
        -s|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --no-cache)
            BUILD_CACHE=false
            shift
            ;;
        --parallel)
            PARALLEL_BUILD=true
            shift
            ;;
        --all)
            PLATFORM="all"
            shift
            ;;
        --android)
            PLATFORM="android"
            shift
            ;;
        --ios)
            PLATFORM="ios"
            shift
            ;;
        --web)
            PLATFORM="web"
            shift
            ;;
        --windows)
            PLATFORM="windows"
            shift
            ;;
        --macos)
            PLATFORM="macos"
            shift
            ;;
        --linux)
            PLATFORM="linux"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(debug|release|profile)$ ]]; then
    print_error "Invalid build type: $BUILD_TYPE. Must be debug, release, or profile."
    exit 1
fi

# Set verbose mode
if [ "$VERBOSE" = true ]; then
    set -x
fi

# Main execution
main() {
    print_status "Starting Breach App build process..."
    print_status "Build started at: $(date)"
    
    # Check prerequisites
    check_prerequisites
    
    # Show build summary
    show_build_summary
    
    # Clean build if requested
    clean_build
    
    # Run tests if not skipped
    run_tests
    
    # Build based on platform
    case $PLATFORM in
        "android")
            build_android
            ;;
        "ios")
            build_ios
            ;;
        "web")
            build_web
            ;;
        "windows")
            build_windows
            ;;
        "macos")
            build_macos
            ;;
        "linux")
            build_linux
            ;;
        "all")
            build_all
            ;;
        "")
            print_error "No platform specified. Use --help for usage information."
            exit 1
            ;;
        *)
            print_error "Unknown platform: $PLATFORM"
            exit 1
            ;;
    esac
    
    print_success "Build process completed successfully!"
    print_status "Build finished at: $(date)"
}

# Run main function
main "$@"
