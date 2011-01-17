require 'thor'
require 'thor/group'
require 'thor/actions'
require 'active_support'
require 'active_support/core_ext'

class Asmodai::CLI < Thor
  desc "new <appname>", "create a new Asmodai-App"
  def new(path)
    require 'asmodai/generator'
    args = ARGV.clone
    args.shift
    Asmodai::Generator.start(args)
  end
  
  desc "foreground", "Runs the daemon in foreground logging to stdout"
  def foreground
    Asmodai::Daemon.retrieve_class(Dir.pwd).new.perform_run
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