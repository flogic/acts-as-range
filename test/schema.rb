ActiveRecord::Schema.define(:version => 1) do

  create_table :widgets, :force => true do |t|
    t.column :title, :string, :limit => 50
    t.column :begin_date, :timestamp
    t.column :end_date, :timestamp
    t.column :thing_id, :integer
  end
                           
  create_table :things, :force => true do |t|
    t.column :title, :string, :limit => 50
    t.column :name,  :string, :limit => 50
    t.column :start, :timestamp
    t.column :stop, :timestamp
  end
  
  create_table :thing_widgets, :force => true do |t|
    t.column :thing_id, :integer
    t.column :widget_id, :integer
  end

  create_table :number_ranges, :force => true do |t|
    t.column :title, :string, :limit => 50
    t.column :begin, :integer
    t.column :end, :integer
  end                       
  
  create_table :my_ranges, :force => true do |t|
    t.column :title, :string, :limit => 50
    t.column :begin, :integer
    t.column :end, :integer
  end
end
