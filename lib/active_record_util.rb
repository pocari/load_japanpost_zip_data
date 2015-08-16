require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'yn_test_user',
  password: '-yn_test_user-',
  database: 'yn_test'
)

module ActiveRecord
  class Base
    def self.truncate
      connection.execute("truncate table #{self.table_name}")
    end
  end
end

class MstZip < ActiveRecord::Base
  self.table_name = 'mst_zip'
end
