require 'active_record'

DATABASE_CONFIG = {
  adapter:  'mysql2',
  host:     'localhost',
  username: 'zip_user',
  password: '-zip_user-',
  database: 'zip'
}

module ActiveRecord
  class Base
    def self.truncate
      connection.execute("truncate table #{self.table_name}")
    end
  end
end

class TransactionHelper
  def initialize(config)
    @config = config
    ActiveRecord::Base.establish_connection(@config)
  end
  
  def with_transaction
     ActiveRecord::Base.connection_pool.with_connection do
      ActiveRecord::Base.transaction do
        yield
      end
    end
  end
  
  def with_rollback_transaction
    with_transaction do
      begin
        yield
        raise ActiveRecord::Rollback
      end
    end
  end
end

