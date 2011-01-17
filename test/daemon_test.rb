require 'test/test_helper'

class DaemonTest < ActiveSupport::TestCase
  TEST_APP_PATH = Pathname.new(File.join(File.dirname(__FILE__), "test_daemon" ))
  
  class TestDaemon < Asmodai::Daemon
    def run
      while running?
        puts "Still running"
        sleep 0.01
      end
    end
  end
  
  class AnotherTestDaemon < Asmodai::Daemon
    set_daemon_name 'azrael'
  end
  
  TestDaemon.base_path = TEST_APP_PATH

  def setup
    %w(log/test_daemon.log log/test_daemon.pid).map do |e| 
      TEST_APP_PATH.join(e)
    end.each do |p|
      p.delete rescue nil
    end
  end
  
  test "Naming the daemons" do 
    assert_equal "test_daemon", TestDaemon.daemon_name
    assert_equal "azrael", AnotherTestDaemon.daemon_name    
  end
  
  test "Daemon-specific paths" do 
    assert_equal TEST_APP_PATH, TestDaemon.base_path
    assert TestDaemon.log_file_path.to_s.match( /test_daemon\.log$/ )
    assert TestDaemon.pid_file_path.to_s.match( /test_daemon\.pid$/ )    
    assert AnotherTestDaemon.log_file_path.to_s.match( /azrael/ )
    assert AnotherTestDaemon.pid_file_path.to_s.match( /azrael/ )    
  end
  
  test "Starting and stopping the daemons" do 
    assert !TestDaemon.is_running?
    assert !TestDaemon.log_file_path.exist?    
    TestDaemon.start
    assert TestDaemon.is_running?
    assert TestDaemon.pid > 0
    sleep 0.1
    assert TestDaemon.log_file_path.exist?
    TestDaemon.terminate
    assert !TestDaemon.pid_file_path.exist?
    assert TestDaemon.log_file_path.size > 0
    TestDaemon.log_file_path.open do |f|
      assert f.lines.to_a.last.match( /Received signal TERM/)
    end
  end
end