require 'pathname'
require 'logger'

module Asmodai
  class << self
    attr_accessor :root
    
    def log_file_path
      @log_file_path ||=
        Asmodai.root.join("log/#{Asmodai::Info.current.daemon_name}.log")
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
  
  require 'thor'
  require 'thor/actions'
  require 'thor/group'  
  require 'asmodai/info'  
  require 'asmodai/logging'
  require 'asmodai/daemon'
  require 'asmodai/version'
  require 'asmodai/cli'
end