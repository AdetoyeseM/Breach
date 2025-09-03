#!/bin/bash

# Mobile Build Script for Breach App
# Builds only for Android and iOS platforms

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📱 Breach App Mobile Build Script${NC}"

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Not in a Flutter project. Run this from the project root.${NC}"
    exit 1
fi

# Default values
BUILD_TYPE="release"
CLEAN_BUILD=false
SKIP_TESTS=true
BUILD_ANDROID=true
BUILD_IOS=true
VERSION=""
BUILD_NUMBER=""

# Function to show help
 

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check Flutter version
    FLUTTER_VERSION=$(flutter --version | grep -o 'Flutter [0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
    echo -e "${BLUE}📱 Using $FLUTTER_VERSION${NC}"
    
    # Check Flutter doctor
    echo -e "${BLUE}🏥 Running Flutter doctor...${NC}"
    if ! flutter doctor --android-licenses &> /dev/null; then
        echo -e "${YELLOW}⚠️  Some Flutter doctor issues detected. Build may fail.${NC}"
    fi
    
    echo -e "${GREEN}✅ Prerequisites check completed${NC}"
}

# # Function to clean build
clean_build() {
    if [ "$CLEAN_BUILD" = true ]; then
        echo -e "${BLUE}🧹 Cleaning build...${NC}"
        flutter clean
        flutter pub get
        echo -e "${GREEN}✅ Build cleaned${NC}"
    fi
}


# Function to build Android
build_android() {
    echo -e "${BLUE}🤖 Building Android app...${NC}"
    
    local build_args=""
    [ "$BUILD_TYPE" = "release" ] && build_args="$build_args --release"
    [ "$BUILD_TYPE" = "debug" ] && build_args="$build_args --debug"
    [ "$BUILD_TYPE" = "profile" ] && build_args="$build_args --profile"
    
    if [ -n "$VERSION" ]; then
        build_args="$build_args --build-name=$VERSION"
    fi
    
    if [ -n "$BUILD_NUMBER" ]; then
        build_args="$build_args --build-number=$BUILD_NUMBER"
    fi
    
    # Build APK
    echo -e "${BLUE}📦 Building APK...${NC}"
    if flutter build apk $build_args; then
        echo -e "${GREEN}✅ Android APK built successfully!${NC}"
        
        # Show APK location and size
        APK_PATH=$(find build/app/outputs/flutter-apk -name "*.apk" | head -1)
        if [ -n "$APK_PATH" ]; then
            echo -e "${BLUE}📁 APK location: $APK_PATH${NC}"
            ls -lh "$APK_PATH"
        fi
    else
        echo -e "${RED}❌ Android APK build failed${NC}"
        exit 1
    fi
    
    # Build AAB for release
    if [ "$BUILD_TYPE" = "release" ]; then
        echo -e "${BLUE}📦 Building Android App Bundle...${NC}"
        if flutter build appbundle $build_args; then
            echo -e "${GREEN}✅ Android App Bundle built successfully!${NC}"
            
            # Show AAB location and size
            AAB_PATH=$(find build/app/outputs/bundle -name "*.aab" | head -1)
            if [ -n "$AAB_PATH" ]; then
                echo -e "${BLUE}📁 AAB location: $AAB_PATH${NC}"
                ls -lh "$AAB_PATH"
            fi
        else
            echo -e "${YELLOW}⚠️  AAB build failed, but APK was successful${NC}"
        fi
    fi
}

# Function to build iOS
build_ios() {
    echo -e "${BLUE}🍎 Building iOS app...${NC}"
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}❌ iOS builds can only be done on macOS${NC}"
        return 1
    fi
    
    # Check if Xcode is installed
    if ! command -v xcodebuild &> /dev/null; then
        echo -e "${RED}❌ Xcode not found. Please install Xcode from the App Store.${NC}"
        return 1
    fi
    
    local build_args=""
    [ "$BUILD_TYPE" = "release" ] && build_args="$build_args --release"
    [ "$BUILD_TYPE" = "debug" ] && build_args="$build_args --debug"
    [ "$BUILD_TYPE" = "profile" ] && build_args="$build_args --profile"
    
    if [ -n "$VERSION" ]; then
        build_args="$build_args --build-name=$VERSION"
    fi
    
    if [ -n "$BUILD_NUMBER" ]; then
        build_args="$build_args --build-number=$BUILD_NUMBER"
    fi
    
    # Install CocoaPods if needed
    if [ ! -f "ios/Podfile.lock" ]; then
        echo -e "${BLUE}📦 Installing CocoaPods dependencies...${NC}"
        cd ios
        pod install
        cd ..
    fi
    
    # Build iOS
    if flutter build ios $build_args; then
        echo -e "${GREEN}✅ iOS app built successfully!${NC}"
        echo -e "${BLUE}📁 iOS build location: build/ios/${NC}"
        
        # Show build info
        if [ -d "build/ios" ]; then
            echo -e "${BLUE}📊 iOS build size:${NC}"
            du -sh build/ios/
        fi
    else
        echo -e "${RED}❌ iOS build failed${NC}"
        exit 1
    fi
}

# Function to show build summary
show_build_summary() {
    echo -e "${BLUE}📋 Build Summary:${NC}"
    echo "  Android: $BUILD_ANDROID"
    echo "  iOS: $BUILD_IOS"
    echo "  Build Type: $BUILD_TYPE"
    echo "  Version: ${VERSION:-$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)}"
    echo "  Build Number: ${BUILD_NUMBER:-$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f2)}"
    echo "  Clean Build: $CLEAN_BUILD"
    echo "  Skip Tests: $SKIP_TESTS"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
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
        -s|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --android-only)
            BUILD_ANDROID=true
            BUILD_IOS=false
            shift
            ;;
        --ios-only)
            BUILD_ANDROID=false
            BUILD_IOS=true
            shift
            ;;
        --debug)
            BUILD_TYPE="debug"
            shift
            ;;
        --profile)
            BUILD_TYPE="profile"
            shift
            ;;
        --release)
            BUILD_TYPE="release"
            shift
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(debug|release|profile)$ ]]; then
    echo -e "${RED}❌ Invalid build type: $BUILD_TYPE. Must be debug, release, or profile.${NC}"
    exit 1
fi

# Main execution
main() {
    echo -e "${BLUE}🚀 Starting Breach App mobile build process...${NC}"
    echo -e "${BLUE}⏰ Build started at: $(date)${NC}"
    
    # Check prerequisites
    # check_prerequisites
    
    # # Show build summary
    # show_build_summary
    
    # Clean build if requested
    # clean_build 

    # Build Android if requested
    if [ "$BUILD_ANDROID" = true ]; then
        build_android
    fi
    
    # Build iOS if requested
    if [ "$BUILD_IOS" = true ]; then
        build_ios
    fi
    
    echo -e "${GREEN}🎉 Mobile build process completed successfully!${NC}"
    echo -e "${BLUE}⏰ Build finished at: $(date)${NC}"
    
    # Show final summary
    echo -e "${BLUE}📱 Build Results:${NC}"
    if [ "$BUILD_ANDROID" = true ]; then
        echo -e "  ✅ Android: build/app/outputs/flutter-apk/"
        if [ "$BUILD_TYPE" = "release" ]; then
            echo -e "  ✅ Android Bundle: build/app/outputs/bundle/"
        fi
    fi
    
    if [ "$BUILD_IOS" = true ]; then
        echo -e "  ✅ iOS: build/ios/"
    fi
}

# Run main function
main "$@"
