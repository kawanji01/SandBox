# wiktionaryをパースして辞書を作るなどする
# dumpデータは　https://dumps.wikimedia.org/jawiktionary
class JaWiktionary < ApplicationRecord


  # wiktionaryをCSVで出力する
  def self.export_wiktionary_as_csv
    filename = "jawiktionary.xml"
    p 'Read file START'
    file_str = open(filename).read
    p 'Read file END'
    p 'Load file START'
    hash = Ox.load(file_str, mode: :hash_no_attrs)
    p 'open file END'
    pages = hash[:mediawiki][:page]
    title_ary = []
    text_ary = []
    pages.each do |page|
      title_ary << page[:title]
      text_ary << page[:revision][:text]
    end
    # 原文と翻訳文を１行にまとめて、配列を組み直す。
    array = [title_ary, text_ary].transpose
    csv_data = CSV.generate do |csv|
      header = %w[title text]
      csv << header
      array.each do |a|
        csv << a
      end
    end
    # CSVでダウンロード https://qiita.com/asadsexyimp/items/47375a12f7d05e812ff2
    # 現在時間でダウンロードできるようにする
    current_time = DateTime.now.to_s
    # ファイル作成
    File.open("./#{current_time}_corpus.csv", 'w') do |file|
      file.write(csv_data)
    end
  end



  def self.create_ja_ja_dict_csv
    filename = "jawiktionary.xml"
    p 'Read file START'
    file_str = open(filename).read
    p 'Read file END'
    p 'Load file START'
    hash = Ox.load(file_str, mode: :hash_no_attrs)
    p 'open file END'
    pages = hash[:mediawiki][:page]
    title_ary = []
    text_ary = []
    pages.each do |page|
      text = page[:revision][:text]
      title = page[:title]
      if self.is_ja?(title, text)
        title_ary << title
        text_ary << text
      end
    end
    # 原文と翻訳文を１行にまとめて、配列を組み直す。
    array = [title_ary, text_ary].transpose
    csv_data = CSV.generate do |csv|
      header = %w[title text]
      csv << header
      array.each do |a|
        csv << a
      end
    end
    # CSVでダウンロード https://qiita.com/asadsexyimp/items/47375a12f7d05e812ff2
    # 現在時間でダウンロードできるようにする
    current_time = DateTime.now.to_s
    # ファイル作成
    File.open("./#{current_time}_corpus.csv", 'w') do |file|
      file.write(csv_data)
    end
  end

  def self.create_ja_ja_dict_m_and_exp
    filename = "jawiktionary.xml"
    p 'Read file START'
    file_str = open(filename).read
    p 'Read file END'
    p 'Load file START'
    hash = Ox.load(file_str, mode: :hash_no_attrs)
    p 'open file END'
    pages = hash[:mediawiki][:page]
    title_ary = []
    meaning_ary = []
    explanation_ary = []
    pages.each do |page|
      title = page[:title]
      text = page[:revision][:text]
      meaning = meaning(text)
      explanation = explanation(text)
      if self.is_ja?(title, text) && meaning.present?
        title_ary << title
        meaning_ary << meaning
        explanation_ary << explanation
      end
    end
    # 原文と翻訳文を１行にまとめて、配列を組み直す。
    array = [title_ary, meaning_ary, explanation_ary].transpose
    p "pages_count: #{array.size}"
    csv_data = CSV.generate do |csv|
      header = %w[title meaning explanation]
      csv << header
      array.each do |a|
        csv << a
      end
    end
    # CSVでダウンロード https://qiita.com/asadsexyimp/items/47375a12f7d05e812ff2
    # 現在時間でダウンロードできるようにする
    current_time = DateTime.now.to_s
    # ファイル作成
    File.open("./#{current_time}_corpus.csv", 'w') do |file|
      file.write(csv_data)
    end
  end

  def self.is_ja?(title, text)
    # Category:{{ja}} か Category:日本語 か =={{ja}}== か ==日本語== が含まれるなら日本語
    text_is_ja = text&.include?('Category:{{ja}}') || text&.include?('Category:日本語') || text&.include?('=={{ja}}==') || text&.include?('==日本語==')
    # テンプレート:KTOC のようなページを除外する。
    title_is_ja = title&.include?(':') == false
    text_is_ja && title_is_ja
  end

  def self.meaning(text)
    matches = text&.scan(/(\s#[^\*\#\=;<>]+)/)
    return '' if matches.blank?
    array = []
    matches.each do |match|
      match_text = match.join(' / ')
      converted_text = FileUtility.convert_into_dict_link(match_text)
      # プレーンなテキストに変換
      sanitized_text = ApplicationController.helpers.sanitize_dict_links(converted_text)
      subbed_text = sanitized_text.gsub('#', '')
      array << subbed_text
    end
    str = array.join(' / ')
    str
  end

  def self.explanation(text)
    matches = text&.scan(/(\s#[^\*\#\=;<>]+)/)
    return '' if matches.blank?
    array = []
    matches.each do |match|
      match_text = match.join(' / ')
      converted_text = FileUtility.convert_into_dict_link(match_text)
      subbed_text = converted_text.gsub('#', '【意味】')
      array << subbed_text
    end
    str = array.join("\n")
    str
  end

  # wiktionaryのリンク記法をDiQtのリンク記法に変換する。
  def self.convert_into_dict_link(text)
    subbed = text&.gsub(/\[{2}([^\]]+?)\|([^\]]+?)\]{2}/) do
      "[[#{$2}|#{$1}]]"
    end
    subbed
  end

  # DBクライアントからDiQtにimportする辞書データを生成する
  def self.create_dict_csv
    entry = []
    entry_ja = []
    meaning = []
    explanation = []
    lang_number_of_entry = []
    lang_number_of_meaning = []
    dictionary_id = []
    created_at = []
    updated_at = []
    sps = CSV.open('tmp/ja_ja_dict_m_and_exp.csv', headers: true)
    sps.each do |s|
      entry << s['title']&.strip
      entry_ja << s['title']&.strip
      meaning << s['meaning']
      explanation << s['explanation']
      lang_number_of_entry << Languages::CODE_MAP['ja']
      lang_number_of_meaning << Languages::CODE_MAP['ja']
      dictionary_id << 6
      created_at << '2022-08-26 15:44:44.834394'
      updated_at << '2022-08-26 15:44:44.834394'
    end

    array = [entry, entry_ja, meaning, explanation, lang_number_of_entry, lang_number_of_meaning, dictionary_id, created_at, updated_at].transpose

    csv_data = CSV.generate do |csv|
      header = %w[entry entry_ja meaning explanation lang_number_of_entry lang_number_of_meaning dictionary_id created_at updated_at]
      csv << header
      array.each do |a|
        csv << a
      end
    end

    current_time = DateTime.now.to_s
    # ファイル作成
    File.open("./#{current_time}_corpus.csv", 'w') do |file|
      file.write(csv_data)
    end
  end


  # DBクライアントからDiQtにimportする辞書の問題データを生成する
  def self.create_dict_quiz_csv(dictionary)
    drill = dictionary.drill
    return if drill.blank?
    question = []
    correct_answer = []
    distractor_1 = []
    distractor_2 = []
    distractor_3 = []
    lang_number_of_question = []
    lang_number_of_answer = []
    question_read_aloud = []
    auto_dict_link_of_question = []
    word_id = []
    dictionary_id = []
    drill_id = []
    created_at = []
    updated_at = []

    meanings = dictionary.words&.map(&:meaning)
    dictionary.words.order(id: :asc).find_each do |word|
      shuffle_meanings = meanings&.shuffle
      question << word&.entry

      answer_array = []

      answer = word&.meaning
      answer_array << answer
      correct_answer << answer.truncate(200)

      dis_1 = shuffle_meanings&.find { |n| answer_array&.exclude?(n) }
      answer_array << dis_1
      distractor_1 << dis_1&.truncate(200)

      dis_2 = shuffle_meanings&.find { |n| answer_array&.exclude?(n) }
      answer_array << dis_2
      distractor_2 << dis_2&.truncate(200)

      dis_3 = shuffle_meanings&.find { |n| answer_array&.exclude?(n) }
      answer_array << dis_3
      distractor_3 << dis_3&.truncate(200)

      lang_number_of_question << word.lang_number_of_entry
      lang_number_of_answer << word.lang_number_of_meaning
      question_read_aloud << true
      auto_dict_link_of_question << true
      word_id << word.id
      dictionary_id << dictionary.id
      drill_id << drill.id
      created_at << '2022-08-27 15:44:44.834394'
      updated_at << '2022-08-27 15:44:44.834394'
    end

    array = [question, correct_answer, distractor_1, distractor_2, distractor_3,
             lang_number_of_question, lang_number_of_answer, question_read_aloud, auto_dict_link_of_question,
             word_id, dictionary_id, drill_id,  created_at, updated_at].transpose

    csv_data = CSV.generate do |csv|
      header = %w[question correct_answer distractor_1 distractor_2 distractor_3
lang_number_of_question lang_number_of_answer question_read_aloud auto_dict_link_of_question
word_id dictionary_id drill_id created_at updated_at]
      csv << header
      array.each do |a|
        csv << a
      end
    end

    current_time = DateTime.now.to_s
    # ファイル作成
    File.open("./#{current_time}_corpus.csv", 'w') do |file|
      file.write(csv_data)
    end
  end

end