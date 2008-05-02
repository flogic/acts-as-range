require File.join(File.dirname(__FILE__), 'test_helper')
         
class MyRange < ActiveRecord::Base
  acts_as_range :begin => :begin, :end => :end
end

class BeforeAfterTest < Test::Unit::TestCase
    
  def test_before_without_end_is_false
    obj = MyRange.new
    assert !obj.before?(5)
  end
  
  def test_before_nothing_is_false
    [90,4,1,-5].each do |ending|
      obj = MyRange.new(:acts_as_range_end => ending)
      assert !obj.before?(nil)
    end
  end
  
  def test_before_point
    obj = MyRange.new(:acts_as_range_end => 4)
    assert !obj.before?(3)
    assert !obj.before?(4)
    assert  obj.before?(5)
  end
  
  def test_before_object
    obj = MyRange.new(:acts_as_range_end => 4)
    
    target = MyRange.new(:acts_as_range_begin => 3)
    assert !obj.before?(target)
    
    target = MyRange.new(:acts_as_range_begin => 4)
    assert !obj.before?(target)
    
    target = MyRange.new(:acts_as_range_begin => 5)
    assert obj.before?(target)
  end
  
  def test_after_without_beginning_is_false
    obj = MyRange.new
    assert !obj.after?(5)
  end
  
  def test_after_nothing_is_false
    [-5,1,4,90].each do |beginning|
      obj = MyRange.new(:acts_as_range_begin => beginning)
      assert !obj.after?(nil)
    end
  end
  
  def test_after_point
    obj = MyRange.new(:acts_as_range_begin => 4)
    assert  obj.after?(3)
    assert !obj.after?(4)
    assert !obj.after?(5)
  end
  
  def test_after_object
    obj = MyRange.new(:acts_as_range_begin => 4)
    
    target = MyRange.new(:acts_as_range_end => 3)
    assert obj.after?(target)
    
    target = MyRange.new(:acts_as_range_end => 4)
    assert !obj.after?(target)
    
    target = MyRange.new(:acts_as_range_end => 5)
    assert !obj.after?(target)
  end

end
