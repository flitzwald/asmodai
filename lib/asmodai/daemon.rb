class Asmodai::Daemon
  require 'asmodai/daemon/process_management'
  require 'asmodai/daemon/rake_task'  

  extend Asmodai::Logging
  include Asmodai::Logging
  extend ProcessManagement
  extend RakeTask

  class << self
    def autoload_paths
      @autoload_paths ||= []
    end
    
    def set_daemon_name(name)
      @daemon_name=name.to_s.underscore
    end
    
    def daemon_name
      @daemon_name || name.split("::").last.to_s.underscore
    end
  end

  def initialize
  end
  
  def daemon_name
    self.class.daemon_name
  end

  def on_signal(sig)
    # dummy implementation
  end
  
  
  def foreground
    prepare_run
    perform_run
  end
  
  def start 
    prepare_run

    raise 'Fork failed' if (pid=fork) == -1

    if !pid
      Process.setsid

      raise 'Fork failed' if (pid=fork) == -1
      if !pid
        pid = Process.pid

        self.class.pid_file_path.open("w") do |f|
          f.puts pid
        end

        $stdin.reopen('/dev/null')
        $stdout.reopen(log_file)
        $stderr.reopen(log_file)
        logger.info "Starting up #{daemon_name} at #{Time.now}, pid: #{Process.pid}"

        perform_run
      end
    end
  end

  protected

    def prepare_run
      %w(INT TERM).each do |sig|
        trap sig do 
          logger.info { "Received signal #{sig}"}
          on_signal(sig)
        end
      end
      
      
      require 'rubygems'
      require 'bundler'
    
      Bundler.setup
      Bundler.require    
    end
  
    def perform_run
      unless respond_to? :run
        raise ArgumentError.new("#{self.class} does not implement 'run'")
      end
      run
    end
end