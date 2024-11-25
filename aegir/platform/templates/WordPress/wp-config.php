<?php

/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, and ABSPATH. You can find more information by visiting
 * {@link https://codex.wordpress.org/Editing_wp-config.php Editing wp-config.php}
 * Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

/**
 * Aegir-specific - Adds support for using civix and cv from the CLI.
 *
 * It will traverse the directory hierarchy up from the current working directory
 * looking for a drushrc.php file. It also looks for a wp-config.php file, to avoid
 * going higher than the site root.
 */
if (file_exists('/var/aegir/config/includes/global.inc')) {
  require_once '/var/aegir/config/includes/global.inc';
}

if (php_sapi_name() == "cli") {
  $directory = getcwd();
  $found = FALSE;

  while (!$found && dirname($directory) != '/') {
    if (file_exists($directory . '/drushrc.php')) {
      require_once($directory . '/drushrc.php');
      $found = TRUE;
    }
    if (file_exists($directory . '/wp-config.php')) {
      require_once($directory . '/wp-config.php');
      $found = TRUE;
    }
    $directory = dirname(dirname($directory . '/../'));
  }
}

// This is used for web requests, which have the wp_content_dir in the vhost
if (!empty($_SERVER['wp_content_dir'])) {
  if (file_exists($_SERVER['wp_content_dir'] . '/../wp-config.php')) {
    require_once $_SERVER['wp_content_dir'] . '/../wp-config.php';
  }
  if (file_exists($_SERVER['wp_content_dir'] . '/../drushrc.php')) {
    require_once $_SERVER['wp_content_dir'] . '/../drushrc.php';
  }
}

/**
 * Added by Symbiotic: support for the fail2ban plugin
 */
if (defined('WP_FAIL2BAN_ACTIVATE') && WP_FAIL2BAN_ACTIVATE) {
  include '{{ publish_path }}/wp-content/wp-fail2ban-config.php';
}

// ** MySQL settings ** //
/** The name of the database for WordPress */
if (!defined('DB_NAME')) {
  define('DB_NAME', $_SERVER['db_name']);
}

/** MySQL database username */
if (!defined('DB_USER')) {
  define('DB_USER', $_SERVER['db_user']);
}

/** MySQL database password */
if (!defined('DB_PASSWORD')) {
  define('DB_PASSWORD', $_SERVER['db_passwd']);
}

/** MySQL hostname */
if (!defined('DB_HOST')) {
  define('DB_HOST', $_SERVER['db_host']);
}

/** Content directory */
if (!defined('WP_CONTENT_DIR')) {
  define('WP_CONTENT_DIR', $_SERVER['wp_content_dir']);
  define('WP_CONTENT_URL', $_SERVER['wp_content_url']);
}

/** Database Charset to use in creating database tables. */
if (!defined('DB_CHARSET')) {
  define('DB_CHARSET', 'utf8');
}

/** The Database Collate type. Don't change this if in doubt. */
if (!defined('DB_COLLATE')) {
  define('DB_COLLATE', '');
}

/** Required by CiviCRM extensions */
if (!defined('CIVICRM_CMSDIR')) {
  define('CIVICRM_CMSDIR', '/var/aegir/platforms/wordpress');
}

/** Keep max 3 revisions for wp_posts - can be overridden in the wp-config.php of the site */
if (!defined('WP_POST_REVISIONS')) {
  define('WP_POST_REVISIONS', 3);
}

/** coopsymbiotic/ops#441 Disable the lazy WP cron. We use systemd timers */
if (!defined('DISABLE_WP_CRON')) {
  define('DISABLE_WP_CRON', true);
}

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 *
 * NB: this can be overridden by the site-specific wp-config.php.
 */
$table_prefix  = 'wp_';

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */

if (!defined('AUTH_KEY')) {
  define('AUTH_KEY',         'put your unique phrase here');
  define('SECURE_AUTH_KEY',  'put your unique phrase here');
  define('LOGGED_IN_KEY',    'put your unique phrase here');
  define('NONCE_KEY',        'put your unique phrase here');
  define('AUTH_SALT',        'put your unique phrase here');
  define('SECURE_AUTH_SALT', 'put your unique phrase here');
  define('LOGGED_IN_SALT',   'put your unique phrase here');
  define('NONCE_SALT',       'put your unique phrase here');
}

/**#@-*/

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
if (!defined('WP_DEBUG')) {
  define('WP_DEBUG', false);
}

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */

// If run from Aegir (platform verify), stop here.
if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
