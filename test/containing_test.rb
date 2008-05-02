require File.join(File.dirname(__FILE__), 'test_helper')
         
class MyRange < ActiveRecord::Base
  acts_as_range :begin => :begin, :end => :end
end

class ContainingTest < Test::Unit::TestCase
  
  def test_containing_range_or_point_all_defined
    obj = MyRange.new(:acts_as_range_begin => 1, :acts_as_range_end => 5)
    
    [(1..4), (2..3), (1...5), (2...5), 1, 2, 2.5, 4].each do |target|
      assert obj.containing?(target)
    end
    
    [(0..1), (1..6), (1..5), (2..5), 5, 0].each do |target|
      assert !obj.containing?(target)
    end
  end
  
  def test_containing_obj_all_defined
    obj = MyRange.new(:acts_as_range_begin => 1, :acts_as_range_end => 5)
    
    [(2...3), (1...3), (1...5)].each do |range|
      target = MyRange.new(:acts_as_range_begin => range.first, :acts_as_range_end => range.last)
      assert obj.containing?(target)
    end
    
    [(3...6), (0...1), (0...2), (0...6)].each do |range|
      target = MyRange.new(:acts_as_range_begin => range.first, :acts_as_range_end => range.last)
      assert !obj.containing?(target)
    end
  end
  
  def test_containing_range_or_point_source_begin_not_defined
    obj = MyRange.new(:acts_as_range_end => 5)
    
    [(1..4), (0..3), (-999...5), (2...5), 1, 2, 2.5, 4, 0, -99].each do |target|
      assert obj.containing?(target)
    end
    
    [(1..5), (3..6), 5, 6, 100].each do |target|
      assert !obj.containing?(target)
    end
  end
  
  def test_containing_obj_source_begin_not_defined
    obj = MyRange.new(:acts_as_range_end => 5)
    
    [(1...4), (0...3), (-999...5), (2...5)].each do |range|
      target = MyRange.new(:acts_as_range_begin => range.first, :acts_as_range_end => range.last)
      assert obj.containing?(target)
    end
    
    [(3...6), (6...8)].each do |range|
      target = MyRange.new(:acts_as_range_begin => range.first, :acts_as_range_end => range.last)
      assert !obj.containing?(target)
    end
  end
  
  def test_containing_range_or_point_source_end_not_defined
    obj = MyRange.new(:acts_as_range_begin => 1)
    
    [(1..4), (3..6), (5..999), 1, 2, 2.5, 4, 1024].each do |target|
      assert obj.containing?(target)
    end
    
    [(0..5), (-50..-25), 0, -100].each do |target|
      assert !obj.containing?(target)
    end
  end
  
  def test_containing_obj_source_end_not_defined
    obj = MyRange.new(:acts_as_range_begin => 1)
    
    [(1...4), (3...6), (5...9999)].each do |range|
      target = MyRange.new(:acts_as_range_begin => range.first, :acts_as_range_end => range.last)
      assert obj.containing?(target), range
    end
    
    [(0...6), (-50...-25)].each do |range|
      target = MyRange.new(:acts_as_range_begin => range.first, :acts_as_range_end => range.last)
      assert !obj.containing?(target), range
    end
  end
  
  def test_containing_obj_source_and_target_begin_not_defined
    obj = MyRange.new(:acts_as_range_end => 2)
    
    target = MyRange.new(:acts_as_range_end => 1)
    assert obj.containing?(target)
    
    target = MyRange.new(:acts_as_range_end => 2)
    assert obj.containing?(target)
    
    target = MyRange.new(:acts_as_range_end => 3)
    assert !obj.containing?(target)
  end
  
  def test_containing_obj_source_and_target_end_not_defined
    obj = MyRange.new(:acts_as_range_begin => 2)
    
    target = MyRange.new(:acts_as_range_begin => 1)
    assert !obj.containing?(target)
    
    target = MyRange.new(:acts_as_range_begin => 2)
    assert obj.containing?(target)
    
    target = MyRange.new(:acts_as_range_begin => 3)
    assert obj.containing?(target)
  end
  
  def test_containing_range_source_bounds_not_defined
    obj = MyRange.new
    
    [(1..2), (5..9999), (-9999..-50), (-9999..9999)].each do |range|
      assert obj.containing?(range)
    end
  end
  
  def test_containing_obj_source_bounds_not_defined
    obj = MyRange.new
    
    [(1...2), (5...9999), (-9999...-50), (-9999...9999)].each do |range|
      target = MyRange.new(:acts_as_range_begin => range.first, :acts_as_range_end => range.end)
      assert obj.containing?(target)
    end
  end

  def test_containing_obj_target_bounds_not_defined
    obj = MyRange.new(:acts_as_range_begin => 1, :acts_as_range_end => 5)
    
    [4,5,6].each do |end_point|
      target = MyRange.new(:acts_as_range_end => end_point)
      assert !obj.containing?(target)
    end
    
    [0,1,2].each do |begin_point|
      target = MyRange.new(:acts_as_range_begin => begin_point)
      assert !obj.containing?(target)
    end
    
    target = MyRange.new
    assert !obj.containing?(target)
  end
  
  def test_containing_obj_source_and_target_bounds_not_defined
    obj = MyRange.new
    target = MyRange.new
    assert obj.containing?(target)
  end
  
end