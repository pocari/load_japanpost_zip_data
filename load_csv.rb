require_relative 'lib/japan_post_zip_data_loader'
require_relative 'lib/active_record_util'
require_relative 'lib/config_helper'
require_relative 'lib/mst_zip'

def main
  loader = JapanPostZipDataLoader.new('./')

  tm = TransactionHelper.new(ConfigHelper[:db, :development])
  tm.with_transaction do
    MstZip.delete_all
    records = []
    loader.merge_duplicate_zip_code do |row|
      records << MstZip.new(row.to_h)
    end
    count = 0;
    records.each_slice(1000) do |slice|
      MstZip.import slice
      count += slice.size
      $stderr.puts "#{count} inserted."
    end
  end
end

main

