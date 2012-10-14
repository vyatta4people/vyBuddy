if [ "$(ruby -v | fgrep 1.9.3)" ]; then
  sudo rm -f /usr/bin/ruby
  sudo ln -s /usr/local/rvm/rubies/ruby-1.9.3-head/bin/ruby /usr/bin/ruby
fi