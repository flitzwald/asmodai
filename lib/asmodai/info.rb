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
  
  def call_wrapper(argument)
    command="#{ruby_exe_path} ./script/asmodai #{argument}"
    function_body=<<-FUNCTION_END
do_#{argument}() {
	cd #{path}
	sudo -u #{base_file_owner.name} bash -c "GEM_HOME=#{gem_home} #{command}"
}  
FUNCTION_END
  end
  
  def wrapped_commands
    %w(start stop reopen foreground)
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

  def ruby_exe_path
    File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name']).
      sub(/.*\s.*/m, '"\&"')
  end
  
  def gem_home
    if (path=ENV['GEM_HOME']).blank?
      path=Gem.dir
    end
    path
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
