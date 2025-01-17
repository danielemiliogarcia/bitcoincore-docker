FROM debian:bullseye-slim

# Set default UID and GID
ARG UID=101
ARG GID=101

RUN echo "UID: ${UID}"
RUN echo "GID: ${GID}"

# Create bitcoin user and group with specified UID and GID
RUN groupadd --gid ${GID} bitcoin \
  && useradd --create-home --no-log-init -u ${UID} -g ${GID} bitcoin

# Install dependencies
RUN apt-get update -y \
  && apt-get install -y curl gnupg gosu

# Clean up apt cache
RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set environment variables for Bitcoin Core
ARG TARGETPLATFORM
ENV BITCOIN_VERSION=27.0
ENV BITCOIN_DATA=/home/bitcoin/.bitcoin
ENV PATH=/opt/bitcoin-${BITCOIN_VERSION}/bin:$PATH

# FIXED HARDCODED TARGET PLATFORM
ENV TARGETPLATFORM=x86_64-linux-gnu

# Determine the correct TARGETPLATFORM
RUN set -ex \
  && if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then export TARGETPLATFORM=x86_64-linux-gnu; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then export TARGETPLATFORM=aarch64-linux-gnu; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm/v7" ]; then export TARGETPLATFORM=arm-linux-gnueabihf; fi


# Import GPG keys
RUN for key in \
    152812300785C96444D3334D17565732E08E5E41 \
    0AD83877C1F0CD1EE9BD660AD7CC770B81FD22A8 \
    590B7292695AFFA5B672CBB2E13FC145CD3F4304 \
    CFB16E21C950F67FA95E558F2EEB9F5CC09526C1 \
    F4FC70F07310028424EFC20A8E4256593F177720 \
    D1DBF2C4B96F2DEBF4C16654410108112E7EA81F \
    287AE4CA1187C68C08B49CB2D11BD4F33F1DB499 \
    9DEAE0DC7063249FB05474681E4AED62986CD25D \
    3EB0DEE6004A13BE5A0CC758BF2978B068054311 \
    ED9BDF7AD6A55E232E84524257FF9BDBCC301009 \
    28E72909F1717FE9607754F8A7BEB2621678D37D \
    79D00BAC68B56D422F945A8F8E3A8F3247DBCBBF \
    637DB1E23370F84AFF88CCE03152347D07DA627C \
    1A3E761F19D2CC7785C5502EA291A2C45D0C504A \
    E86AE73439625BBEE306AAE6B66D427F873CB1A3 \
    670BC460DC8BF5EEF1C3BC74B14CC9F833238F85 \
    F19F5FF2B0589EC341220045BA03F4DBE0C63FB4 \
    F2CFC4ABD0B99D837EEBB7D09B79B45691DB4173 \
    C388F6961FB972A95678E327F62711DBDCA8AE56 \
    6A8F9C266528E25AEB1D7731C2371D91CB716EA7 \
    E61773CD6E01040E2F1BD78CE7E2984B6289C93A \
  ; do \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" || \
    gpg --batch --keyserver keys.openpgp.org --recv-keys "$key" || \
    gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" || \
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key" || \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key"; \
  done

# Download Bitcoin Core, server is failing, use mirror
# RUN curl -SLO https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-${TARGETPLATFORM}.tar.gz \
#   && curl -SLO https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS \
#   && curl -SLO https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc

# Download Bitcoin Core (this mirror currently only provide up to version 27.0)
RUN curl -SLO https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-${TARGETPLATFORM}.tar.gz \
  && curl -SLO https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS \
  && curl -SLO https://bitcoin.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc

# Verify the SHA256SUMS file with the GPG signature
RUN gpg --verify SHA256SUMS.asc SHA256SUMS

# Check the SHA256SUM of the downloaded tarball
RUN grep " bitcoin-${BITCOIN_VERSION}-${TARGETPLATFORM}.tar.gz" SHA256SUMS

# Validate the SHA256 checksum
RUN grep " bitcoin-${BITCOIN_VERSION}-${TARGETPLATFORM}.tar.gz" SHA256SUMS | sha256sum -c -


# Extract the Bitcoin Core binaries
RUN tar -xzf *.tar.gz -C /opt

# Cleanup
RUN rm *.tar.gz *.asc \
  && rm -rf /opt/bitcoin-${BITCOIN_VERSION}/bin/bitcoin-qt

# Copy the entrypoint script
COPY docker-entrypoint.sh /entrypoint.sh

# Define a volume for the Bitcoin data directory
VOLUME ["/home/bitcoin/.bitcoin"]

# Expose necessary ports
EXPOSE 8332 8333 18332 18333 18443 18444 38333 38332

# Set the entrypoint to the custom script
ENTRYPOINT ["/entrypoint.sh"]

# Verify installation
RUN bitcoind -version | grep "Bitcoin Core version v${BITCOIN_VERSION}"

# Set the default command to start bitcoind
CMD ["bitcoind"]

