module Asmodai::Daemon::Logging
  module ClassMethods
    def log_file_path
      base_path.join("log/#{daemon_name}.log")
    end
  
    def log_file
      @log_file ||= 
        log_file_path.open("a").tap do |r|
          r.sync = true
        end
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |logger|
        logger.formatter = Logger::Formatter.new
      end
    end
  end
  
  module InstanceMethods
    %w(log_file_path log_file logger).each do |method|
      define_method method do 
        self.class.send(method)
      end
    end
  end
  
  def self.included(klass)
    klass.class_eval do 
      extend ClassMethods
      include InstanceMethods
    end
  end
end