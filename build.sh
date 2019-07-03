#!/bin/sh
RELEASE_LIST="$(./releases.py)"
BASE_DIR="$(mktemp -d)"


echo $BASE_DIR

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
    echo "Running $(pwd)/bootstrap.sh"
    ./bootstrap.sh >> ${RELEASE_DIR}/build.log
    echo "Running $(pwd)/configure"
    mkdir -p /yara/${RELEASE}/
    ./configure --bindir=/yara/${RELEASE}/ --enable-static --disable-shared --enable-profiling --enable-cuckoo --enable-magic --enable-dex --enable-dotnet --enable-macho >> ${RELEASE_DIR}/configure.log
    echo "Building yara"
    make >> ${RELEASE_DIR}/make.log
    echo "Installing yara in /yara/${RELEASE}/"
    make install >> ${RELEASE_DIR}/make.log
    echo "Running yara version"
    /yara/${RELEASE}/yara --version
done