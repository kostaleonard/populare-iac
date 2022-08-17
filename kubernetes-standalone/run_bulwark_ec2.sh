docker run -d \
  --rm \
  --name=bulwark \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e PEERS=leo_mac \
  -e SERVERURL=0.0.0.0 \
  -e SERVERPORT=51820 \
  -e INTERNAL_SUBNET=10.13.13.0 \
  -e PEERDNS=auto \
  -p 51820:51820/udp \
  -v /tmp/bulwark-config:/config \
  -v /lib/modules:/lib/modules \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  linuxserver/wireguard
