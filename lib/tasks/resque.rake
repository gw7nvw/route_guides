require 'resque/tasks'
require 'resque/scheduler/tasks'
task "resque:preload" => :environment
namespace :resque do
  task :setup do
    require 'resque'
    Resque.redis = 'localhost:6379'
  end
task :setup_schedule => :setup do
    require 'resque-scheduler'
    require 'resque/scheduler/server'
    Resque.schedule = YAML.load_file('config/resque_schedule.yml')
  end
task :scheduler => :setup_schedule
end
