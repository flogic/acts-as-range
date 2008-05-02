require File.join(File.dirname(__FILE__), 'test_helper')
         
class MyRange < ActiveRecord::Base
  acts_as_range :begin => :begin, :end => :end
end

class MyRangeTest < Test::Unit::TestCase
  fixtures :my_ranges
  
  @@t = FixedTime.time
              
  def test_create
    range = MyRange.new(:title => 'foo', :begin => 4, :end => 6)
    assert range.save, range.errors.full_messages.join('\n')
    assert MyRange.find(:all).include?(range)
  end
  
  def test_create_open_intervals
    range = MyRange.new(:title => 'foo', :begin => nil, :end => nil)
    assert range.save, range.errors.full_messages.join("\n")
    assert MyRange.find(:all).include?(range)
  end            
  
  def test_update
    range = my_ranges(:surrounding_year)
    range.end = nil
    assert range.save, range.errors.full_messages.join("\n") 
    assert MyRange.find(range.id, :on => 20.years.from_now.to_i)
    range.begin = nil
    assert range.save, range.errors.full_messages.join("\n") 
    assert MyRange.find(range.id, :on => 20.years.ago.to_i)    
  end
  
  def test_begin_after_end
    range = MyRange.create(:title => 'foo', :begin => 10, :end => 9)
    assert ! range.save

    range = MyRange.create(:title => 'foo', :begin => nil, :end => nil)
    assert range.save, range.errors.full_messages.join("\n")

    range = MyRange.create(:title => 'foo', :begin => 10, :end => nil)
    assert range.save, range.errors.full_messages.join("\n")

    range = MyRange.create(:title => 'foo', :begin => nil, :end => 9)
    assert range.save, range.errors.full_messages.join("\n")
  end                      
  
  def test_begin_after_end_save_change
    range = my_ranges(:surrounding_year)
    range.begin = 1.year.from_now.to_i
    assert ! range.save
  end

  def test_normal_find
    all = MyRange.find(:all)
    assert_equal @loaded_fixtures['my_ranges'].length, all.length
  end                 
  
  def test_normal_destroy     
    the_id = my_ranges(:contained).id
    assert_difference MyRange, :count, -1 do
      MyRange.destroy(the_id)
    end                                
    assert_raise(ActiveRecord::RecordNotFound) { MyRange.find(the_id) }
  end

  def test_range_find_on
    future = MyRange.find(:all, :on => 3.years.from_now(@@t).to_i)
    assert_equal 5, future.length
    assert future.include?(my_ranges(:containing))
  end
  
  def test_range_find_first_on_closed_intervals
    assert_equal 13, MyRange.find(:first, :on => 1.months.since(3.years.since(@@t)).to_i, 
                                  :conditions => 'begin is not null and my_ranges.end is not null' ).id
  end
  
  def test_range_find_contained_intervals
    contained = MyRange.find(:all, :contain => 18.months.from_now(@@t).to_i .. 19.months.from_now(@@t).to_i)
    assert_equal 5, contained.length
    assert contained.include?(MyRange.find(8, :on => 18.months.from_now(@@t).to_i))
  end

  def test_range_find_contained_intervals_with_obj
    target = MyRange.find(1, :on => @@t.to_i)
    contained = MyRange.find(:all, :contain => target)
    assert_equal 3, contained.length
    assert contained.include?(MyRange.find(6, :on => @@t.to_i ))
  end

  def test_range_find_contained_by_intervals
    contained = MyRange.find(:all, :contained_by => 13.months.ago(@@t).to_i .. 13.months.from_now(@@t).to_i)
    assert_equal 3, contained.length
    assert contained.include?(MyRange.find(1, :on => @@t.to_i ))
  end

  def test_range_find_contained_by_intervals_with_obj
    target = MyRange.find(13, :on => 4.years.from_now(@@t).to_i)
    contained = MyRange.find(:all, :contained_by => target)
    assert_equal 1, contained.length
    assert contained.include?(MyRange.find(14, :on => 50.months.from_now(@@t).to_i ))
  end

  def test_range_find_overlapping_intervals
    overlapping = MyRange.find(:all, :overlapping => 1.month.ago(@@t).to_i .. 1.month.from_now(@@t).to_i)
    assert_equal 8, overlapping.length
    assert overlapping.include?(MyRange.find(1, :on => @@t.to_i ))
  end

  def test_range_find_overlapping_intervals_with_obj
    target = MyRange.find(1, :on => @@t.to_i)
    overlapping = MyRange.find(:all, :overlapping => target)
    assert_equal 7, overlapping.length
    assert overlapping.include?(MyRange.find(3, :on => @@t.to_i ))
  end
  
  def test_range_find_overlapping_obj_open_right
    target = MyRange.find(5, :on => 13.months.from_now(@@t).to_i)
    overlapping = MyRange.find(:all, :overlapping => target)
    assert_equal 6, overlapping.length
    assert overlapping.include?(MyRange.find(8, :on => 18.months.from_now(@@t).to_i)) 
    overlapping = MyRange.find(:all, :overlapping => [target.begin, target.end])
    assert_equal 7, overlapping.length
  end

  def test_range_find_overlapping_obj_open_left
    target = MyRange.find(2, :on => 13.months.ago(@@t).to_i)
    overlapping = MyRange.find(:all, :overlapping => target)
    assert_equal 7, overlapping.length
    assert overlapping.include?(MyRange.find(15, :on => 4.years.ago(@@t).to_i)) 
  end

  def test_range_find_overlapping_obj_open_both
    target = MyRange.find(6, :on => @@t.to_i)
    overlapping = MyRange.find(:all, :overlapping => target)               
    assert_equal @loaded_fixtures['my_ranges'].length - 1, overlapping.length
    assert overlapping.include?(MyRange.find(1, :on => @@t.to_i))
  end
  
  def test_range_find_contained_by_obj_open_right
    target = MyRange.find(9, :on => 13.months.from_now(@@t).to_i)
    contained = MyRange.find(:all, :contained_by => target)
    assert_equal 5, contained.length
    assert contained.include?(MyRange.find(5, :on => 4.years.from_now(@@t).to_i)) 
  end

  def test_range_find_contained_by_obj_open_left
    target = MyRange.find(10, :on => 13.months.ago(@@t).to_i)
    contained = MyRange.find(:all, :contained_by => target)
    assert_equal 4, contained.length
    assert contained.include?(MyRange.find(2, :on => 4.years.ago(@@t).to_i)) 
  end

  def test_range_find_contained_by_obj_open_both
    target = MyRange.find(6, :on => @@t.to_i)
    contained = MyRange.find(:all, :contained_by => target)
    assert_equal @loaded_fixtures['my_ranges'].length - 1, contained.length
    assert contained.include?(MyRange.find(1, :on => @@t.to_i))
  end
  
  def test_range_find_contained_obj_open_right
    target = MyRange.find(5, :on => 13.months.from_now(@@t).to_i)
    contained = MyRange.find(:all, :contain => target)
    assert_equal 3, contained.length
    assert contained.include?(MyRange.find(4, :on => 18.months.from_now(@@t).to_i)) 
  end

  def test_range_find_contained_obj_open_left
    target = MyRange.find(2, :on => 13.months.ago(@@t).to_i)
    contained = MyRange.find(:all, :contain => target)
    assert_equal 3, contained.length
    assert contained.include?(MyRange.find(10, :on => 4.years.ago(@@t).to_i)) 
  end

  def test_range_find_contained_obj_open_both
    target = MyRange.find(6, :on => @@t.to_i)
    contained = MyRange.find(:all, :contain => target)
    assert_equal 0, contained.length
  end         
  
  def test_range_include?          
    interval = MyRange.find(1, :on => @@t.to_i)
    assert interval.include?(@@t.to_i), interval.inspect
    assert interval.include?(5.months.from_now(@@t).to_i)
    assert interval.include?(5.months.ago(@@t).to_i)    
    assert ! interval.include?(7.months.from_now(@@t).to_i)
    assert ! interval.include?(7.months.ago(@@t).to_i)

    interval = MyRange.find(6, :on => @@t.to_i)
    assert interval.include?(@@t.to_i)
    assert interval.include?(20.years.from_now(@@t).to_i)
    assert interval.include?(20.years.ago(@@t).to_i)
    
    interval = MyRange.find(9, :on => 1.year.from_now(@@t).to_i)
    assert interval.include?(6.months.from_now(@@t).to_i)
    assert interval.include?(20.years.from_now(@@t).to_i)
    assert ! interval.include?(1.day.ago(@@t).to_i)
    assert ! interval.include?(20.years.ago(@@t).to_i)
    
    interval = MyRange.find(10, :on => 1.year.ago(@@t).to_i)
    assert interval.include?(6.months.ago(@@t).to_i)
    assert interval.include?(20.years.ago(@@t).to_i)
    assert ! interval.include?(1.day.from_now(@@t).to_i)
    assert ! interval.include?(20.years.from_now(@@t).to_i)
  end         
  
  def test_conditions_on
    target = MyRange.find(:all, :conditions => ['title = ?', 'this surrounding year'], :on => @@t.to_i)
    assert_equal 1, target.length
    assert_equal 'this surrounding year', target.first.title
  end
  
  def test_conditions_containing
    target = MyRange.find(:all, :conditions => ['title = ?', 'the alpha + omega, etc., etc.'], :contain => 6.months.ago(@@t).to_i .. 6.months.from_now(@@t).to_i)
    assert_equal 1, target.length
    assert_equal 'the alpha + omega, etc., etc.', target.first.title
  end
  
  def test_conditions_contained_by
    target = MyRange.find(:all, :conditions => ['title = ?', 'this surrounding year'], :contained_by => [nil, nil])
    assert_equal 1, target.length
    assert_equal 'this surrounding year', target.first.title
  end
  
  def test_conditions_overlapping
    target = MyRange.find(:all, :conditions => ['title = ?', 'this surrounding year'], :overlapping => @@t.to_i .. 1.day.from_now(@@t).to_i)
    assert_equal 1, target.length
    assert_equal 'this surrounding year', target.first.title
  end     
  
  def test_before
    target = MyRange.find(:all, :before => @@t.to_i)
    assert_equal 4, target.length
    assert ! target.include?(MyRange.find(1, :on => @@t.to_i))
    assert target.include?(MyRange.find(15, :on => 4.years.ago(@@t).to_i))
  end
  
  def test_after      
    target = MyRange.find(:all, :after => @@t.to_i)
    assert_equal 4, target.length
    assert ! target.include?(MyRange.find(1, :on => @@t.to_i))
    assert target.include?(MyRange.find(13, :on => 4.years.from_now(@@t).to_i))
  end
  
  def test_impossible_find_first
    assert MyRange.find(:first, :conditions => '1=0', :overlapping => [13.months.ago(@@t).to_i, 1.day.from_now(@@t).to_i]).nil?
  end
end