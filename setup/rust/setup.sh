#!/bin/sh

set -eu

# shellcheck disable=SC1091
. ./utils.sh

printf "Installing rustup\n\n"
rustup_url="https://sh.rustup.rs"
if _test_executable "curl" 2>/dev/null; then
	curl -sSf "$rustup_url" | sh
else
	wget -qO- "$rustup_url" | sh
fi