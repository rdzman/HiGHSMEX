ARG MATLAB_RELEASE=r2023b
ARG ADDITIONAL_PRODUCTS="MATLAB"
FROM ubuntu:24.04
USER root

# Declare the global argument to use at the current build stage
ARG MATLAB_RELEASE
ARG ADDITIONAL_PRODUCTS

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
	libatomic1 zlib1g-dev \
	libxt6 \
	gcc-12 \
    g++-12 \
	cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm \
    && chmod +x mpm \
    && ./mpm install \
        --destination=/opt/matlab \
        --release=${MATLAB_RELEASE} \
        --products ${ADDITIONAL_PRODUCTS} \
    || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) \
    && rm -f mpm /tmp/mathworks_root.log

ARG LICENSE_SERVER
ENV MLM_LICENSE_FILE=$LICENSE_SERVER

WORKDIR /build
COPY build.sh /root/
WORKDIR /root
RUN chmod +x build.sh
RUN ./build.sh