<?php

# Used by 'bee uli'
global $base_url;
$base_url = 'https://{{ inventory_hostname }}';

# https://docs.backdropcms.org/documentation/trusted-host-settings
# Aliases are currently not supported by Aegir because we assume redirects
$settings['trusted_host_patterns'] = [
  '^{{ inventory_hostname }}$',
];
