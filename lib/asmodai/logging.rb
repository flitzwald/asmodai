module Asmodai::Logging
  %w(log_file_path log_file logger).each do |method|
    define_method method do 
      Asmodai.send(method)
    end
  end
end