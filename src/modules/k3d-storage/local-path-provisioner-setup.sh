#!/bin/sh

set -eu

chown 1000:1000
mkdir -m 0777 -p "$VOL_DIR"
