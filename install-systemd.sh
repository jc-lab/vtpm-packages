#!/bin/bash

DESTDIR=${DESTDIR:-}

cat <<'EOF' | tee $DESTDIR/lib/systemd/system/swtpm-device@.service
[Unit]
Description=swtpm server

[Service]
Type=simple
PermissionsStartOnly=true
User=swtpm
ExecStartPre=/opt/swtpm-prepare.sh %i
ExecStart=swtpm socket --tpm2 --tpmstate dir=/var/lib/qemu-swtpm/%i --ctrl type=unixio,path=/var/run/qemu-server/swtpm/device-%i.sock
Restart=always

[Install]
WantedBy=multi-user.target
EOF

cat <<'EOF' | tee $DESTDIR/opt/swtpm-prepare.sh
#!/bin/sh

set -e

mkdir -p /var/run/qemu-server/swtpm
chown swtpm:swtpm /var/run/qemu-server/swtpm

mkdir -p /var/lib/qemu-swtpm/$1
chown swtpm:swtpm -R /var/lib/qemu-swtpm/$1
EOF

chmod +x $DESTDIR/opt/swtpm-prepare.sh

