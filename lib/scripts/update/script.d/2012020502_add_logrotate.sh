sudo cp ./lib/scripts/update/files/vybuddy-rails /etc/logrotate.d/
if [ ${?} -ne 0 ]; then
  echo "Failed to copy file: /etc/logrotate.d/vybuddy-rails"
  exit 1
fi
sudo chown root:root /etc/logrotate.d/vybuddy-rails
sudo chmod 0644 /etc/logrotate.d/vybuddy-rails
