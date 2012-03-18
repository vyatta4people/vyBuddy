#!/bin/bash
#
# vyBuddy custom update script
#
export UPDATE_DIR="${VYBUDDY_RAILS_APP_DIR}/vendor/vybuddy/update"
export UPDATE_SCRIPT_DIR="${UPDATE_DIR}/script.d"
export UPDATE_FILE_DIR="${UPDATE_DIR}/file.d"

export CACHE_DIR="${VYBUDDY_ROOT}/cache"
export CACHE_SCRIPT_DIR="${CACHE_DIR}/script.d"
export CACHE_SQL_BCKP_DIR="${CACHE_DIR}/sql-backups"

BASH_EXEC="/bin/bash"

DATABASE_YML="${VYBUDDY_RAILS_CAP_CONFIG_DIR}/database.yml"
SQL_HOST="$(grep host: "${DATABASE_YML}" | awk '{print $NF}')"
SQL_USER="$(grep username: "${DATABASE_YML}" | awk '{print $NF}')"
SQL_PASS="$(grep password: "${DATABASE_YML}" | awk '{print $NF}')"
SQL_DB="$(grep database: "${DATABASE_YML}" | awk '{print $NF}')"
SQL_OPTS="-h${SQL_HOST} -u${SQL_USER} -p${SQL_PASS} ${SQL_DB}"
SQL_EXEC="/usr/bin/mysql ${SQL_OPTS}"
SQL_BCKP="/usr/bin/mysqldump ${SQL_OPTS}"
SQL_BCKP_FILE="${CACHE_SQL_BCKP_DIR}/$(date +%Y%m%d%H%M%S)-${RANDOM}.sql.gz"

if [ ! -d "${CACHE_SCRIPT_DIR}" ]; then
  mkdir "${CACHE_SCRIPT_DIR}"
fi

if [ ! -d "${CACHE_SQL_BCKP_DIR}" ]; then
  mkdir "${CACHE_SQL_BCKP_DIR}"
fi

${SQL_BCKP} | gzip > "${SQL_BCKP_FILE}"
if [ ${?} -ne 0 ]; then
  echo "*** FATAL: Can not backup DB to ${SQL_BCKP_FILE}"
  exit 1
fi

UPDATE_SCRIPTS=$(ls -1 "${UPDATE_SCRIPT_DIR}")
for UPDATE_SCRIPT in ${UPDATE_SCRIPTS}; do
  if [ ! -f "${CACHE_SCRIPT_DIR}/${UPDATE_SCRIPT}" ]; then
    SCRIPT_EXT=$(echo "${UPDATE_SCRIPT}" | sed 's/.*\.//')
    case ${SCRIPT_EXT} in
      "sql")SCRIPT_EXEC="${SQL_EXEC}";;
      *)SCRIPT_EXEC="${BASH_EXEC}";;
    esac
    ${SCRIPT_EXEC} < "${UPDATE_SCRIPT_DIR}/${UPDATE_SCRIPT}"
    if [ ${?} -eq 0 ]; then
      cp "${UPDATE_SCRIPT_DIR}/${UPDATE_SCRIPT}" "${CACHE_SCRIPT_DIR}/"
      echo "OK: ${UPDATE_SCRIPT}"
    else
      echo "FAIL: ${UPDATE_SCRIPT}"
    fi
  fi
done
