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

rm_pkg_if_exists() {
	if [ $# -eq 1 ]; then
		local pkg_name="$1"
		[ -d "$QSC_WS_BUILD/$pkg_name/" ] && rm -rf -- "$QSC_WS_BUILD/${pkg_name:?}/"
		[ -d "$QSC_WS_INSTALL/$pkg_name/" ] && rm -rf -- "$QSC_WS_INSTALL/${pkg_name:?}/"
	fi
}

qsc_ws() {
	rm_dir_if_exists "$QSC_WS_BUILD/"
	rm_dir_if_exists "$QSC_WS_INSTALL/"
	rm_dir_if_exists "$QSC_WS_LOG/"

	echo "编译工作空间全部包"
	colcon --log-base "$QSC_WS_LOG/" \
		build \
		--parallel-workers "$(nproc)" \
		--base-paths "$QSC_WS_SRC/" \
		--build-base "$QSC_WS_BUILD/" \
		--install-base "$QSC_WS_INSTALL/"
}

qsc_ws_pkg() {
	local -a pkgs_in=("$@")
	local -A seen
	local -a pkgs_unique=()

	for p in "${pkgs_in[@]}"; do
		[[ -z ${seen[$p]} ]] && seen[$p]=1 && pkgs_unique+=("$p")
	done

	for pkg in "${pkgs_unique[@]}"; do
		rm_pkg_if_exists "$pkg"
	done

	echo "编译包: ${pkgs_unique[*]}"
	colcon --log-base "$QSC_WS_LOG" \
		build \
		--packages-select "${pkgs_unique[@]}" \
		--parallel-workers "$(nproc)" \
		--base-paths "$QSC_WS_SRC" \
		--build-base "$QSC_WS_BUILD" \
		--install-base "$QSC_WS_INSTALL"
}

main() {
	if [[ $# -eq 0 ]]; then
		qsc_ws
	else
		qsc_ws_pkg "$@"
	fi
}
main "$@"
