class Asmodai::Daemon
  require 'asmodai/daemon/logging'
  require 'asmodai/daemon/process_management'
  require 'asmodai/daemon/rake_task'  

  attr_accessor :running
  alias :running? :running  
  extend ProcessManagement
  extend RakeTask
  include Logging
  
  class << self
    attr_writer :base_path
    
    def base_path
      @base_path ||= Pathname.new(Dir.pwd)
    end
    
    def set_daemon_name(name)
      @daemon_name=name.to_s.underscore
    end
    
    def daemon_name
      @daemon_name || name.split("::").last.to_s.underscore
    end
    
    def retrieve_class(path, opts={})
      dirname = path
      filename = File.basename(path)
      Dir.chdir(dirname) if dirname != "."
      opts[:class_name] ||= filename.camelize
      $LOAD_PATH.unshift(".")
      require filename

      eval(opts[:class_name])
    end
  end
  
  def daemon_name
    self.class.daemon_name
  end
  
  def initialize
    self.running = false
  end

  def perform_run
    self.running = true
    unless respond_to? :run
      raise ArgumentError.new("#{self.class} does not implement 'run'")
    end
    run
    self.running = false
  end
  
  def start 
    pid = fork do 
      %w(INT TERM).each do |sig|
        trap sig do 
          logger.info { "Received signal #{sig}"}
          self.running = false
        end
      end
      
      $stdin.close
      $stdout.reopen(log_file)
      $stderr.reopen(log_file)
      
      logger.info "Starting up #{daemon_name} at #{Time.now}, pid: #{Process.pid}"
      perform_run
    end
    
    self.class.pid_file_path.open("w") do |f|
      f.puts pid
    end
    
    Process.detach(pid)
  end
end