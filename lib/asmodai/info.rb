require 'pathname'
require 'etc'

class Asmodai::Info
  attr_accessor :path
  
  class << self
    def current
      @current||=self.new
    end
  end
  
  def initialize(path=Asmodai.root)
    self.path = path
  end

  # Returns the name of the daemon which is equal to the
  # name of the directory, the daemon lives in
  def daemon_name
    File.basename(self.path)
  end
  
  # Returns the camelized daemon name
  def daemon_class_name
    daemon_name.camelize
  end
  
  # Returns the class of the Daemon
  def daemon_class
    require "./#{daemon_name}"
    eval(daemon_class_name)
  end
  
  # Returns the generated base file where the daemon class is
  # declared in.
  def base_file
    path.join("#{daemon_name}.rb")
  end
  
  def base_file_owner
    Etc.getpwuid(Pathname.new(base_file).stat.uid)
  end
end
