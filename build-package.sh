#!/bin/bash

if [ -n "${SIGN_KEY_ID:-}" ]; then
	dpkg-buildpackage --sign-key="${SIGN_KEY_ID}" "$@"
else
	dpkg-buildpackage --no-sign "$@"
fi

