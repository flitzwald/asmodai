require 'bundler'
Bundler::GemHelper.install_tasks
Bundler.setup
Bundler.require(:default,:test)

namespace :asmodai do
  desc "Runs the unit tests"
  task :test do 
    $LOAD_PATH.unshift(File.dirname(__FILE__))
    Dir['test/*_test.rb'].each do |f|
      require f
    end
  end
end