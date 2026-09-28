#!/usr/bin/env bash

USERNAME="admin1"
QSC_WS="/home/$USERNAME/qsc_ws"
QSC_WS_SRC="/home/$USERNAME/qsc_ws/src"
QSC_WS_BUILD="$QSC_WS/build"
QSC_WS_INSTALL="$QSC_WS/install"
QSC_WS_LOG="$QSC_WS/log"

rm_dir_if_exists() {
	if [ $# -eq 1 ]; then
		local dir="$1"
		[ -d "$dir" ] && rm -rf -- "$dir"
	fi
}

qsc_ws() {
	rm_dir_if_exists "$QSC_WS_BUILD/"
	rm_dir_if_exists "$QSC_WS_INSTALL/"
	rm_dir_if_exists "$QSC_WS_LOG/"

	colcon --log-base "$QSC_WS_LOG/" \
		build \
		--parallel-workers "$(nproc)" \
		--base-paths "$QSC_WS_SRC/" \
		--build-base "$QSC_WS_BUILD/" \
		--install-base "$QSC_WS_INSTALL/"
}
# qsc_ws

qsc_ws_pkg() {
	local pkg_name="$1"

	rm_dir_if_exists "$QSC_WS_BUILD/$pkg_name/"
	rm_dir_if_exists "$QSC_WS_INSTALL/$pkg_name/"

	colcon --log-base "$QSC_WS_LOG/" \
		build \
		--packages-select "$pkg_name" \
		--parallel-workers "$(nproc)" \
		--base-paths "$QSC_WS_SRC/" \
		--build-base "$QSC_WS_BUILD/" \
		--install-base "$QSC_WS_INSTALL/"
}
qsc_ws_pkg "test_cpp"
