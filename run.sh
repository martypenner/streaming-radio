#!/bin/bash

set -euo pipefail

tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &
tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=radio

ALL_PROXY=socks5://localhost:1055/ \
	HTTP_PROXY=http://localhost:1055/ \
	http_proxy=http://localhost:1055/ \
	node build
