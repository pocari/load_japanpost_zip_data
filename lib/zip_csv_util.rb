require 'csv'

module ZipCsvUtil
  HEADERS = %w(
    全国地方公共団体コード
    （旧）郵便番号（5桁）
    （郵便番号）（7桁）
    都道府県名（カナ）
    市区町村名（カナ）
    町域名（カナ）
    都道府県名
    市区町村名
    町域名
    町域特定不可フラグ
    小字重複フラグ
    丁目ありフラグ
    町域重複フラグ
    更新フラグ
    変更理由フラグ
  )


  module_function
  def each_csv_line(file, open_flag)
    open(file, open_flag) do |f|
      CSV.new(f).each do |row|
        yield row
      end
    end
  end

  def each_zip_files(dir, pattern="*")
    Dir.glob("#{dir}/#{pattern}.csv", File::FNM_CASEFOLD) do |csv|
      yield csv
    end
  end
end
