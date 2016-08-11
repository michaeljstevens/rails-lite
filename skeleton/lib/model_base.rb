require_relative '01_sql_object'
require_relative '02_searchable'
require_relative '03_associatable'
require_relative '04_associatable2'

class ModelBase < SQLObject
  extend Searchable
  extend Associatable
end
