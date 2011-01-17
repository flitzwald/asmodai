module Asmodai::Daemon::ProcessManagement
  def pid_file_path
    base_path.join("log/#{daemon_name}.pid")
  end
  
  def pid
    pid_file_path.read.strip.to_i rescue 0
  end
  
  def is_running?
    pid_file_path.exist? and ( Process.kill(0,pid); true ) rescue false
  end
    
  def start
    if is_running?
      false
    else
      self.new.start
      true
    end
  end
  
  def terminate
    if is_running?
      Process.kill('TERM', pid)
      while is_running?
        sleep 0.1
      end
      FileUtils.rm pid_file_path.to_s
      true
    else
      false
    end
  end
end