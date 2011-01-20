require 'thor'
require 'thor/group'
require 'thor/actions'
require 'active_support'
require 'active_support/core_ext'

class Asmodai::CLI < Thor
  include Thor::Actions
  attr_accessor :app_name
  
  def self.source_root
    File.join(File.dirname(__FILE__), "generator")
  end
  
  desc "fitzi", "bammbamm" 
  method_options :hoenzdi => :string
  def fitzi(*params)
    puts params.inspect
  end
  
  desc "new <appname>", "create a new Asmodai-App"
  def new(name)
    @app_name=name
    empty_directory "#{name}/log"
    template 'templates/daemon.rb.erb', "#{name}/#{name}.rb"
    copy_file 'templates/Gemfile', "#{name}/Gemfile"
  end
  
  desc "install", "Installs startup scripts to /etc/init.d"
  def install
    @info = Asmodai::Daemon::Info.new
    path = "/etc/init.d/#{@info.daemon_name}"
    template "templates/init_d.erb", path
    system "chmod a+x #{path}"
  end
  
  def help(*params)
    require 'asmodai/generator'
    case params.first
    when 'new'
      Asmodai::Generator::App.help(shell)
    when 'install'
      Asmodai::Generator::Installer.help(shell)
    else
      super *params
    end
  end
  
  desc "foreground", "Runs the daemon in foreground logging to stdout"
  def foreground
    instance=Asmodai::Daemon.retrieve_class(Dir.pwd).new
    instance.running = true
    instance.perform_run
  end
  
  desc "start", "Runs the daemon in the background"
  def start
    klass = Asmodai::Daemon.retrieve_class(Dir.pwd)
    puts "Starting #{klass.daemon_name}"
    if klass.start
      puts "Ok."
    else
      puts "#{klass.daemon_name} seems to be already running"
    end
  end

  desc "stop", "Stops the daemon"
  def stop
    Asmodai::Daemon.retrieve_class(Dir.pwd).tap do |klass|
      puts "Stopping #{klass.daemon_name}"
      if klass.terminate
        puts "Ok."
      else
        puts "#{klass.daemon_name} doesn't seem to be running."
      end
    end
  end

end