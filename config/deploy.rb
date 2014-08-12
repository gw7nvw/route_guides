# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'route_guides'
set :repo_url, 'git@github.com:gw7nvw/route_guides.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :branch, "master"

# Default deploy_to directory is /var/www/my_app

set :git_shallow_clone, 1

# Default value for :scm is :git
set :scm, :git
set :use_sudo, false
set :deploy_to, "/var/www/html/#{application}"
set :deloy_via, :remote_cache
set :keep_releases, 1
set :rails_env, "production"
set :migrate_target, :latest

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
 
 
role :web, "107.170.182.73"# Your HTTP server, Apache/etc
role :app, "107.170.182.73" # This may be the same as your `Web` server
role :db, "107.170.182.73", :primary => true # This is where Rails migrations will run
 

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
