require 'centerstone/acts/range'
require 'centerstone/acts/date_range'
require 'centerstone/association_extensions/ranged'
require 'centerstone/association_extensions/date_ranged'

ActiveRecord::Base.send :include, Centerstone::Acts::Range
ActiveRecord::Base.send :include, Centerstone::Acts::DateRange

# ActiveRecord::Reflection::AssociationReflection.send :include, Centerstone::ReflectionExtensions::Ranged