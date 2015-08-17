require_relative 'zip_csv_util'
require_relative 'active_record_util'

class JapanPostZipDataLoader
  CsvRecord = Struct.new(
    *%i(
      code
      old_zip_code
      zip_code
      todofuken_kana
      shikuchoson_kana
      choiki_kana
      todofuken
      shikuchoson
      choiki
      flg_choiki_tokutei_fuka
      flg_koaza_tyoufuku
      flg_tyome_ari
      flg_choiki_tyoufuku
      flg_update
      flg_update_reason
    )
  )

  include ZipCsvUtil

  def initialize(data_dir='./')
    @data_dir = data_dir
  end

  def each_record
    each_zip_files(@data_dir) do |f|
      each_csv_line(f, 'r:Windows-31J:UTF-8') do |row|
        yield CsvRecord.new(*row)
      end
    end
  end

  def included_parentheses(e)
    paren_num = 0
    e.each_char do |c|
      if c == '（'
        paren_num += 1
      elsif c == '）'
        paren_num -= 1
      end
    end
    paren_num
  end

  def merge_duplicate_zip_code
    prev = nil
    paren_num = 0
    each_record do |e|
      if prev
        if e.zip_code == prev.zip_code
          if paren_num != 0 #前のレコードの括弧の対応がとれていない場合
            #町域を連結する
            e.choiki      = prev.choiki + e.choiki
            #カナについては異なる値の場合連結する（京都の住所などで、町域カナは同じ値で、町域のみ連結するケースがあるため)
            e.choiki_kana = prev.choiki_kana + e.choiki_kana unless prev.choiki_kana == e.choiki_kana
          else
            #前のレコードに開き,閉じ括弧のみのデータが無ければ、独立したレコードとみなして前レコードを返す
            yield prev
          end
        else
          #ブレイクしたので、前のレコードを返す
          yield prev
        end
      end
      prev = e
      paren_num = included_parentheses(e.choiki)
    end
    yield prev if prev
  end

  def load_zip_csv
    CsvRecord.truncate
    merge_duplicate_zip_code do |rec|
      rec.save!
    end
  end
end

