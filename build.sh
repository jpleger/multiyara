#!/bin/sh
RELEASE_LIST="$(./releases.py)"
BASE_DIR="$(mktemp -d)"
CLEANUP="yes"


echo "Working in ${BASE_DIR}"

for RELEASE in $RELEASE_LIST; do
    TARFILE="$BASE_DIR/yara-${RELEASE}.tar.gz"
    RELEASE_DIR="${BASE_DIR}/yara-${RELEASE}"

    # Download the yara release into the directory
    echo "downloading yara ${RELEASE} to ${TARFILE}"
    wget https://api.github.com/repos/VirusTotal/yara/tarball/${RELEASE} -O ${TARFILE} -o ${BASE_DIR}/wget.log
    mkdir ${RELEASE_DIR}

    # Extract the release
    tar -xzf ${TARFILE} -C ${RELEASE_DIR}

    # cd into the directory and build yara
    cd ${RELEASE_DIR}/*/

    # Bootstrap
    echo "Running $(pwd)/bootstrap.sh"
    ./bootstrap.sh >> ${RELEASE_DIR}/build.log

    # Configure build options
    echo "Running $(pwd)/configure"
    mkdir -p /yara/${RELEASE}/
    ./configure --bindir=/yara/${RELEASE}/ --enable-static --disable-shared --enable-profiling --enable-cuckoo --enable-magic --enable-dex --enable-dotnet --enable-macho >> ${RELEASE_DIR}/configure.log

    # Build yara
    echo "Building yara"
    make >> ${RELEASE_DIR}/make.log

    # install into the /yara/ directory
    echo "Installing yara in /yara/${RELEASE}/"
    make install >> ${RELEASE_DIR}/make.log

    # check to see if yara actually runs...
    echo "Running yara version"
    YARA_VERSION="$(/yara/${RELEASE}/yara --version)"

    # If it didn't work, bail out...
    if [[ -z "$YARA_VERSION" ]]; then
        exit 1
    fi

    # link yara so you can run from $PATH
    ln -s /yara/${RELEASE}/yara /usr/local/bin/yara-${YARA_VERSION}
done

if [[ "${CLEANUP}" == "yes" ]]; then
    rm -rf /tmp/*
fi