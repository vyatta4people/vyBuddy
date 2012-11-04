# Get rid of misleading error message during update-vybuddy.
echo "set :normalize_asset_timestamps, false" >> "${VYBUDDY_RAILS_CAP_CONFIG_DIR}/deploy.rb"