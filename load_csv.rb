require_relative 'lib/japan_post_zip_data_loader'
require_relative 'lib/active_record_util'
require_relative 'lib/config_helper'
require_relative 'lib/mst_zip'

def main
  loader = JapanPostZipDataLoader.new('./')

  tm = TransactionHelper.new(ConfigHelper[:db, :development])
  tm.with_transaction do
    MstZip.delete_all
    loader.merge_duplicate_zip_code do |row|
      MstZip.new(row.to_h).save!
    end
  end
end

main

