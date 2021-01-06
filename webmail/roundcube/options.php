<?php

  $config['mail_domain'] = 'localdomain';

  $config['imap_debug'] = false;
  $config['imap_conn_options'] = array(
    'ssl' => array(
      'verify_peer' => false,
      'verify_peer_name' => false,
    ),
  );

  $config['smtp_debug'] = false;
  $config['smtp_conn_options'] = array(
    'ssl' => array(
      'verify_peer' => false,
      'verify_peer_name' => false,
    ),
  );

?>
