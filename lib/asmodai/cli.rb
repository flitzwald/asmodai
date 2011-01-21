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
  
  desc "new <appname>", "create a new Asmodai-App"
  def new(name)
    @app_name=name
    empty_directory "#{name}/log"
    empty_directory "#{name}/lib"    
    template 'templates/daemon.rb.erb', "#{name}/#{name}.rb"
    copy_file 'templates/Gemfile', "#{name}/Gemfile"
  end
  
  desc "install", "Installs startup scripts to /etc/init.d"
  method_option :autostart,
                :type => :boolean,
                :desc => %{If you provide this, startup-links will be generated for the given runlevel. This is currently only supported on Debian/Ubuntu.}
  def install
    @info = Asmodai::Info.current
    path = "/etc/init.d/#{@info.daemon_name}"
    template "templates/init_d.erb", path
    system "chmod a+x #{path}"
    if options[:autostart]
      if (update_bin=`which update-rc.d`.strip).blank?
        warn "update-rc.d was not found. Omitting autostart installation."
      else
        `#{update_bin} #{@info.daemon_name} defaults`
      end
    end
  end
    
  desc "foreground", "Runs the daemon in foreground logging to stdout"
  def foreground
    instance=Asmodai::Info.current.daemon_class.new
    instance.foreground
  end
  
  desc "start", "Runs the daemon in the background"
  def start
    klass = Asmodai::Info.current.daemon_class
    puts "Starting #{klass.daemon_name}"
    if klass.start
      puts "Ok."
    else
      puts "#{klass.daemon_name} seems to be already running"
    end
  end

  desc "stop", "Stops the daemon"
  def stop
    Asmodai::Info.current.daemon_class.tap do |klass|
      puts "Stopping #{klass.daemon_name}"
      if klass.terminate
        puts "Ok."
      else
        puts "#{klass.daemon_name} doesn't seem to be running."
      end
    end
  end

  desc "status", "Prints the current status of the daemon"
  def status
    klass = Asmodai::Info.current.daemon_class
    if !klass.is_running?
      puts "#{klass.daemon_name} doesn't seem to be running"
    else
      puts "#{klass.daemon_name} runs with pid #{klass.pid}"
    end      
  end

  desc "console", "Starts a console with loaded environment"
  def console
    klass = Asmodai::Info.current.daemon_class
    exec "irb -r rubygems -r asmodai -r ./#{klass.daemon_name}"
  end
end