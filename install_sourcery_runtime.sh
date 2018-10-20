#!/bin/sh

################################################################################
#
# Installs SourceryRuntime sources in ./Vendor/SourceryRuntime.
#
# Example:
# ${SRCROOT}/install_sourcery_runtime.sh
#
################################################################################

## Output helpers
#

function colored_echo() {
    local -r color="${1}"
    local -r message="${2}"
    echo "\033${color}${message}\033[0m"
}

function verbose_echo() {
    local -r message="${1}"

    colored_echo "[37m" "${message}"
}

function warn_echo() {
    local -r message="${1}"

    colored_echo "[33m" "${message}"
}

## Other helpers
#

function random_string() {
    date +%s | shasum | base64 | head -c 32 ; echo
}

## Script phases
#

function copy_file() {
    local -r source="${1}"
    local -r destination="${2}"

    if ! [ -f "${destination}" ] && ! [ -L "${destination}" ]; then
        verbose_echo "Copying ${source}."
        cp "${source}" "${destination}"
    else
        warn_echo "Skipping ${FUNCNAME[0]} because ${destination} already exists."
    fi
}


function copy_folder() {
    local -r source="${1}"
    local -r destination="${2}"

    if ! [ -d "${destination}" ] && ! [ -L "${destination}" ]; then
        verbose_echo "Copying ${source}."
        mkdir -p "${destination}"
        cp -r "${source}" "${destination}"
    else
        warn_echo "Skipping ${FUNCNAME[0]} because ${destination} already exists."
    fi
}

function clone_repo() {
    local -r repository_url="${1}"
    local -r clone_folder="${2}"
    local -r sources_relative_path="${3}"
    local -r sources_destination="${4}"

    local -r sources_path="${clone_folder}/${sources_relative_path}/"
    local -r license_path="${clone_folder}/LICENSE"

    if [ -d "${sources_destination}" ] || [ -L "${sources_destination}" ]; then
        warn_echo "Skipping ${FUNCNAME[0]} because ${sources_destination} already exists."
    elif ! [ -d "${clone_folder}" ]; then
        verbose_echo "Cloning ${repository_url} git repository."
        git clone "${repository_url}" "${clone_folder}"
        copy_folder "${sources_path}" "${sources_destination}"
        copy_file "${license_path}" "${sources_destination}"
    else
        warn_echo "Skipping ${FUNCNAME[0]} because folder ${clone_folder} already exists."
    fi
}

function install() {
    local -r repository_url="${1}"
    local -r sources_relative_path="${2}"
    local -r destination="${3}"

    local -r clone_folder_suffix="$(random_string)"
    local -r clone_folder="/tmp/sourcerer-${clone_folder_suffix}"

    clone_repo "${repository_url}" "${clone_folder}" "${sources_relative_path}" "${destination}"
}

## Script entry point
#

function main() {
    local -r sourcery_repository_url='https://github.com/krzysztofzablocki/Sourcery.git'
    local -r sourcery_runtime_relative_path='SourceryRuntime/Sources'
    local -r sourcery_runtime_destintaion_path='./Vendor/SourceryRuntime'
    install "${sourcery_repository_url}" "${sourcery_runtime_relative_path}" "${sourcery_runtime_destintaion_path}"
}
main
