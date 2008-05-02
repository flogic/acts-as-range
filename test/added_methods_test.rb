require File.join(File.dirname(__FILE__), 'test_helper')
         
class MyRange < ActiveRecord::Base
  acts_as_range :begin => :begin, :end => :end
end

class AddedMethodsTest < Test::Unit::TestCase
  # it is to be hoped this will be the last of explicitly using
  # 'begin' and 'end' simply because this class is known
  def test_added_generic_methods
    obj = MyRange.new(:begin => 5, :end => 10)
    
    assert obj.class.respond_to?(:acts_as_range_begin_attr)
    assert_equal :begin, obj.class.acts_as_range_begin_attr
    
    assert obj.class.respond_to?(:acts_as_range_end_attr)
    assert_equal :end, obj.class.acts_as_range_end_attr
    
    assert obj.respond_to?(:acts_as_range_begin)
    assert_equal obj.begin, obj.acts_as_range_begin
    
    assert obj.respond_to?(:acts_as_range_end)
    assert_equal obj.end, obj.acts_as_range_end
    
    assert obj.respond_to?(:acts_as_range_begin=)
    begin_test = rand(100)
    obj.acts_as_range_begin = begin_test
    assert_equal begin_test, obj.begin
    
    assert obj.respond_to?(:acts_as_range_end=)
    end_test = rand(100)
    obj.acts_as_range_end = end_test
    assert_equal end_test, obj.end
  end
  
  def test_to_range
    obj = MyRange.new(:acts_as_range_begin => 5, :acts_as_range_end => 10)
    assert_equal 5...10, obj.to_range
  end
  
  def test_to_range_error_with_either_open_end
    obj = MyRange.new(:acts_as_range_begin => 5)
    assert_raises(ArgumentError) { obj.to_range }
    
    obj = MyRange.new(:acts_as_range_end => 5)
    assert_raises(ArgumentError) { obj.to_range }
  end
end
