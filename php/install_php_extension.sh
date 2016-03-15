#!/bin/bash

# zend opcache module
if ls -l /alidata/server/ | grep "$php_version" > /dev/null;then
  mkdir -p /alidata/server/php/lib/php/extensions/no-debug-non-zts-${zts_num}/

  # modify by diwen
  if [[ -f ./php/php-${php_version}/modules/opcache.so ]]; then
    \cp ./php/php-${php_version}/modules/opcache.so /alidata/server/php/lib/php/extensions/no-debug-non-zts-${zts_num}/
  elif [[ -f /alidata/server/php/lib/php/extensions/no-debug-zts-${zts_num}/opcache.so ]]; then
    \cp /alidata/server/php/lib/php/extensions/no-debug-zts-${zts_num}/opcache.so /alidata/server/php/lib/php/extensions/no-debug-non-zts-${zts_num}/
  fi

  if [[ -d /alidata/server/php/lib/php/extensions/no-debug-zts-${zts_num} ]]; then
    \rm -rf /alidata/server/php/lib/php/extensions/no-debug-zts-${zts_num}
  fi

  if [[ -d /alidata/server/php/lib/php/extensions/no-debug-non-zts-20131226 ]]; then
    \rm -rf /alidata/server/php/lib/php/extensions/no-debug-non-zts-20131226
  fi

  sed -i 's#\[opcache\]#\[opcache\]\nzend_extension=opcache.so#' /alidata/server/php/etc/php.ini
  sed -i 's#;opcache.enable=0#opcache.enable=1#' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.enable_cli=0/opcache.enable_cli=0/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.memory_consumption=64/opcache.memory_consumption=128/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.interned_strings_buffer=4/opcache.interned_strings_buffer=8/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.max_accelerated_files=2000/opcache.max_accelerated_files=2000/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.max_wasted_percentage=5/opcache.max_wasted_percentage=5/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.use_cwd=1/opcache.use_cwd=0/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.validate_timestamps=1/opcache.validate_timestamps=1/' /alidata/server/php/etc/php.ini
  # cache check 5 mins
  sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=300/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.revalidate_path=0/opcache.revalidate_path=0/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.save_comments=1/opcache.save_comments=0/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.load_comments=1/opcache.load_comments=0/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.fast_shutdown=0/opcache.fast_shutdown=1/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.enable_file_override=0/opcache.enable_file_override=1/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.inherited_hack=1/opcache.inherited_hack=1/' /alidata/server/php/etc/php.ini
  sed -i 's/;opcache.dups_fix=0/opcache.dups_fix=0/' /alidata/server/php/etc/php.ini
  # 15 mins cache
  sed -i 's/;opcache.force_restart_timeout=180/opcache.force_restart_timeout=900/' /alidata/server/php/etc/php.ini
  sed -i 's,;opcache.error_log=,opcache.error_log=/alidata/log/php/opcache-error.log,' /alidata/server/php/etc/php.ini
fi
echo "install php extensions ok"
