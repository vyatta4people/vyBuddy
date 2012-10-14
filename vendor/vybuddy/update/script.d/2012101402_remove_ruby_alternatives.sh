if [ "$(ruby -v | fgrep 1.9.3)" ]; then
  sudo update-alternatives --remove-all ruby
fi
exit 0