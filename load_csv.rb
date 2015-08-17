require_relative 'lib/japan_post_zip_data_loader'
require_relative 'lib/active_record_util'

def main
  loader = JapanPostZipDataLoader.new('./')

  MstZip.truncate
  loader.merge_duplicate_zip_code do |row|
    MstZip.new(row.to_h).save!
  end
end

main

