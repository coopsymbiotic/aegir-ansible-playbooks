#!/bin/bash

# {{ aegir_managed }}

# Help menu
print_help() {
cat <<-HELP
This script is used to fix the file ownership of a Drupal site. You need to
provide the following arguments:

  --site-path: Path to the Drupal site directory (defaults to the current directory).
  --script-user: Username of the user to whom you want to give file ownership
                 (defaults to 'aegir').
  --web-group: Web server group name (defaults to 'www-data').

Usage: (sudo) ${0##*/} --site-path=PATH --script-user=USER --web_group=GROUP
Example: (sudo) ${0##*/} --site-path=/var/aegir/platforms/drupal-7.50/sites/example.com --script-user=aegir --web-group=www-data
HELP
exit 0
}

site_path=`pwd`
script_user="aegir"
web_group="www-data"

# Parse Command Line Arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --site-path=*)
        site_path="${1#*=}"
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

if [ -z "${site_path}" ] || [ ! -f "${site_path}/settings.php" ] ; then
  printf "Error: Please provide a valid Drupal site directory.\n"
  exit 1
fi

if [ -z "${script_user}" ] || [[ $(id -un "${script_user}" 2> /dev/null) != "${script_user}" ]]; then
  printf "Error: Please provide a valid user.\n"
  exit 1
fi

if [ $(id -u) != 0 ]; then
  printf "Error: You must run this with sudo or root.\n"
  exit 1
fi

cd $site_path

if [ ! -d ./private ]; then
  mkdir ./private
fi

chown -R ${script_user}:${web_group} .
find . \( -path "./files" -o -path "./private" -prune \) -type d -exec chmod 750 '{}' \+
find . \( -path "./files" -o -path "./private" -prune \) -type f -exec chmod 640 '{}' \+
chmod 770 files
find ./files -type f -exec chmod 660 '{}' \+
find ./files -type d -exec chmod 770 '{}' \+
chmod 770 private
find ./private -type f -exec chmod 660 '{}' \+
find ./private -type d -exec chmod 770 '{}' \+
chmod 440 settings.php
chmod 550 .
