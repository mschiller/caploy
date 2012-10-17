Capistrano::Configuration.instance.load do

  desc "tail production log files"
  task :tail_logs, :roles => :app do
    run "tail -f #{shared_path}/log/*.log" do |channel, stream, data|
      trap("INT") { puts 'Interupted'; exit 0; }
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end
end
