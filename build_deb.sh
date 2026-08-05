#!/bin/bash
set -e

build_package() {
    local src_dir="${1}"
    local control_file="${src_dir}/DEBIAN/control"

    if [ ! -f "${control_file}" ]; then
        echo "ERROR: File not found: ${control_file}!"
        return 1
    fi

    local pkg_name=$(grep -E "^Package:" "${control_file}" | awk '{print $2}')
    local pkg_ver=$(grep -E "^Version:" "${control_file}" | awk '{print $2}')
    local pkg_arch=$(grep -E "^Architecture:" "${control_file}" | awk '{print $2}')
    local output_deb="${pkg_name}_${pkg_ver}_${pkg_arch}.deb"

    echo "Setting file permissions for ${pkg_name}..."
    find "${src_dir}" -type d -exec chmod 755 {} +

    [ -f "${src_dir}/DEBIAN/postinst" ] && chmod 755 "${src_dir}/DEBIAN/postinst"
    [ -f "${src_dir}/DEBIAN/prerm" ] && chmod 755 "${src_dir}/DEBIAN/prerm"
    [ -d "${src_dir}/usr/bin" ] && chmod -R 755 "${src_dir}/usr/bin"

    echo "Building package: ${output_deb}..."
    dpkg-deb --build "${src_dir}" "${output_deb}"
    echo "Successfully built: ${output_deb}"
    echo "----------------------------------------"
}

# Build both packages
build_package "src-firmware"
build_package "src-config"
