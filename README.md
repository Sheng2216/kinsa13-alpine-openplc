# OpenPLC v3 image running on Alpine Linux

This Dockerfile uses a customized version of the development branch of https://github.com/thiagoralves/OpenPLC_v3

The forked repo is located here: https://github.com/kinsamanka/OpenPLC_v3

To build:
```
docker build --build-arg GIT_REV="$(git rev-parse HEAD)" --build-arg BUILD_DATE="$(date)" -t <tag>
```

To run:
```
docker run -it -p 8080:8080 <tag>
```
