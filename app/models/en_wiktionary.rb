# wiktionaryをパースして辞書を作るなどする
# データは、https://github.com/tatuylonen/wiktextract
# https://kaikki.org/dictionary/English/index.html
class EnWiktionary < ApplicationRecord
  require 'ox'
  require "json"
  require "csv"

  # wiktionaryをCSVで出力する
  def self.export_en_en_wiktionary_as_csv
    filename = "tmp/enwiktionary.xml"
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
      if is_en?(page[:title], page[:revision][:text])
        title_ary << page[:title]
        text_ary << page[:revision][:text]
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


  def self.create_en_en_dict_m_and_exp
    filename = "tmp/enwiktionary.xml"
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
      meaning = meaning(text, 300)
      explanation = explanation(text)
      if self.is_en?(title, text) && meaning.present?
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

  def is_en?(title, text)
    # Category:{{en}} か Category:日本語 か =={{en}}== か ==日本語== が含まれるなら日本語
    text_is_en = text&.include?('==English==')
    # テンプレート:KTOC のようなページを除外する。
    title_is_en = title&.include?(':') == false
    text_is_en && title_is_en
  end


  # raw_glossesがなく、glossesのみ存在する場合がある。それすらない場合もある。
  def self.meaning(senses_hash, limit)
    senses = senses_hash.map { |s| s['raw_glosses']&.join('; ') }
    meaning = senses.first
    return '' if meaning.blank?

    num = 1
    continue = true
    while continue do
      added_meaning = senses[num]
      if added_meaning.blank?
        continue = false
        next
      end
      text_size = meaning.size + added_meaning.size
      if text_size > limit
        continue = false
        next
      end
      meaning = meaning + ' / ' + added_meaning
      num += 1
    end
    meaning
  end

  def self.explanation(senses_hash)
    return '' if senses_hash.blank?

    senses = senses_hash.map { |s| s['raw_glosses'] }
    senses.join("\n")
  end

  def self.ipa(sounds_hash)
    return '' if sounds_hash.blank?

    ipa_hash = sounds_hash[0]
    return '' if ipa_hash.blank?

    ipa_hash['ipa']
  end



  def self.related_words(hash)
    return '' if hash.blank?

    words = hash.map { |h| h['word'] }
    words.join(',')
  end


  #
  def self.export_csv
    entry = []
    entry_en = []
    lang_number_of_entry = []
    meaning = []
    lang_number_of_meaning = []
    etymologies = []
    ipa = []
    explanation = []
    pos = []
    forms_json = []
    sounds_json = []
    senses_json = []
    categories_json = []
    topics_json = []
    translations_json = []
    etymology_templates_json = []
    head_templates_json = []
    inflection_templates_json = []
    synonyms = []
    antonyms = []
    hypernyms = []
    holonyms = []
    meronyms = []
    coordinate_terms = []
    related = []
    derived = []
    wikidata = []
    wiktionary = []
    # すべてnilだが、用意しておかないとimport時に
    # conversion failed: "[{"name":"en-conj-simple","args":{"stem":"abhorr"}}]" to int4 (sentence_id)
    # が発生する。
    sentence_id = []
    dictionary_id = []
    created_at = []
    updated_at = []
    File.foreach('tmp/en_dictionary_text.txt') do |line|
      json = JSON.parse(line)
      next if json.blank?

      entry << json['word']
      entry_en << json['word']
      lang_number_of_entry << 21
      meaning << EnWiktionary.meaning(json['senses'], 200)
      lang_number_of_meaning << 21
      ipa << EnWiktionary.ipa(json['sounds'])
      pos << json['pos']
      etymologies << json['etymology_text']
      explanation << EnWiktionary.explanation(json['senses'])

      forms_json << json['forms']&.to_json
      sounds_json << json['sounds']&.to_json
      senses_json << json['senses']&.to_json
      categories_json << json['categories']&.to_json
      topics_json << json['topics']&.to_json
      translations_json << json['translations']&.to_json
      etymology_templates_json << json['etymology_templates']&.to_json
      head_templates_json << json['head_templates']&.to_json
      inflection_templates_json << json['inflection_templates']&.to_json

      synonyms << EnWiktionary.related_words(json['synonyms'])
      antonyms << EnWiktionary.related_words(json['antonyms'])
      hypernyms << EnWiktionary.related_words(json['hypernyms'])
      holonyms << EnWiktionary.related_words(json['holonyms'])
      meronyms << EnWiktionary.related_words(json['meronyms'])
      coordinate_terms << EnWiktionary.related_words(json['coordinate_terms'])
      related << EnWiktionary.related_words(json['related'])
      derived << EnWiktionary.related_words(json['derived'])
      wikidata << json['wikidata']
      wiktionary << json['wiktionary']
      sentence_id << nil
      dictionary_id << 5
      created_at << '2022-09-09 15:44:44.834394'
      updated_at << '2022-09-09 15:44:44.834394'
    end

    # 原文と翻訳文を１行にまとめて、配列を組み直す。
    array = [entry, entry_en, lang_number_of_entry, meaning, lang_number_of_meaning, ipa, pos, etymologies, explanation,
             forms_json, sounds_json, senses_json, categories_json, topics_json, translations_json,
             etymology_templates_json, head_templates_json, inflection_templates_json,
             synonyms, antonyms, hypernyms, holonyms, meronyms, coordinate_terms, related, derived,
             wikidata, wiktionary, sentence_id, dictionary_id, created_at, updated_at].transpose

    csv_data = CSV.generate do |csv|
      header = %w[entry entry_en lang_number_of_entry meaning lang_number_of_meaning ipa pos etymologies explanation
                  forms_json sounds_json senses_json categories_json topics_json translations_json
                  etymology_templates_json head_templates_json inflection_templates_json
                  synonyms antonyms hypernyms holonyms meronyms coordinate_terms related derived
                  wikidata wiktionary sentence_id dictionary_id created_at updated_at]
      csv << header
      array.each do |a|
        csv << a
      end
    end

    # CSVでダウンロードする： https://qiita.com/asadsexyimp/items/47375a12f7d05e812ff2
    # 最適化についてはこちらも参考： https://www.techscore.com/blog/2017/12/04/fast_and_low-load_processing_method_when_exporting_csv_from_db_with_rails/
    # 現在時間でダウンロードできるようにする
    current_time = DateTime.now.to_s
    # ファイル作成
    File.open("./#{current_time}_corpus.csv", 'w') do |file|
      file.write(csv_data)
    end
  end



end