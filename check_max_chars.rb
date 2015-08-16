require_relative 'lib/zip_csv_util'

include ZipCsvUtil

count_by_column = Hash.new(-1)
each_zip_files('./') do |f|
  each_csv_line(f, 'r:Windows-31J:UTF-8') do |row|
    row.each_with_index do |v, i|
      count_by_column[i] = [v.size, count_by_column[i]].max
    end
  end
end

count_by_column.each do |k, v|
  puts "#{HEADERS[k]}\t#{v}"
end
