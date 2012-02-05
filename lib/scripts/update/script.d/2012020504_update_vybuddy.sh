sudo cp ./lib/scripts/update/files/update-vybuddy /usr/local/sbin/
if [ ${?} -ne 0 ]; then
  echo "Failed to copy file: /usr/local/sbin/update-vybuddy"
  exit 1
fi
sudo chown root:root /usr/local/sbin/update-vybuddy
sudo chmod 0755 /usr/local/sbin/update-vybuddy
