UPDATE_VYBUDDY_FILE="/usr/local/sbin/update-vybuddy"
sudo cp "${UPDATE_FILE_DIR}/update-vybuddy" "${UPDATE_VYBUDDY_FILE}"
if [ ${?} -ne 0 ]; then
  echo "Failed to copy file: ${UPDATE_VYBUDDY_FILE}"
  exit 1
fi
sudo chown root:root "${UPDATE_VYBUDDY_FILE}"
sudo chmod 0755 "${UPDATE_VYBUDDY_FILE}"
