Capistrano::Configuration.instance.load do

  namespace :memcache do
    %(start stop restart status).each do |step|
      desc "#{step} memcache"
      task step do
        try_sudo "service memcached #{step}"
      end
    end

    desc "Flush memcache"
    task :flush do
      run %Q{echo "flush_all" | nc -q 2 127.0.0.1 11211}
    end

    after "deploy:restart", "memcache:flush"
    after "deploy:start", "memcache:flush"
  end

end
