set :application, "vyBuddy"
set :repository,  "https://github.com/vyatta4people/vyBuddy.git"

set :scm, :git

role :web, "127.0.0.1"                   # Your HTTP server, Apache/etc
role :app, "127.0.0.1"                   # This may be the same as your `Web` server
role :db,  "127.0.0.1", :primary => true # This is where Rails migrations will run

set :branch, "master"
set :deploy_via, :export
set :deploy_to, "/home/vybuddy/rails"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end