desc 'Tail application log'
task :tail_logs do
  on roles (:app) do
    tail "#{shared_path}/log/#{fetch(:rails_env)}.log"
  end
end

def with_verbosity(output_verbosity)
  old_verbosity = SSHKit.config.output_verbosity
  begin
    SSHKit.config.output_verbosity = output_verbosity
    yield
  ensure
    SSHKit.config.output_verbosity = old_verbosity
  end
end

def tail(path)
  with_verbosity(Logger::DEBUG) do
    execute "tail -f #{path}"
  end
end
