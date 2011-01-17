module Asmodai::Daemon::RakeTask
  def install_rake_task(namespace)
    daemon = self
    namespace.class_eval do 
      desc "Run the Master server in the background"
      task :start do 
        daemon.start
      end

      desc "Terminate the Master server"
      task :stop do 
        daemon.terminate
      end

      desc "Run the Master server"
      task :run do 
        daemon.new.perform_run
      end
    end
  end
end