LOGROTATE_FILE="/etc/logrotate.d/vybuddy-rails"
sudo cp "${UPDATE_FILE_DIR}/vybuddy-rails" "${LOGROTATE_FILE}"
if [ ${?} -ne 0 ]; then
  echo "Failed to copy file: ${LOGROTATE_FILE}"
  exit 1
fi
sudo chown root:root "${LOGROTATE_FILE}"
sudo chmod 0644 "${LOGROTATE_FILE}"
