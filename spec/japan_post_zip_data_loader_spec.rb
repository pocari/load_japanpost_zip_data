$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'japan_post_zip_data_loader'
require 'rspec'
require_relative 'spec_helper'

describe JapanPostZipDataLoader do
  include_context :uses_temp_dir

  describe '#icluded_parenthese' do
    subject(:target) { JapanPostZipDataLoader.new }

    it '開き括弧1つに対して1が加算されること' do
      expect(target.included_parentheses('(')).to eq(1)
    end

    it '閉じ括弧1つに対して-1が加算されること' do
      expect(target.included_parentheses(')')).to eq(-1)
    end

    describe '括弧の対応に応じた数値が返されること' do
      it '等しい場合' do
        expect(target.included_parentheses('()')).to eq(0)
      end
      it '開き括弧が多い場合場合' do
        expect(target.included_parentheses('(()')).to eq(1)
      end
      it '閉じ括弧が多い場合' do
        expect(target.included_parentheses('()))')).to eq(-2)
      end
    end
  end

  def create_temp_file(str)
    tempfile = nil
    Tempfile.open(['tempfile', '.csv'], @temp_dir) do |f|
      tempfile = f
      f.write(str.encode('windows-31J'))
    end
    tempfile
  end

  describe '#merge_duplicate_zip_code' do
    subject(:target) {
      JapanPostZipDataLoader.new(@temp_dir)
    }

    it "csvレイアウトが想定通りであること" do
      create_temp_file(<<EOS)
x,x,zip,x,x,choiki_kana,x,x,choiki,x,x,x,x,x,x
EOS
      target.each_record do |row|
        expect(row.zip_code).to eq('zip')
        expect(row.choiki_kana).to eq('choiki_kana')
        expect(row.choiki).to eq('choiki')
      end
    end

    context "連続して同じ郵便番号で町域カナの開き括弧が多い場合" do
      it "次のレコードがマージされること" do
        create_temp_file(<<EOS)
x,x,zip,x,x,kana(aa1,x,x,choiki1,x,x,x,x,x,x
x,x,zip,x,x,bb),x,x,choiki2,x,x,x,x,x,x
EOS
        target.merge_duplicate_zip_code do |row|
          expect(row.zip_code).to eq('zip')
          expect(row.choiki_kana).to eq('kana(aa1bb)')
          expect(row.choiki).to eq('choiki1choiki2')
        end
      end
      it "次のレコードがない場合はそのまま出力されること" do
        create_temp_file(<<EOS)
x,x,zip,x,x,kana(aa1,x,x,choiki1,x,x,x,x,x,x
EOS
        target.merge_duplicate_zip_code do |row|
          expect(row.zip_code).to eq('zip')
          expect(row.choiki_kana).to eq('kana(aa1')
          expect(row.choiki).to eq('choiki1')
        end
      end
    end

    context "異なる郵便番号で町域カナの開き括弧が多い場合" do
      it "次のレコードがマージされるないこと" do
        create_temp_file(<<EOS)
x,x,zip1,x,x,kana(aa1,x,x,choiki1,x,x,x,x,x,x
x,x,zip2,x,x,bb),x,x,choiki2,x,x,x,x,x,x
EOS
        result = []
        target.merge_duplicate_zip_code do |row|
          result << row
        end

        expect(result.size).to eq(2)


        expect(result[0].zip_code).to eq('zip1')
        expect(result[0].choiki_kana).to eq('kana(aa1')
        expect(result[0].choiki).to eq('choiki1')

        expect(result[1].zip_code).to eq('zip2')
        expect(result[1].choiki_kana).to eq('bb)')
        expect(result[1].choiki).to eq('choiki2')
      end
    end
  end
end

