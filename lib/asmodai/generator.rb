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

  def copy_gem_file
    copy_file 'templates/Gemfile', "#{name}/Gemfile"
  end
end