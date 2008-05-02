require File.join(File.dirname(__FILE__), 'test_helper')
         
class MyRange < ActiveRecord::Base
  acts_as_range :begin => :begin, :end => :end
end

class ContainedByTest < Test::Unit::TestCase
  
  def test_contained_by_range_all_defined
    obj = MyRange.new(:acts_as_range_begin => 1, :acts_as_range_end => 2)
    
    [(0..3), (0..2), (1..3), (1..2), (1...2)].each do |range|
      assert obj.contained_by?(range)
    end
    
    [(2..3), (0..1), (3..4)].each do |range|
      assert !obj.contained_by?(range)
    end
  end
  
  def test_contained_by_obj_all_defined
    obj = MyRange.new(:acts_as_range_begin => 1, :acts_as_range_end => 2)
    
    [(0...3), (1...3), (1...2), (0...2)].each do |range|
      target = MyRange.new(:acts_as_range_begin => range.first, :acts_as_range_end => range.last)
      assert obj.contained_by?(target)
    end
    
    [(2...3), (0...1)].each do |range|
      target = MyRange.new(:acts_as_range_begin => range.first, :acts_as_range_end => range.last)
      assert !obj.contained_by?(target)
    end
  end
  
  def test_contained_by_range_source_begin_not_defined
    obj = MyRange.new(:acts_as_range_end => 2)
    
    [(0..2), (3..4)].each do |range|
      assert !obj.contained_by?(range)
    end
  end
  
  def test_contained_by_obj_source_begin_not_defined
    obj = MyRange.new(:acts_as_range_end => 2)
    
    [(0...2), (3...4)].each do |range|
      target = MyRange.new(:acts_as_range_begin => range.first, :acts_as_range_end => range.last)
      assert !obj.contained_by?(target)
    end
  end
  
  def test_contained_by_obj_source_and_target_begin_not_defined
    obj = MyRange.new(:acts_as_range_end => 2)
    
    target = MyRange.new(:acts_as_range_end => 1)
    assert !obj.contained_by?(target)
    
    target = MyRange.new(:acts_as_range_end => 2)
    assert obj.contained_by?(target)
    
    target = MyRange.new(:acts_as_range_end => 3)
    assert obj.contained_by?(target)
  end
  
  def test_contained_by_range_source_end_not_defined
    obj = MyRange.new(:acts_as_range_begin => 2)
    
    [(0..2), (3..4)].each do |range|
      assert !obj.contained_by?(range)
    end
  end
  
  def test_contained_by_obj_source_end_not_defined
    obj = MyRange.new(:acts_as_range_begin => 2)
    
    [(0...2), (3...4)].each do |range|
      target = MyRange.new(:acts_as_range_begin => range.first, :acts_as_range_end => range.last)
      assert !obj.contained_by?(target)
    end
  end
  
  def test_contained_by_obj_source_and_target_end_not_defined
    obj = MyRange.new(:acts_as_range_begin => 2)
    
    target = MyRange.new(:acts_as_range_begin => 1)
    assert obj.contained_by?(target)
    
    target = MyRange.new(:acts_as_range_begin => 2)
    assert obj.contained_by?(target)
    
    target = MyRange.new(:acts_as_range_begin => 3)
    assert !obj.contained_by?(target)
  end
  
  def test_contained_by_range_source_bounds_not_defined
    obj = MyRange.new
    
    [(0..100), (-9999..9999)].each do |range|
      assert !obj.contained_by?(range)
    end
  end
  
  def test_contained_by_obj_source_bounds_not_defined
    obj = MyRange.new
    
    target = MyRange.new(:acts_as_range_end => 9999)
    assert !obj.contained_by?(target)
    
    target = MyRange.new(:acts_as_range_begin => -9999)
    assert !obj.contained_by?(target)
    
    target = MyRange.new(:acts_as_range_begin => -9999, :acts_as_range_end => 9999)
    assert !obj.contained_by?(target)
    
    target = MyRange.new
    assert obj.contained_by?(target)
  end
  
  def test_contained_by_obj_target_bounds_not_defined
    target = MyRange.new
    
    obj = MyRange.new(:acts_as_range_end => 9999)
    assert obj.contained_by?(target)
    
    obj = MyRange.new(:acts_as_range_begin => -9999)
    assert obj.contained_by?(target)
    
    obj = MyRange.new(:acts_as_range_begin => -9999, :acts_as_range_end => 9999)
    assert obj.contained_by?(target)
    
    obj = MyRange.new
    assert obj.contained_by?(target)
  end
  
end