namespace :redis do

  desc "Install redis"
  task :install do
    ["#{sudo} rm -r /tmp/redis",
     "#{sudo} rm /usr/local/bin/redis-*",
     "git clone git://github.com/antirez/redis.git /tmp/redis",
     "cd /tmp/redis && git pull",
     "cd /tmp/redis && git checkout v2.0.4-stable",
     "cd /tmp/redis && make clean",
     "cd /tmp/redis && make",
     "cd /tmp/redis && #{sudo} make install",
     "#{sudo} cp /tmp/redis/redis.conf /etc/",
     "#{sudo} sed -i 's/daemonize no/daemonize yes/' /etc/redis.conf",
     "#{sudo} sed -i 's/# bind 127.0.0.1/bind 127.0.0.1/' /etc/redis.conf"
    ].each {|cmd| run cmd}
  end

  desc "Start the Redis server"
  task :start do
    run "redis-server /etc/redis.conf"
  end

  desc "Stop the Redis server"
  task :stop do
    run 'echo "SHUTDOWN" | nc localhost 6379'
    #sudo 'kill `cat /var/run/redis.pid`'
  end

  desc "Restart the Redis server"
  task :restart do
    redis.stop
    sleep(1)
    redis.start
  end

end

