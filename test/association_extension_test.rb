require File.join(File.dirname(__FILE__), 'test_helper')
         
class Widget < ActiveRecord::Base
  has_many :thing_widgets
  has_many :things, :through => :thing_widgets, :extend => [Centerstone::AssociationExtensions::Ranged, Centerstone::AssociationExtensions::DateRanged]
  # belongs_to :thing # ???
end               

class ThingWidget < ActiveRecord::Base
  belongs_to :thing
  belongs_to :widget
end

class Thing < ActiveRecord::Base
  acts_as_date_range :begin => :start, :end => :stop
  has_many :thing_widgets
  has_many :widgets, :through => :thing_widgets
end

class AssociationExtensionTest < Test::Unit::TestCase
  fixtures :my_ranges, :things, :widgets, :thing_widgets
  
  @@t = FixedTime.time
  
  def test_truth
    assert true
  end
  
  def test_things_plan
    w = Widget.find(1)
    
    assert_equal 4, w.things.length
  end
  
  def test_things_current
    w = Widget.find(1)
    
    assert_equal 1, w.things.current.length
    assert_equal 'current', w.things.current.first.title
  end
  
  def test_things_before
    w = Widget.find(1)
    
    assert_equal 1, w.things.before(3.years.ago(@@t)).length
    assert_equal 'way past', w.things.before(3.years.ago(@@t)).first.title
    
    assert_equal 0, w.things.before(5.years.ago(@@t)).length
  end
end