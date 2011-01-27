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
  
  def rvm_environment?
    !rvm_ruby_string.empty? || ENV['GEM_PATH']
  end
  
  def rvm_ruby_string
    execute_sudo_checked("env | grep rvm_ruby_string | grep -v SUDO").strip
  end
  
  def rvm_path
    execute_sudo_checked(
      "env | grep rvm_path | grep -v SUDO").strip.split("=").last
  end
  
  def rvm_wrapper_path
    File.join(rvm_path, "bin/bootup_asmodai")
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

  # Return the sudoer if present, false otherwise
  def run_as_sudo?
    if ENV['USER']=='root' and (su=ENV['SUDO_USER'])
      su
    else
      false
    end
  end
  
  # Executes cmd in the context of the user, even if asmodai
  # is called sudoed
  def execute_sudo_checked(cmd)
    if (su=run_as_sudo?)
      `sudo -u #{su} bash -l -c '#{cmd}'`.strip
    else
      `#{cmd}`.strip
    end
  end
end
