class Asmodai::CLI < ::Thor
  require 'fileutils'
  
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
    empty_directory "#{name}/script"
    template 'templates/daemon.rb.erb', "#{name}/#{name}.rb"
    copy_file 'templates/Gemfile', "#{name}/Gemfile"
    template 'templates/asmodai.erb', "#{name}/script/asmodai"
    FileUtils.chmod 0755, "#{name}/script/asmodai"
    
  end
  
  desc "install", "Installs startup scripts to /etc/init.d"
  method_option :autostart,
                :type => :boolean,
                :desc => %{If you provide this, startup-links will be generated for the given runlevel. This is currently only supported on Debian/Ubuntu.}
  
  def install
    @info = Asmodai::Info.current
    @asmodai = "asmodai"
    path = "/etc/init.d/#{@info.daemon_name}"
    IO.popen "sudo bash -c \"cat > #{path}; chmod a+x #{path}\"", "r+" do |io|
      template_path = File.join(
        File.dirname(__FILE__), "generator/templates/init_d.erb")

      io.puts ERB.new(File.read(template_path)).result(binding)
      io.close
    end

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
    exec "irb -Ilib -r rubygems -r asmodai -r ./#{klass.daemon_name}"
  end
  
  desc "version", "Prints Asmodai's version and exists"
  def version
    puts "Asmodai version #{Asmodai::VERSION}"
  end
  map %w(-v --version) => :version
end