# vtpm packages

Packages:

- libtpms
- swtpm

# Install as systemd service

```bash
$ sudo useradd -r swtpm
$ sudo ./install-systemd.sh

# example:
$ systemctl enable swtpm-device@tpm1.service
$ systemctl start  swtpm-device@tpm1.service
```

# Build scripts License

Apache License 2.0

