# syntax=docker/dockerfile:1.4

FROM node:18-bullseye

ENV DEBIAN_FRONTEND=noninteractive
ENV TAILSCALED_TUN=userspace-networking

WORKDIR /app

RUN apt-get update && \
	# gettext is for envsubst
	apt-get install -y icecast2 gettext mime-support netcat \
	&& curl -fsSL https://tailscale.com/install.sh | sh \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd -m icecast-user
COPY config.xml.template .
RUN mkdir -p /usr/local/icecast/logs \
	&& chown icecast-user:icecast-user /app /usr/local/icecast/logs \
	&& chown -R icecast-user:icecast-user /usr/local/icecast/logs

COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
	CMD nc -vz 127.0.0.1 3000 && nc -vz 127.0.0.1 8000 \
	|| exit 1

CMD ["/app/run.sh"]
