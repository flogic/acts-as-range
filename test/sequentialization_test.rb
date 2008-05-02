require File.join(File.dirname(__FILE__), 'test_helper')
         
class Thing1 < ActiveRecord::Base
  set_table_name 'things'
  acts_as_date_range :begin => :start, :end => :stop, :sequentialize => true
end

class Thing2 < ActiveRecord::Base
  set_table_name 'things'
  acts_as_date_range :begin => :start, :end => :stop, :sequentialize => :title
end

class Thing3 < ActiveRecord::Base
  set_table_name 'things'
  acts_as_date_range :begin => :start, :end => :stop
end

class Thing4 < ActiveRecord::Base
  set_table_name 'things'
  acts_as_date_range :begin => :start, :end => :stop, :sequentialize => [:title, :name]
end

class SequentializationTest < Test::Unit::TestCase
  
  def setup_singleton
    Thing1.find(:all).each(&:destroy)
  end
  
  def test_sequentialization_must_default_begin_time
    setup_singleton
    t = Thing1.create!
    assert_in_delta Time.now, t.start, 2.seconds
  end
  
  def test_sequentialization_must_expire_open_objects
    setup_singleton
    Thing1.create!(:start => 1.year.ago)
    t = Thing1.create!

    assert_equal 1, Thing1.count(:conditions => 'stop is not null')    
    assert_equal 1, Thing1.count(:conditions => 'stop is null')
  end
  
  def test_sequentialization_must_not_allow_begin_time_corruption
    setup_singleton
    Thing1.create!(:start => 1.year.ago)
    t=Thing1.create(:start => 2.years.ago)
    assert t.errors.on(:start).size > 0
  end

  def test_sequentialization_must_not_allow_begin_time_corruption
    setup_singleton
    Thing1.create!(:start => 2.years.ago, :stop => 1.year.ago)
    
    t=Thing1.create(:start => 3.years.ago)
    assert t.errors.on(:start).size > 0
  end
  
  def setup_scoped
    Thing2.find(:all).each(&:destroy)
    Thing2.create!(:title => 'other', :start => 3.years.ago)
    Thing2.create!(:title => 'more',  :start => 1.month.ago)
  end
      
  def test_sequentialization_scoped_must_default_begin_time
    setup_scoped
    t = Thing2.create!
    assert_in_delta Time.now, t.start, 2.seconds
  end
  
  def test_sequentialization_scoped_must_expire_open_objects
    setup_scoped
    Thing2.create!(:start => 1.year.ago, :title => 'test')
    t = Thing2.create!(:title => 'test')

    assert_equal 1, Thing2.count(:conditions => ['stop is not null and title = ?', 'test'])    
    assert_equal 1, Thing2.count(:conditions => ['stop is null and title = ?', 'test'])
  end
  
  def test_sequentialization_scoped_must_not_allow_begin_time_corruption
    setup_scoped
    Thing2.create!(:start => 1.year.ago, :title => 'test')
    t=Thing2.create(:start => 2.years.ago, :title => 'test')
    assert t.errors.on(:start).size > 0
  end
  
  def test_sequentialization_scoped_must_ignore_other_items_in_scope
    setup_scoped
    t=Thing2.create(:start => 2.years.ago, :title => 'test')
    assert t.errors.on(:start).nil?
  end
  
  def setup_multiple_scoped
    Thing4.find(:all).each(&:destroy)
    Thing4.create!(:title => 'other', :name => 'test-o',  :start => 3.years.ago)
    Thing4.create!(:title => 'other', :name => 'testing', :start => 3.years.ago)
    Thing4.create!(:title => 'again', :name => 'testing', :start => 3.years.ago)
  end
  
  def test_sequentialization_multiple_scoped_must_expire_open_objects
    setup_multiple_scoped
    Thing4.create!(:start => 1.year.ago, :title => 'other', :name => 'testing')

    assert_equal 1, Thing4.count(:conditions => ['stop is not null and title = ? and name = ?', 'other', 'testing'])
    assert_equal 1, Thing4.count(:conditions => ['stop is null and title = ? and name = ?', 'other', 'testing'])
  end
  
  def test_sequentialization_multiple_scoped_must_not_allow_begin_time_corruption
    setup_multiple_scoped
    t=Thing4.create(:start => 4.years.ago, :title => 'other', :name => 'testing')
    assert t.errors.on(:start).size > 0
  end
  
  def test_sequentialization_multiple_scoped_must_ignore_other_items_in_scope
    setup_multiple_scoped
    t=Thing4.create(:start => 2.years.ago, :title => 'other', :name => 'testing')
    assert t.errors.on(:start).nil?
  end
  
  def test_class_must_be_able_to_tell_if_its_sequentialized
    assert Thing1.respond_to?(:sequentialized?)
    assert Thing2.respond_to?(:sequentialized?)
    assert Thing3.respond_to?(:sequentialized?)
    assert Thing4.respond_to?(:sequentialized?)
  end
  
  def test_class_must_tell_if_its_sequentialized
    assert  Thing1.sequentialized?
    assert  Thing2.sequentialized?
    assert !Thing3.sequentialized?
    assert  Thing4.sequentialized?
  end
  
  def test_class_must_indicate_sequentialization
    assert_equal true, Thing1.sequentialized_on
    assert_equal :title, Thing2.sequentialized_on
    assert_nil Thing3.sequentialized_on
    assert_equal [:title, :name], Thing4.sequentialized_on
  end
  
end