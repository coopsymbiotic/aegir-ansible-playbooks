#!/bin/bash

# Help menu
print_help() {
cat <<-HELP
This script is used to fix the file ownership of a Drupal platform. You need to
provide the following arguments:

  --root: Path to the root of your Drupal installation.
  --script-user: Username of the user to whom you want to give file ownership
                 (defaults to 'aegir').
  --web-group: Web server group name (defaults to 'www-data').

Usage: (sudo) ${0##*/} --root=PATH --script-user=USER --web_group=GROUP
Example: (sudo) ${0##*/} --drupal_path=/var/aegir/platforms/drupal-7.50 --script-user=aegir --web-group=www-data
HELP
exit 0
}

if [ $(id -u) != 0 ]; then
  printf "Error: You must run this with sudo or root.\n"
  exit 1
fi

drupal_root=${1%/}
script_user=${2:-aegir}
web_group="${3:-www-data}"

# Parse Command Line Arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --root=*)
        drupal_root="${1#*=}"
        ;;
    --script-user=*)
        script_user="${1#*=}"
        ;;
    --web-group=*)
        web_group="${1#*=}"
        ;;
    --help) print_help;;
    *)
      printf "Error: Invalid argument, run --help for valid arguments.\n"
      exit 1
  esac
  shift
done

if [ -z "${drupal_root}" ] || [ ! -f "${drupal_root}/core/modules/system/system.module" ] && [ ! -f "${drupal_root}/modules/system/system.module" ]; then
  printf "Error: Please provide a valid Drupal root directory.\n"
  exit 1
fi

if [ -z "${script_user}" ] || [[ $(id -un "${script_user}" 2> /dev/null) != "${script_user}" ]]; then
  printf "Error: Please provide a valid user.\n"
  exit 1
fi

cd $drupal_root

if [ ! -d "${drupal_root}/sites" ]; then
  mkdir "${drupal_root}/sites"
fi
if [ ! -d "${drupal_root}/sites/all" ]; then
  mkdir "${drupal_root}/sites/all"
fi

# This file is required in Drupal10 for drush multisite support
if [ ! -f "${drupal_root}/sites/sites.php" ] && [ -f "${drupal_root}/sites/example.sites.php" ]; then
  cp "${drupal_root}/sites/example.sites.php" "${drupal_root}/sites/sites.php"
fi

# Change ownership of all contents of ${drupal_root} to aegir:www-data
find . \( -path "./sites" -prune \) -exec chown ${script_user}:${web_group} '{}' \+
chown ${script_user}:${web_group} ./sites/sites.php
chown -R ${script_user}:${web_group} ./sites/all

# Change permissions of all directories inside ${drupal_root} to "750"
find . \( -path "./sites" -prune \) -type d -exec chmod 750 '{}' \+
find ./sites/all/ -type d -exec chmod 750 '{}' \+
chmod 750 ./sites/all/

# Change permissions of all files inside ${drupal_root} to 640
find . \( -path "./sites" -prune \) -type f -exec chmod 640 '{}' \+
find ./sites/all/ -type f -exec chmod 640 '{}' \+
