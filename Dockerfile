FROM node:18-bullseye

ENV DEBIAN_FRONTEND noninteractive
ENV TAILSCALED_TUN=userspace-networking

WORKDIR /app

RUN apt-get update && \
  apt-get install -y netcat && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://tailscale.com/install.sh | sh

COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD nc -vz 127.0.0.1 3000 \
  || exit 1

CMD ["/app/run.sh"]
