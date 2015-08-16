require_relative 'lib/active_record_util'

def each_duplicate_zip_code()
  sql = <<EOS
select
  id
 ,code
 ,zip_code
 ,todofuken_kana
 ,shikuchoson_kana
 ,choiki_kana
 ,todofuken
 ,shikuchoson
 ,choiki
from
  mst_zip
where
  zip_code in (
    select
     zip_code
    from
      mst_zip mz
    group by
      zip_code
    having
      count(*) > 1
    )
order by
 zip_code,
 id
EOS
  ActiveRecord::Base.connection.select_all(sql).each do |row|
    yield MstZip.new(row)
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
  each_duplicate_zip_code do |e|
    if prev
      if e.zip_code == prev.zip_code
        if prev.id + 1 != e.id
          # 連番で無いので違うレコード
          yield prev
        else
          #連番なので異なるレコードの可能性があるためチェック
          if paren_num != 0 #前のレコードの括弧の対応がとれていない場合
            current_paren = included_open_parentheses(e.choiki_kana)
            #町域を連結する
            e.choiki_kana = prev.choiki_kana + e.choiki_kana
            e.choiki       = prev.choiki + e.choiki
          else
            #前のレコードに開き,閉じ括弧のみのデータが無ければ、独立したレコードとみなして前レコードを返す
            yield prev
          end
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

merge_duplicate_zip_code do |row|
  puts [row.id, row.zip_code, row.choiki_kana, row.choiki].join("\t")
end

