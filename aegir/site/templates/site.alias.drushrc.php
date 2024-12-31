<?php
// {{ ansible_managed }}
$aliases['{{ inventory_hostname }}'] = [
  'context_type' => 'site',
  'uri' => '{{ inventory_hostname }}',
  'root' => '{{ site_root }}',
  'site_path' => '{{ site_path }}',
];
