FROM alpine:latest

# Add scripts
ADD releases.py /releases.py
ADD requirements.txt /requirements.txt
ADD build.sh /build.sh

# Install dependencies
RUN apk update && apk upgrade && apk add python3 openssl file jansson bison python
RUN pip3 install --upgrade pip && pip3 install -r /requirements.txt
RUN apk add -t .build-yara wget python-dev py-setuptools openssl-dev build-base libc-dev file-dev automake autoconf libtool jansson-dev

# Permissions and build script
RUN chmod +x /build.sh /releases.py
RUN /build.sh

# Cleanup image after building
RUN apk del --purge .build-yara && rm -rf /tmp/*