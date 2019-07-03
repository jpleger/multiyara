#!/usr/bin/env python3
import requests
import re


MIN_VER = (3, 6)

release_list = requests.get('https://api.github.com/repos/VirusTotal/yara/releases').json()
release_list = [(x['tag_name'], x['tarball_url']) for x in release_list]

for release_version, release_url in release_list:
    version = re.search(r'^v(\d+)\.(\d+)\.(\d+)$', release_version)
    if not version.groups():
        continue
    major, minor, patch = (int(x) for x in version.groups())
    if major < MIN_VER[0] or (major == MIN_VER[0] and minor < MIN_VER[1]):
        continue
    print(release_version)