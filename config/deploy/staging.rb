set :stage, :staging
set :branch, "master"

# used in case we're deploying multiple versions of the same
# app side by side. Also provides quick sanity checks when looking
# at filepaths
set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"
set :server_name, "www.powerful-chamber-1551.herokuapp.com"

server 'www.powerful-chamber-1551.herokuapp.com', user: 'deploy', roles: %w{web app db}, primary: true
server 'ds031701-a.mongolab.com:31701 ', user: 'deploy', roles: %w{db}, primary: true

set :deploy_to, "/home/#{fetch(:deploy_user)}/apps/#{fetch(:full_app_name)}"

# dont try and infer something as important as environment from
# stage name.
set :rails_env, :production

# number of unicorn workers, this will be reflected in
# the unicorn.rb and the monit configs
set :unicorn_worker_count, 5

# whether we're using ssl or not, used for building nginx
# config file
set :enable_ssl, false