
env = ENV["RAILS_ENV"] || "production"

worker_processes 4

preload_app true

timeout 30

pid "/tmp/unicorn.thestore.pid"

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
