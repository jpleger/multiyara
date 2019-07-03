# MultiYARA

MultiYARA is a docker container with multiple versions of yara in a single container. The goal of this is to make it easier to test rules against multiple versions of yara to assist in finding compatibility issues between engine versions. 

## How it works

The docker container pulls against the latest releases on GitHub and compiles different versions with the same build flags. Currently it goes back to anything newer than yara 3.6, which should provide several years of different versions.

Every day, a new docker container is built and pushed to Docker Hub, ensuring the latest versions of yara are on the docker image.

## Using Multi Yara

Simply use the container on dockerhub or build yourself.