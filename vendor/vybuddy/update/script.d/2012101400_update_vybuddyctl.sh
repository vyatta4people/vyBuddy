VYBUDDYCTL_FILE="/usr/local/sbin/vybuddyctl"
sudo cp "${UPDATE_FILE_DIR}/vybuddyctl" "${VYBUDDYCTL_FILE}"
if [ ${?} -ne 0 ]; then
  echo "Failed to copy file: ${VYBUDDYCTL_FILE}"
  exit 1
fi
sudo chown root:root "${VYBUDDYCTL_FILE}"
sudo chmod 0755 "${VYBUDDYCTL_FILE}"
