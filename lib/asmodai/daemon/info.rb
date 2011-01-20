require 'pathname'
require 'etc'

class Asmodai::Daemon::Info
  attr_accessor :path
  
  def initialize(path=Dir.pwd)
    self.path = path
  end
  
  def daemon_name
    File.basename(self.path)
  end
  
  def base_file
    File.join(path, "#{daemon_name}.rb")
  end
  
  def base_file_owner
    Etc.getpwuid(Pathname.new(base_file).stat.uid)
  end
end
