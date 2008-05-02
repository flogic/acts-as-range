require File.join(File.dirname(__FILE__), 'test_helper')
         
class MyRange < ActiveRecord::Base
  acts_as_range :begin => :begin, :end => :end
end

class OverlappingTest < Test::Unit::TestCase
  
end