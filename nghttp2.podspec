Pod::Spec.new do |s|
  s.name         = "nghttp2"
  s.version      = "1.36.0"
  s.summary      = "nghttp2 for iOS and OS X"
  s.description  = "nghttp2 - HTTP/2 C Library."
  s.homepage     = "https://nghttp2.org"
  s.license	     = { :type => 'MIT', :file => 'COPYING' }
  s.source       = { :git => "https://github.com/nghttp2/nghttp2.git", :tag => "#{s.version}" }
  s.authors      = ["187j3x1",
                      "Alek Storm",
                      "Alex Nalivko",
                      "Alexandros Konstantinakis-Karmis",
                      "Alexis La Goutte",
                      "Amir Pakdel",
                      "Anders Bakken",
                      "Andreas Pohl",
                      "Andy Davies",
                      "Angus Gratton",
                      "Anna Henningsen",
                      "Ant Bryan",
                      "Benedikt Christoph Wolters",
                      "Benjamin Peterson",
                      "Bernard Spil",
                      "Brendan Heinonen",
                      "Brian Card",
                      "Brian Suh",
                      "Daniel Evers",
                      "Daniel Stenberg",
                      "Dave Reisner",
                      "David Beitey",
                      "David Weekly",
                      "Dmitriy Vetutnev",
                      "Don",
                      "Dylan Plecki",
                      "Etienne Cimon",
                      "Fabian Möller",
                      "Fabian Wiesel",
                      "Gabi Davar",
                      "Gitai",
                      "Google Inc.",
                      "Jacob Champion",
                      "Jan Kundrát",
                      "Jan-E",
                      "Janusz Dziemidowicz",
                      "Jay Satiro",
                      "Jianqing Wang",
                      "Jim Morrison",
                      "Josh Braegger",
                      "José F. Calcerrada",
                      "Kamil Dudka",
                      "Kazuho Oku",
                      "Kenny (kang-yen) Peng",
                      "Kenny Peng",
                      "Kit Chan",
                      "Kyle Schomp",
                      "LazyHamster",
                      "Lucas Pardue",
                      "MATSUMOTO Ryosuke",
                      "Marc Bachmann",
                      "Matt Rudary",
                      "Matt Way",
                      "Mike Conlen",
                      "Mike Frysinger",
                      "Mike Lothian",
                      "Nicholas Hurley",
                      "Nora Shoemaker",
                      "Pedro Santos",
                      "Peeyush Aggarwal",
                      "Peter Wu",
                      "Piotr Sikora",
                      "Raul Gutierrez Segales",
                      "Remo E",
                      "Reza Tavakoli",
                      "Rick Lei",
                      "Ross Smith II",
                      "Scott Mitchell",
                      "Sebastiaan Deckers",
                      "Simone Basso",
                      "Soham Sinha",
                      "Stefan Eissing",
                      "Stephen Ludin",
                      "Sunpoet Po-Chuan Hsieh",
                      "Svante Signell",
                      "Syohei YOSHIDA",
                      "Tapanito",
                      "Tatsuhiko Kubo",
                      "Tatsuhiro Tsujikawa",
                      "Tobias Geerinckx-Rice",
                      "Tom Harwood",
                      "Tomasz Buchert",
                      "Tomasz Torcz",
                      "Vernon Tang",
                      "Viacheslav Biriukov",
                      "Viktor Szakats",
                      "Viktor Szépe",
                      "Wenfeng Liu",
                      "Xiaoguang Sun",
                      "Zhuoyun Wei",
                      "acesso",
                      "ayanamist",
                      "bxshi",
                      "clemahieu",
                      "dalf",
                      "dawg",
                      "es",
                      "fangdingjun",
                      "jwchoi",
                      "kumagi",
                      "lstefani",
                      "makovich",
                      "mod-h2-dev",
                      "moparisthebest",
                      "snnn",
                      "yuuki-kodama",]
  s.prepare_command = <<-CMD
    #!/bin/bash
    # This script downlaods and builds the Mac, iOS and tvOS nghttp2 libraries
    #
    # Credits:
    # Jason Cox, @jasonacox
    #   https://github.com/jasonacox/Build-OpenSSL-cURL
    #
    # NGHTTP2 - https://github.com/nghttp2/nghttp2
    #

    # > nghttp2 is an implementation of HTTP/2 and its header
    # > compression algorithm HPACK in C
    #
    # NOTE: pkg-config is required

    set -e

    # set trap to help debug build errors
    trap 'echo "** ERROR with Build - Check /tmp/nghttp2*.log"; tail /tmp/nghttp2*.log' INT TERM EXIT

    usage ()
    {
      echo "usage: $0 [nghttp2 version] [iOS SDK version (defaults to latest)] [tvOS SDK version (defaults to latest)]"
      trap - INT TERM EXIT
      exit 127
    }

    if [ "$1" == "-h" ]; then
      usage
    fi

    if [ -z $2 ]; then
      IOS_SDK_VERSION="" #"9.1"
      IOS_MIN_SDK_VERSION="7.0"

      TVOS_SDK_VERSION="" #"9.0"
      TVOS_MIN_SDK_VERSION="9.0"
    else
      IOS_SDK_VERSION=$2
      TVOS_SDK_VERSION=$3
    fi

    if [ -z $1 ]; then
      NGHTTP2_VERNUM="1.36.0"
    else
      NGHTTP2_VERNUM="$1"
    fi

    # --- Edit this to update version ---

    NGHTTP2_VERSION="nghttp2-${NGHTTP2_VERNUM}"
    DEVELOPER=`xcode-select -print-path`

    NGHTTP2="${PWD}"

    # Check to see if pkg-config is already installed
    if (type "pkg-config" > /dev/null) ; then
      echo "pkg-config installed"
    else
      echo "ERROR: pkg-config not installed... attempting to install."

      # Check to see if Brew is installed
      if ! type "brew" > /dev/null; then
        echo "FATAL ERROR: brew not installed - unable to install pkg-config - exiting."
        exit
      else
        echo "brew installed - using to install pkg-config"
        brew install pkg-config
      fi

      # Check to see if installation worked
      if (type "pkg-config" > /dev/null) ; then
        echo "SUCCESS: pkg-config installed"
      else
        echo "FATAL ERROR: pkg-config failed to install - exiting."
        exit
      fi
    fi

    buildMac()
    {
      ARCH=$1
      HOST="i386-apple-darwin"

      echo "Building ${NGHTTP2_VERSION} for ${ARCH}"

      TARGET="darwin-i386-cc"

      if [[ $ARCH == "x86_64" ]]; then
        TARGET="darwin64-x86_64-cc"
      fi

      export CC="${BUILD_TOOLS}/usr/bin/clang -fembed-bitcode"
        export CFLAGS="-arch ${ARCH} -pipe -Os -gdwarf-2 -fembed-bitcode"
        export LDFLAGS="-arch ${ARCH}"

      pushd . > /dev/null
      cd "${NGHTTP2_VERSION}"
      ./configure --disable-shared --disable-app --disable-threads --enable-lib-only --prefix="${NGHTTP2}/Mac/${ARCH}" --host=${HOST} &> "/tmp/${NGHTTP2_VERSION}-${ARCH}.log"
      make >> "/tmp/${NGHTTP2_VERSION}-${ARCH}.log" 2>&1
      make install >> "/tmp/${NGHTTP2_VERSION}-${ARCH}.log" 2>&1
      make clean >> "/tmp/${NGHTTP2_VERSION}-${ARCH}.log" 2>&1
      popd > /dev/null
    }

    buildIOS()
    {
      ARCH=$1
      BITCODE=$2

      pushd . > /dev/null
      cd "${NGHTTP2_VERSION}"

      if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]]; then
        PLATFORM="iPhoneSimulator"
      else
        PLATFORM="iPhoneOS"
      fi

        if [[ "${BITCODE}" == "nobitcode" ]]; then
            CC_BITCODE_FLAG=""
        else
            CC_BITCODE_FLAG="-fembed-bitcode"
        fi

      export $PLATFORM
      export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
      export CROSS_SDK="${PLATFORM}${IOS_SDK_VERSION}.sdk"
      export BUILD_TOOLS="${DEVELOPER}"
      export CC="${BUILD_TOOLS}/usr/bin/gcc"
      export CFLAGS="-arch ${ARCH} -pipe -Os -gdwarf-2 -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -miphoneos-version-min=${IOS_MIN_SDK_VERSION} ${CC_BITCODE_FLAG}"
      export LDFLAGS="-arch ${ARCH} -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK}"

      echo "Building ${NGHTTP2_VERSION} for ${PLATFORM} ${IOS_SDK_VERSION} ${ARCH}"
        if [[ "${ARCH}" == "arm64" ]]; then
        ./configure --disable-shared --disable-app --disable-threads --enable-lib-only --prefix="${NGHTTP2}/iOS/${ARCH}" --host="arm-apple-darwin" &> "/tmp/${NGHTTP2_VERSION}-iOS-${ARCH}-${BITCODE}.log"
        else
        ./configure --disable-shared --disable-app --disable-threads --enable-lib-only --prefix="${NGHTTP2}/iOS/${ARCH}" --host="${ARCH}-apple-darwin" &> "/tmp/${NGHTTP2_VERSION}-iOS-${ARCH}-${BITCODE}.log"
        fi

        make -j8 >> "/tmp/${NGHTTP2_VERSION}-iOS-${ARCH}-${BITCODE}.log" 2>&1
        make install >> "/tmp/${NGHTTP2_VERSION}-iOS-${ARCH}-${BITCODE}.log" 2>&1
        make clean >> "/tmp/${NGHTTP2_VERSION}-iOS-${ARCH}-${BITCODE}.log" 2>&1
        popd > /dev/null
    }

    buildTVOS()
    {
      ARCH=$1

      pushd . > /dev/null
      cd "${NGHTTP2_VERSION}"

      if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]]; then
        PLATFORM="AppleTVSimulator"
      else
        PLATFORM="AppleTVOS"
      fi

        export $PLATFORM
        export CROSS_TOP="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
        export CROSS_SDK="${PLATFORM}${TVOS_SDK_VERSION}.sdk"
        export BUILD_TOOLS="${DEVELOPER}"
        export CC="${BUILD_TOOLS}/usr/bin/gcc"
        export CFLAGS="-arch ${ARCH} -pipe -Os -gdwarf-2 -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -mtvos-version-min=${TVOS_MIN_SDK_VERSION} -fembed-bitcode"
        export LDFLAGS="-arch ${ARCH} -isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -L${OPENSSL}/tvOS/lib ${NGHTTP2LIB}"
      export LC_CTYPE=C

      echo "Building ${NGHTTP2_VERSION} for ${PLATFORM} ${TVOS_SDK_VERSION} ${ARCH}"

      # Patch apps/speed.c to not use fork() since it's not available on tvOS
      # LANG=C sed -i -- 's/define HAVE_FORK 1/define HAVE_FORK 0/' "./apps/speed.c"

      # Patch Configure to build for tvOS, not iOS
      # LANG=C sed -i -- 's/D\_REENTRANT\:iOS/D\_REENTRANT\:tvOS/' "./Configure"
      # chmod u+x ./Configure

      ./configure --disable-shared --disable-app --disable-threads --enable-lib-only  --prefix="${NGHTTP2}/tvOS/${ARCH}" --host="arm-apple-darwin" &> "/tmp/${CURL_VERSION}-tvOS-${ARCH}.log"
      LANG=C sed -i -- 's/define HAVE_FORK 1/define HAVE_FORK 0/' "config.h"

      # add -isysroot to CC=
      #sed -ie "s!^CFLAG=!CFLAG=-isysroot ${CROSS_TOP}/SDKs/${CROSS_SDK} -mtvos-version-min=${TVOS_MIN_SDK_VERSION} !" "Makefile"

      make  >> "/tmp/${NGHTTP2_VERSION}-tvOS-${ARCH}.log" 2>&1
      make install  >> "/tmp/${NGHTTP2_VERSION}-tvOS-${ARCH}.log" 2>&1
      make clean >> "/tmp/${NGHTTP2_VERSION}-tvOS-${ARCH}.log" 2>&1
      popd > /dev/null
    }


    echo "Cleaning up"
    rm -rf nghttp2
    rm -rf lib
    rm -fr Mac
    rm -fr iOS
    rm -fr tvOS

    mkdir -p lib

    rm -rf "/tmp/${NGHTTP2_VERSION}-*"
    rm -rf "/tmp/${NGHTTP2_VERSION}-*.log"

    rm -rf "${NGHTTP2_VERSION}"

    if [ ! -e ${NGHTTP2_VERSION}.tar.gz ]; then
      echo "Downloading ${NGHTTP2_VERSION}.tar.gz"
      curl -LO https://github.com/nghttp2/nghttp2/releases/download/v${NGHTTP2_VERNUM}/${NGHTTP2_VERSION}.tar.gz
    else
      echo "Using ${NGHTTP2_VERSION}.tar.gz"
    fi

    echo "Unpacking nghttp2"
    tar xfz "${NGHTTP2_VERSION}.tar.gz"

    mkdir -p nghttp2
    cp "${NGHTTP2_VERSION}/lib/includes/nghttp2/nghttp2.h" "nghttp2/nghttp2.h"
    cp "${NGHTTP2_VERSION}/lib/includes/nghttp2/nghttp2ver.h" "nghttp2/nghttp2ver.h"

    echo "Building Mac libraries"

    buildMac "x86_64"

    mkdir -p "${NGHTTP2}/lib/Mac"

    lipo \
      "${NGHTTP2}/Mac/x86_64/lib/libnghttp2.a" \
      -create -output "${NGHTTP2}/lib/Mac/libnghttp2.a"

    echo "Building iOS libraries (nobitcode)"
    buildIOS "arm64" "nobitcode"
    buildIOS "armv7" "nobitcode"
    buildIOS "armv7s" "nobitcode"
    buildIOS "x86_64" "nobitcode"
    buildIOS "i386" "nobitcode"

    mkdir -p "${NGHTTP2}/lib/iOS"

    lipo \
      "${NGHTTP2}/iOS/armv7/lib/libnghttp2.a" \
      "${NGHTTP2}/iOS/armv7s/lib/libnghttp2.a" \
      "${NGHTTP2}/iOS/i386/lib/libnghttp2.a" \
      "${NGHTTP2}/iOS/arm64/lib/libnghttp2.a" \
      "${NGHTTP2}/iOS/x86_64/lib/libnghttp2.a" \
      -create -output "${NGHTTP2}/lib/iOS/libnghttp2.a"

    # echo "Building tvOS libraries"
    # buildTVOS "arm64"
    # buildTVOS "x86_64"

    # lipo \
    #         "${NGHTTP2}/tvOS/arm64/lib/libnghttp2.a" \
    #         "${NGHTTP2}/tvOS/x86_64/lib/libnghttp2.a" \
    #         -create -output "${NGHTTP2}/lib/tvOS/libnghttp2.a"

    echo "Cleaning up"
    rm -rf "/tmp/${NGHTTP2_VERSION}-*"
    rm -rf "${NGHTTP2_VERSION}"
    rm -fr Mac
    rm -fr iOS
    rm -fr tvOS

    #reset trap
    trap - INT TERM EXIT
  CMD

  s.ios.deployment_target   = '6.0'
  s.ios.source_files        = 'nghttp2/*.h'
  s.ios.public_header_files = 'nghttp2/*.h'
  s.ios.header_dir          = 'nghttp2'
  s.ios.preserve_paths      = 'lib/iOS/libnghttp2.a'
  s.ios.vendored_libraries  = 'lib/iOS/libnghttp2.a'

  s.osx.deployment_target   = '10.8'
  s.osx.source_files        = 'nghttp2/*.h'
  s.osx.public_header_files = 'nghttp2/*.h'
  s.osx.header_dir          = 'nghttp2'
  s.osx.preserve_paths      = 'lib/Mac/libnghttp2.a'
  s.osx.vendored_libraries  = 'lib/Mac/libnghttp2.a'

  s.libraries = 'nghttp2'
  s.requires_arc = false
end
