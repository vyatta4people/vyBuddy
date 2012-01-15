#!/bin/bash
#
# Custom update script
#
UPDATE_DIR="${VYBUDDY_RAILS_APP_DIR}/lib/scripts/update"
UPDATE_SCRIPT_DIR="${UPDATE_DIR}/script.d"

CACHE_DIR="${VYBUDDY_ROOT}/cache"
CACHE_SCRIPT_DIR="${CACHE_DIR}/script.d"

BASH_EXEC="/bin/bash"

DATABASE_YML="${VYBUDDY_RAILS_CAP_CONFIG_DIR}/database.yml"
SQL_HOST="$(grep host: "${DATABASE_YML}" | awk '{print $NF}')"
SQL_USER="$(grep username: "${DATABASE_YML}" | awk '{print $NF}')"
SQL_PASS="$(grep password: "${DATABASE_YML}" | awk '{print $NF}')"
SQL_DB="$(grep database: "${DATABASE_YML}" | awk '{print $NF}')"
SQL_EXEC="/usr/bin/mysql -h${SQL_HOST} -u${SQL_USER} -p${SQL_PASS} ${SQL_DB}"

if [ ! -d "${CACHE_SCRIPT_DIR}" ]; then
  mkdir "${CACHE_SCRIPT_DIR}"
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
