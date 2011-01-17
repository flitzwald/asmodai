$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "../lib"))

require 'test/unit'
require 'active_support/test_case'
require 'asmodai'

ASMODAI_APP_ROOT = Pathname.new(File.join(File.dirname(__FILE__), ".."))
