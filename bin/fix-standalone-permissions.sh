#!/bin/bash

# {{ ansible_managed }}

# Help menu
print_help() {
cat <<-HELP
This script is used to fix the file permissions of a CiviCRM Standalone site.
You can provide the following argument:

  --site-path: Path to the Standalone site's directory.

Usage: (sudo) ${0##*/} --site-path=PATH
Example: (sudo) ${0##*/} --site-path=/var/aegir/platforms/standalone/web/sites/example.org
HELP
exit 0
}

site_path=`pwd`

# Parse Command Line Arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --site-path=*)
        site_path="${1#*=}"
        ;;
    --help) print_help;;
    *)
      printf "Error: Invalid argument, run --help for valid arguments.\n"
      exit 1
  esac
  shift
done

# Validate it is a valid directory
if [ -z "${site_path}" ] || [ ! -d "${site_path}/upload" ] ; then
  printf "Error: Please provide a valid Standalone site directory.\n"
  exit 1
fi

if [ $(id -u) != 0 ]; then
  printf "Error: You must run this with sudo or root.\n"
  exit 1
fi

cd $site_path

# Guess our site name (site.example.org)
url=`basename $(pwd)`

# Fix the main site directory
chown aegir:www-data $site_path
chmod 0770 $site_path
chmod g+s $site_path

# drushrc.php Probably does not need to be readably by anyone than Aegir
# (for Standalone, this file is not really used, only Aegir compatibility)
chown aegir:aegir drushrc.php
chmod 0600 drushrc.php

# Public directory
mkdir -p ./upload
chown -R aegir:www-data upload
find ./upload/ -type d -exec chmod 0775 {} \;
find ./upload/ -type f -exec chmod 0664 {} \;

# Private directory
mkdir -p ../../../private/$url
mkdir -p ../../../private/$url/cache
mkdir -p ../../../private/$url/log
chown -R aegir:www-data ../../../private/$url
find ../../../private/$url -type d -exec chmod 0775 {} \;
find ../../../private/$url -type f ! -name civicrm.settings.php -exec chmod 0664 {} \;
chmod 0640 ../../../private/$url/civicrm.settings.php
