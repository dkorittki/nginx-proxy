FROM nginx:1.19.3

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    wget \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*


# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf

# Install Forego
RUN curl -O https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-arm64.tgz \
  && tar -C /usr/local/bin -xvzf forego-stable-linux-arm64.tgz \
  && chmod +x /usr/local/bin/forego \
  && rm forego-stable-linux-arm64.tgz

ENV DOCKER_GEN_VERSION 0.7.4

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz

COPY network_internal.conf /etc/nginx/

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
