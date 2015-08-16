require_relative 'lib/zip_csv_util'
require_relative 'lib/active_record_util'

include ZipCsvUtil

def each_record
  db_columns = MstZip.columns.drop(1).map(&:name).map(&:to_sym)
  each_zip_files('./') do |f|
    each_csv_line(f, 'r:Windows-31J:UTF-8') do |row|
      yield MstZip.new(db_columns.zip(row).to_h)
    end
  end
end

def included_open_parentheses(e)
  paren_num = 0
  e.each_char do |c|
    if c == '('
      paren_num += 1
    elsif c == ')'
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
          current_paren = included_open_parentheses(e.choiki_kana)
          #町域を連結する
          e.choiki_kana = prev.choiki_kana + e.choiki_kana
          e.choiki       = prev.choiki + e.choiki
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
    paren_num = included_open_parentheses(e.choiki_kana)
  end
  yield prev if prev
end

def load_zip_csv
  MstZip.truncate
  merge_duplicate_zip_code do |rec|
    rec.save!
  end
end

load_zip_csv

