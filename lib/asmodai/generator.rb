require 'erb'

class Asmodai::Generator < Thor::Group
  include Thor::Actions
  argument :name, :type => :string

  def self.source_root
    File.join(File.dirname(__FILE__), "generator")
  end
  
  def create_log_directory
    empty_directory "#{name}/log"
  end

  def create_daemon_file
    template 'templates/daemon.rb.erb', "#{name}/#{name}.rb"
  end
  
  
=begin  
  TEMPLATE_PATH = Pathname.new(
    File.join(File.dirname(__FILE__), "generator/templates"))
  
  def initialize(path)
    segs = path.split '/'
    self.name = segs.pop
    self.directory = segs.empty? ? "." : File.join(*segs)
  end
  
  def paths
    Pathname.new(directory).join(name)
  end
  
  def run
    puts "Creating new daemon in #{path}"
    
    Dir.chdir directory  do 
      mkdir name
      Dir.chdir name do 
        cp TEMPLATE_PATH.join("GemFile").to_s, "./Gemfile"
        mkdir 'log'
        mkdir 'lib'
        open("#{name}.rb", "w") do |f|
          f.puts ERB.new(TEMPLATE_PATH.join("daemon.rb.erb").read).result(binding)
        end
      end
    end
  end
=end
end