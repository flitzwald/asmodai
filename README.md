# Asmodai

## Description

Asmodai is a simple-to-use generator for daemon tasks written in Ruby. It makes 
creating a daemon as straight forward as creating a Rails-application and saves 
you the hassle of boring and repetitive tasks like creating start- and 
stop-scripts, pid-file logic or implementing logging.

## Installation

$ gem install asmodai

## Usage

$ asmodai new foobar
$ cd foobar

Here you will find a dummy implementation:

    class Foobar < Asmodai::Daemon
      attr_accessor :running
      
      def on_signal(sig)
        # perform cleanup or stop an eventloop
        self.running=false
      end
      
      def run
        self.running=true
        while running
          logger.info { "I'm still running" }
          sleep 1
        end
      end
    end

You can develop your daemon by executing 

$ asmodai foreground

This executes the daemon in the foreground and outputs all logging to standard
output. It can be terminated with Ctrl-C.

To start your daemon in the background run

$ asmodai start

Check the status of the daemon

$ asmodai status
  => foobar runs with pid 75952
  
Stop the daemon

$ asmodai stop

## Example: Using Asmodai with EventMachine

$ asmodai new echo
$ cd echo

Edit the Gemfile

    source 'http://rubygems.org'

    gem 'activesupport', ">= 3.0.0"
    gem 'eventmachine'
  
Edit lib/server.rb

    module Echo::Server
      def post_init
        puts "-- someone connected to the echo server!"
      end
    
      def receive_data data
        send_data ">>>you sent: #{data}"
        close_connection if data =~ /quit/i
      end
    
      def unbind
        puts "-- someone disconnected from the echo server!"
      end
    end

Edit echo.rb

    class Echo < Asmodai::Daemon
      require 'server' # lib is automatically added to the $LOAD_PATH
      
      attr_accessor :running
      
      def on_signal(sig)
        EventMachine::stop_event_loop
      end
      
      def run
        EventMachine::run do 
          EventMachine::start_server "127.0.0.1", 8081, Echo::Server
        end
      end
    end





