TMP_CRONTAB_FILE="/tmp/vybuddy-vymasterd-watchdog"

echo "HOME=/home/vybuddy" > "${TMP_CRONTAB_FILE}"
echo "USER=vybuddy" > "${TMP_CRONTAB_FILE}"
echo "SHELL=/bin/bash" > "${TMP_CRONTAB_FILE}"
echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" > "${TMP_CRONTAB_FILE}"
echo "" > "${TMP_CRONTAB_FILE}"
echo "*/5 * * * * vybuddy /usr/local/sbin/vybuddyctl run-script vymasterd-watchdog" > "${TMP_CRONTAB_FILE}"

sudo chown root:root "${TMP_CRONTAB_FILE}"
sudo chmod 0644 "${TMP_CRONTAB_FILE}"
sudo mv "${TMP_CRONTAB_FILE}" /etc/cron.d/
