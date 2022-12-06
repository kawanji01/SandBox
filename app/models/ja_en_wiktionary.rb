class JaEnWiktionary < ApplicationRecord
  require 'ox'
  require "json"
  require "csv"

  def self.export_csv
    entry = []
    entry_ja = []
    reading = []
    lang_number_of_entry = []
    meaning = []
    lang_number_of_meaning = []
    etymologies = []
    ipa = []
    explanation = []
    pos = []
    synonyms = []
    antonyms = []
    hypernyms = []
    holonyms = []
    meronyms = []
    coordinate_terms = []
    related = []
    derived = []
    # wiktionaryのJSON
    wiktextract_json = []
    # sentence_idはすべてnilだが、用意しておかないとimport時に
    # conversion failed: "[{"name":"en-conj-simple","args":{"stem":"abhorr"}}]" to int4 (sentence_id)
    # が発生する。
    sentence_id = []
    dictionary_id = []
    created_at = []
    updated_at = []
    File.foreach('tmp/ja_en_dictionary.json') do |line|
      json = JSON.parse(line)
      next if json.blank?
      pos_text = json['pos']
      meaning_text = JsonUtility.meaning(json['senses'], 200)
      next if meaning_text.blank?
      # kunのような単なるローマ字化は取り除く。
      next if pos_text == 'romanization'
      entry << json['word']
      entry_ja << json['word']
      reading << JaEnWiktionary.hiragana_reading(json)
      lang_number_of_entry << Languages::CODE_MAP['ja']
      meaning << meaning_text
      lang_number_of_meaning << Languages::CODE_MAP['en']
      ipa << ''
      pos << json['pos']
      etymologies << json['etymology_text']
      explanation << ''
      synonyms << JsonUtility.related_words(json['synonyms'])
      antonyms << JsonUtility.related_words(json['antonyms'])
      hypernyms << JsonUtility.related_words(json['hypernyms'])
      holonyms << JsonUtility.related_words(json['holonyms'])
      meronyms << JsonUtility.related_words(json['meronyms'])
      coordinate_terms << JsonUtility.related_words(json['coordinate_terms'])
      related << JsonUtility.related_words(json['related'])
      derived << JsonUtility.related_words(json['derived'])
      #
      wiktextract_json << json.to_json
      #
      sentence_id << nil
      # 要設定
      dictionary_id << 7
      created_at << '2022-12-05 15:44:44.834394'
      updated_at << '2022-12-05 15:44:44.834394'
    end

    # 原文と翻訳文を１行にまとめて、配列を組み直す。
    array = [entry, entry_ja, reading, lang_number_of_entry, meaning, lang_number_of_meaning, ipa, pos, etymologies, explanation,
             synonyms, antonyms, hypernyms, holonyms, meronyms, coordinate_terms, related, derived,
             wiktextract_json,
             sentence_id, dictionary_id, created_at, updated_at].transpose

    csv_data = CSV.generate do |csv|
      header = %w[entry entry_ja reading lang_number_of_entry meaning lang_number_of_meaning ipa pos etymologies explanation
                  synonyms antonyms hypernyms holonyms meronyms coordinate_terms related derived
                  wiktextract_json
                  sentence_id dictionary_id created_at updated_at]
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

  def self.extract_pos_without_reading
    pos_ary = []
    reading_ary = []
    File.foreach('tmp/ja_en_dictionary.json') do |line|
      json = JSON.parse(line)
      next if json.blank?
      pos = json['pos']
      reading = JaEnWiktionary.hiragana_reading(json)
      if reading.first.match?(/[a-z[0-9]]/)
        # next if pos_ary.include?(json['pos'])
        pos_ary << pos
        reading_ary << reading
      end
    end
    array = [pos_ary, reading_ary].transpose

    csv_data = CSV.generate do |csv|
      header = %w[pos reading]
      csv << header
      array.each do |a|
        csv << a
      end
    end
    current_time = DateTime.now.to_s
    File.open("./#{current_time}_corpus.csv", 'w') do |file|
      file.write(csv_data)
    end
  end


  # ひらがなの読みを取得する
  def self.hiragana_reading(json)
    pos = json['pos']
    head_template = json['head_templates'][0]['args'] rescue nil
    # head_template["1"]に読みが存在しない品詞一覧
    not_standard_pos = ['name', 'counter', 'particle', 'affix', 'prefix', 'intj',
                        'pron', 'suffix' 'syllable', 'num', 'punct', 'phrase',
                        'combining_form', 'infix', 'root', 'suffix', 'character',
                        'conj', 'adj', 'abbrev', 'noun']
    if not_standard_pos.include?(pos)
      @reading = head_template["1"] rescue nil
      @reading = JaEnWiktionary.get_hiragana(json) rescue nil if @reading.blank? || @reading&.first&.match?(/[a-z[0-9]]/)
    elsif 'romanization'
      @reading = json["senses"][0]["alt_of"][0]['word'] rescue nil
      # ローマ字読みなら""
      @reading = '' if @reading&.first&.match?(/[a-z[0-9]]/)
    else
      @reading = head_template["1"] rescue nil
    end
    return '' if @reading.blank?
    @reading = @reading.gsub('%', '')
  end

  def self.get_hiragana(json)
    forms = json['forms']
    hiragana_form = forms.find { |f| f['tags'][0] == 'hiragana' } rescue nil
    return '' if hiragana_form.blank?
    hiragana_form['form']
  end

  ###### データのサンプル START ######

  def self.sample_adj
    { "pos": "adj",
      "head_templates": [
        { "name": "ja-adj", "args": { "infl": "i", "1": "\u3044\u305f\u3044" }, "expansion": "\u75db(\u3044\u305f)\u3044 \u2022 (itai) -i (adverbial \u75db(\u3044\u305f)\u304f (itaku))" }
      ],
      "forms": [
        { "form": "\u75db (\u3044\u305f)\u3044", "tags": ["canonical"] },
        { "form": "itai", "tags": ["romanization"] },
        { "form": "\u75db (\u3044\u305f)\u304f", "roman": "itaku", "tags": ["adverbial"] },
        { "form": "", "source": "inflection", "tags": ["table-tags"] },
        { "form": "ja-i", "source": "inflection", "tags": ["inflection-template"] },
        { "form": "\u75db\u304b\u308d", "tags": ["imperfective", "stem"], "source": "inflection" },
        { "form": "\u3044\u305f\u304b\u308d", "tags": ["imperfective", "stem"], "source": "inflection" },
        { "form": "itakaro", "tags": ["imperfective"], "source": "inflection" },
        { "form": "\u75db\u304f", "tags": ["continuative", "stem"], "source": "inflection" },
        { "form": "\u3044\u305f\u304f", "tags": ["continuative", "stem"], "source": "inflection" },
        { "form": "itaku", "tags": ["continuative"], "source": "inflection" },
        { "form": "\u75db\u3044", "tags": ["stem", "terminative"], "source": "inflection" },
        { "form": "\u3044\u305f\u3044", "tags": ["stem", "terminative"], "source": "inflection" },
        { "form": "itai", "tags": ["terminative"], "source": "inflection" },
        { "form": "\u75db\u3044", "tags": ["attributive", "stem"], "source": "inflection" },
        { "form": "\u3044\u305f\u3044", "tags": ["attributive", "stem"], "source": "inflection" },
        { "form": "itai", "tags": ["attributive"], "source": "inflection" },
        { "form": "\u75db\u3051\u308c", "tags": ["hypothetical", "stem"], "source": "inflection" },
        { "form": "\u3044\u305f\u3051\u308c", "tags": ["hypothetical", "stem"], "source": "inflection" },
        { "form": "itakere", "tags": ["hypothetical"], "source": "inflection" },
        { "form": "\u75db\u304b\u308c", "tags": ["imperative", "stem"], "source": "inflection" },
        { "form": "\u3044\u305f\u304b\u308c", "tags": ["imperative", "stem"], "source": "inflection" },
        { "form": "itakare", "tags": ["imperative"], "source": "inflection" },
        { "form": "\u75db\u304f\u306a\u3044", "tags": ["informal", "negative"], "source": "inflection" },
        { "form": "\u3044\u305f\u304f\u306a\u3044", "tags": ["informal", "negative"], "source": "inflection" },
        { "form": "itaku nai", "tags": ["informal", "negative"], "source": "inflection" },
        { "form": "\u75db\u304b\u3063\u305f", "tags": ["informal", "past"], "source": "inflection" },
        { "form": "\u3044\u305f\u304b\u3063\u305f", "tags": ["informal", "past"], "source": "inflection" },
        { "form": "itakatta", "tags": ["informal", "past"], "source": "inflection" },
        { "form": "\u75db\u304f\u306a\u304b\u3063\u305f", "tags": ["informal", "negative", "past"], "source": "inflection" },
        { "form": "\u3044\u305f\u304f\u306a\u304b\u3063\u305f", "tags": ["informal", "negative", "past"], "source": "inflection" },
        { "form": "itaku nakatta", "tags": ["informal", "negative", "past"], "source": "inflection" },
        { "form": "\u75db\u3044\u3067\u3059", "tags": ["formal"], "source": "inflection" },
        { "form": "\u3044\u305f\u3044\u3067\u3059", "tags": ["formal"], "source": "inflection" },
        { "form": "itai desu", "tags": ["formal"], "source": "inflection" },
        { "form": "\u75db\u304f\u306a\u3044\u3067\u3059", "tags": ["formal", "negative"], "source": "inflection" },
        { "form": "\u3044\u305f\u304f\u306a\u3044\u3067\u3059", "tags": ["formal", "negative"], "source": "inflection" },
        { "form": "itaku nai desu", "tags": ["formal", "negative"], "source": "inflection" },
        { "form": "\u75db\u304b\u3063\u305f\u3067\u3059", "tags": ["formal", "past"], "source": "inflection" },
        { "form": "\u3044\u305f\u304b\u3063\u305f\u3067\u3059", "tags": ["formal", "past"], "source": "inflection" },
        { "form": "itakatta desu", "tags": ["formal", "past"], "source": "inflection" },
        { "form": "\u75db\u304f\u306a\u304b\u3063\u305f\u3067\u3059", "tags": ["formal", "negative", "past"], "source": "inflection" },
        { "form": "\u3044\u305f\u304f\u306a\u304b\u3063\u305f\u3067\u3059", "tags": ["formal", "negative", "past"], "source": "inflection" },
        { "form": "itaku nakatta desu", "tags": ["formal", "negative", "past"], "source": "inflection" },
        { "form": "\u75db\u304f\u3066", "tags": ["conjunctive"], "source": "inflection" },
        { "form": "\u3044\u305f\u304f\u3066", "tags": ["conjunctive"], "source": "inflection" },
        { "form": "itakute", "tags": ["conjunctive"], "source": "inflection" },
        { "form": "\u75db\u3051\u308c\u3070", "tags": ["conditional"], "source": "inflection" },
        { "form": "\u3044\u305f\u3051\u308c\u3070", "tags": ["conditional"], "source": "inflection" },
        { "form": "itakereba", "tags": ["conditional"], "source": "inflection" },
        { "form": "\u75db\u304b\u3063\u305f\u3089", "tags": ["conditional", "past"], "source": "inflection" },
        { "form": "\u3044\u305f\u304b\u3063\u305f\u3089", "tags": ["conditional", "past"], "source": "inflection" },
        { "form": "itakattara", "tags": ["conditional", "past"], "source": "inflection" },
        { "form": "\u75db\u304b\u308d\u3046", "tags": ["volitional"], "source": "inflection" },
        { "form": "\u3044\u305f\u304b\u308d\u3046", "tags": ["volitional"], "source": "inflection" },
        { "form": "itakar\u014d", "tags": ["volitional"], "source": "inflection" },
        { "form": "\u75db\u304f", "tags": ["adverbial"], "source": "inflection" },
        { "form": "\u3044\u305f\u304f", "tags": ["adverbial"], "source": "inflection" },
        { "form": "itaku", "tags": ["adverbial"], "source": "inflection" },
        { "form": "\u75db\u3055", "tags": ["noun-from-adj"], "source": "inflection" },
        { "form": "\u3044\u305f\u3055", "tags": ["noun-from-adj"], "source": "inflection" },
        { "form": "itasa", "tags": ["noun-from-adj"], "source": "inflection" }
      ],
      "inflection_templates": [
        { "name": "ja-adj-infl", "args": {
          "lemma": "\u75db", "kana": "\u3044\u305f", "imperfective": "\u304b\u308d", "continuative": "\u304f", "terminal": "\u3044", "attributive": "\u3044", "hypothetical": "\u3051\u308c", "imperative": "\u304b\u308c", "informal_negative": "\u304f \u306a\u3044", "informal_past": "\u304b\u3063\u305f", "informal_negative_past": "\u304f \u306a\u304b\u3063\u305f", "formal": "\u3044 \u3067\u3059", "formal_negative": "\u304f \u306a\u3044 \u3067\u3059", "formal_past": "\u304b\u3063\u305f \u3067\u3059", "formal_negative_past": "\u304f \u306a\u304b\u3063\u305f \u3067\u3059", "conjunctive": "\u304f\u3066", "conditional": "\u3051\u308c\u3070", "provisional": "\u304b\u3063\u305f\u3089", "volitional": "\u304b\u308d\u3046", "adverbial": "\u304f", "degree": "\u3055"
        } }
      ],
      "word": "\u75db\u3044",
      "lang": "Japanese",
      "lang_code": "ja",
      "categories": [],
      "derived": [
        { "roman": "kataharaitai", "ruby": "\u304b\u305f\u306f\u3089\u3044\u305f", "english": "ridiculous, absurd", "word": "\u7247\u8179\u75db\u3044", "_dis1": "0 0" },
        { "roman": "teitai", "ruby": "\u3066\u3044\u305f", "english": "situation", "word": "\u624b\u75db\u3044: severe", "_dis1": "0 0" },
        { "roman": "itai itai by\u014d", "ruby": "\u3044\u305f\u3044\u305f\u3073\u3087\u3046", "english": "lit. ouch-ouch-disease", "word": "\u75db\u3044\u75db\u3044\u75c5: itai-itai disease", "_dis1": "0 0" },
        { "roman": "itasha", "ruby": "\u3044\u305f\u3057\u3083", "english": "a vehicle decorated with images of fictional anime, manga, or game characters", "word": "\u75db\u8eca", "_dis1": "0 0" },
        { "roman": "itachari", "ruby": "\u3044\u305f", "english": "a bicycle decorated with images of fictional anime, manga, or game characters", "word": "\u75db\u30c1\u30e3\u30ea", "_dis1": "0 0" },
        { "roman": "itaden", "ruby": "\u3044\u305f\u3067\u3093", "english": "a train car decorated with images of fictional anime, manga, or game characters", "word": "\u75db\u96fb", "_dis1": "0 0" },
        { "roman": "itansha", "ruby": "\u3044\u305f\u3093\u3057\u3083", "english": "a motorcycle decorated with images of fictional anime, manga, or game characters", "word": "\u75db\u5358\u8eca", "_dis1": "0 0" },
        { "roman": "itabeya", "ruby": "\u3044\u305f\u3079\u3084", "english": "a room decorated with images of fictional anime, manga, or game characters", "word": "\u75db\u90e8\u5c4b", "_dis1": "0 0" }
      ],
      "senses": [
        { "raw_glosses": ["painful"], "examples": [
          { "text": "\u982d(\u3042\u305f\u307e)\u304c\u75db(\u3044\u305f)\u3044\u3002\nAtama ga itai.I have a headache.", "type": "example" },
          { "text": "\u304a\u8179(\u306a\u304b)\u304c\u75db(\u3044\u305f)\u3044\u3002\nOnaka ga itai.My stomach hurts.", "type": "example" },
          { "text": "\u75db(\u3044\u305f)\u3063\uff01\nIta'!Ow!", "type": "example" }
        ], "glosses": ["painful"], "id": "\u75db\u3044-ja-adj-X18lPiHr", "categories": [] },
        { "raw_glosses": ["\u30a4\u30bf\u3044: (slang) cringy; embarrassing"], "examples": [
          { "text": "\u300c\u3066\u3063\u304d\u308a\u63a8(\u304a)\u3057\u3092\u81ea(\u3058)\u5206(\u3076\u3093)\u306e\u59b9(\u3044\u3082\u3046\u3068)\u3068\u304b\u8a00(\u3044)\u3063\u3066\u308b\u30a4\u30bf\u3044\u4eba(\u3072\u3068)\u304b\u3068\u601d(\u304a\u3082)\u3063\u3066\u307e\u3057\u305f\u3088\u301c\u300d\n\u201cTekkiri oshi o jibun no im\u014dto to ka itteru itai hito ka to omottemashita yo~\u201d\"I totally thought that you were just one of those embarrassing people who call their favorite idol their little sister or something!\"", "ref": "(Can we date this quote?), \u3044\u305f\u308b, \u201c#31 \u30a2\u30aa\u30d0\u3001\u59b9\u3044\u308b\u3063\u3066\u3088\u201d, in \u30ad\u30e2\u30aa\u30bf\u3001\u30a2\u30a4\u30c9\u30eb\u3084\u308b\u3063\u3066\u3088", "type": "example" }
        ], "glosses": ["\u30a4\u30bf\u3044: (slang) cringy; embarrassing"], "id": "\u75db\u3044-ja-adj-ZmwSz930", "categories": [], "synonyms": [
          { "sense": "embarrassing", "roman": "itaitashii", "ruby": "\u3044\u305f\u3044\u305f", "word": "\u75db\u3005\u3057\u3044", "_dis1": "2 98" }] }
      ] }
  end

  def self.sample_character
    { "pos": "character", "word": "\u72ad", "lang": "Japanese", "lang_code": "ja",
      "senses": [
        { "raw_glosses": ["left \"dog\" radical (\u3051\u3082\u306e\u3078\u3093)"], "tags": ["kanji", "radical"],
          "glosses": ["left \"dog\" radical (\u3051\u3082\u306e\u3078\u3093)"], "id": "\u72ad-ja-character-SxOBP7td",
          "categories": [{ "name": "CJKV radicals", "kind": "other", "parents": [], "source": "w" }],
          "synonyms": [{ "word": "\u72ac" }] }
      ]
    }
  end

  def self.sample_name
    { "pos": "name",
      "head_templates": [
        { "name": "ja-pos", "args": { "1": "proper", "2": "\u3068\u308a" }, "expansion": "\u9149(\u3068\u308a) \u2022 (Tori)" }
      ],
      "forms": [
        { "form": "Tori", "tags": ["romanization"] },
        { "form": "\u3068\u308a", "tags": ["hiragana"] }
      ],
      "wikipedia": ["Earthly Branches", "Rooster (zodiac)"],
      "etymology_number": 1,
      "etymology_text": "From \u9d8f (niwatori, tori, \u201cchicken\u201d), from \u5ead (niwa, \u201cgarden\u201d) + \u9ce5 (tori, \u201cbird\u201d).",
      "etymology_templates": [
        { "name": "ja-kanjitab", "args": { "1": "\u3068\u308a", "yomi": "k" }, "expansion": "" },
        { "name": "wp", "args": { "lang": "ja" }, "expansion": "" },
        { "name": "m", "args": { "1": "ja", "2": "\u9d8f", "tr": "niwatori, tori", "3": "", "4": "chicken" }, "expansion": "\u9d8f (niwatori, tori, \u201cchicken\u201d)" },
        { "name": "m", "args": { "1": "ja", "2": "\u5ead", "tr": "niwa", "3": "", "4": "garden" },
          "expansion": "\u5ead (niwa, \u201cgarden\u201d)" }, { "name": "m", "args": { "1": "ja", "2": "\u9ce5", "tr": "tori", "3": "", "4": "bird" }, "expansion": "\u9ce5 (tori, \u201cbird\u201d)" }
      ],
      "sounds": [
        { "homophone": "\u9ce5" }, { "homophone": "\u9d8f" }
      ],
      "word": "\u9149",
      "lang": "Japanese",
      "lang_code": "ja",
      "senses": [
        { "raw_glosses": ["the Rooster, the tenth of the twelve Earthly Branches"], "glosses": ["the Rooster, the tenth of the twelve Earthly Branches"], "id": "\u9149-ja-name--kFz6D.H", "categories": [{ "name": "Japanese words with multiple readings", "kind": "other", "parents": [], "source": "w+disamb", "_dis": "22 19 11 24 24" }, { "name": "Earthly branches", "kind": "topical", "parents": ["List of sets", "Sexagenary cycle", "All sets", "Calendar terms", "Fundamental", "Timekeeping", "Time", "All topics"], "source": "w+disamb", "orig": "ja:Earthly branches", "langcode": "ja", "_dis": "3 3 5 44 44" }
        ] }
      ] }
  end

  def self.sample_name_2
    { "pos" => "name",
      "head_templates" => [
        { "name" => "ja-pos", "args" => { "1" => "にし", "2" => "proper" }, "expansion" => "西(にし) • (Nishi)" }
      ],
      "forms" => [
        { "form" => "Nishi", "tags" => ["romanization"] }, { "form" => "にし", "tags" => ["hiragana"] }
      ],
      "wikipedia" => ["Edo Castle", "Edo period", "Kyoto", "Shinjuku"], "etymology_number" => 1, "etymology_text" => "From adnominal 往にし (inishi, “leaving, passing”), as the direction of sunset.", "etymology_templates" => [{ "name" => "ja-kanjitab", "args" => { "1" => "にし", "yomi" => "k" }, "expansion" => "" }, { "name" => "m", "args" => { "1" => "ja", "2" => "往にし", "tr" => "inishi", "3" => "", "4" => "leaving, passing" }, "expansion" => "往にし (inishi, “leaving, passing”)" }, { "name" => "rfv-etym", "args" => { "1" => "ja" }, "expansion" => "" }], "word" => "西", "lang" => "Japanese", "lang_code" => "ja", "senses" => [{ "raw_glosses" => ["(Buddhism) Synonym of 西方浄土 (Saihō Jōdo): the western paradise of Amitabha Buddha"], "topics" => ["Buddhism", "lifestyle", "religion"], "glosses" => ["Synonym of 西方浄土 (Saihō Jōdo): the western paradise of Amitabha Buddha"], "synonyms" => [{ "word" => "西方浄土", "extra" => "(Saihō Jōdo): the western paradise of Amitabha Buddha", "tags" => ["synonym", "synonym-of"] }], "id" => "西-ja-name-6BHP7lVR", "categories" => [{ "name" => "Buddhism", "kind" => "topical", "parents" => ["Religion", "Culture", "Society", "All topics", "Fundamental"], "source" => "w", "orig" => "ja:Buddhism", "langcode" => "ja" }] }, { "raw_glosses" => ["(Buddhism) Short for 西本願寺 (Nishi Hongan-ji): a Buddhist temple in Kyoto"], "synonyms" => [{ "word" => "お西" }], "topics" => ["Buddhism", "lifestyle", "religion"], "glosses" => ["Short for 西本願寺 (Nishi Hongan-ji): a Buddhist temple in Kyoto"], "tags" => ["abbreviation", "alt-of"], "alt_of" => [{ "word" => "西本願寺", "extra" => "(Nishi Hongan-ji): a Buddhist temple in Kyoto" }], "id" => "西-ja-name-ULbLboEk", "categories" => [{ "name" => "Buddhism", "kind" => "topical", "parents" => ["Religion", "Culture", "Society", "All topics", "Fundamental"], "source" => "w", "orig" => "ja:Buddhism", "langcode" => "ja" }] }, { "raw_glosses" => ["(historical) a red-light district in Edo-period Shinjuku (as it was located west of Edo Castle)"], "tags" => ["historical"], "glosses" => ["a red-light district in Edo-period Shinjuku (as it was located west of Edo Castle)"], "id" => "西-ja-name-Ke3.0j9j", "categories" => [] }, { "raw_glosses" => ["a place name, especially the name of various wards in major cities throughout Japan"], "glosses" => ["a place name, especially the name of various wards in major cities throughout Japan"], "id" => "西-ja-name-fPfzj.UM" }, { "raw_glosses" => ["a surname"], "glosses" => ["a surname"], "id" => "西-ja-name-v2O7m9sM", "categories" => [{ "name" => "Japanese surnames", "kind" => "other", "parents" => [], "source" => "w" }] }] }
  end

  # entry: [:word]
  # reading: [:head_templates][0][:args][:"1"]
  # pos: [:pos]
  # meaning:
  def self.sample_noun
    { "pos": "noun",
      "head_templates": [
        { "name": "ja-noun", "args": { "1": "\u304b\u305a" }, "expansion": "\u6570(\u304b\u305a) \u2022 (kazu)" }
      ],
      "forms": [
        { "form": "kazu", "tags": ["romanization"] },
        { "form": "\u304b\u305a", "tags": ["hiragana"] }
      ],
      "etymology_number": 1, "etymology_text": "",
      "etymology_templates": [
        { "name": "ja-kanjitab", "args": { "1": "\u304b\u305a", "yomi": "k" }, "expansion": "" },
        { "name": "inh", "args": { "1": "ja", "2": "ojp", "3": "-" }, "expansion": "Old Japanese" }
      ],
      "word": "\u6570",
      "lang": "Japanese",
      "lang_code": "ja",
      "categories": [],
      "senses": [
        { "raw_glosses": ["number; amount"], "examples": [{ "text": "hito no kazu'number' of people", "ref": "\u4eba(\u3072\u3068)\u306e\u6570(\u304b\u305a)", "type": "example" },
                                                          { "text": "yozora no hoshi no kazuthe number of stars in the night sky", "ref": "\u591c(\u3088)\u7a7a(\u305e\u3089)\u306e\u661f(\u307b\u3057)\u306e\u6570(\u304b\u305a)", "type": "example" }],
          "glosses": ["number; amount"], "id": "\u6570-ja-noun-tFLeo5Hh", "categories": [],
          "derived": [
            { "word": "\u6570\u3005" },
            { "roman": "kazukazu", "word": "\u6570\u6570" },
            { "roman": "kazuteki", "ruby": "\u304b\u305a\u3066\u304d", "word": "\u6570\u7684" },
            { "roman": "kazufuda", "ruby": "\u304b\u305a\u3075\u3060", "word": "\u6570\u672d" },
            { "roman": "kazuya", "ruby": "\u304b\u305a\u3084", "word": "\u6570\u77e2" },
            { "roman": "okazu", "ruby": "\u304a\u304b\u305a", "word": "\u5fa1\u6570" },
            { "roman": "kuchikazu", "ruby": "\u304f\u3061\u304b\u305a", "word": "\u53e3\u6570" },
            { "roman": "hitokazu", "ruby": "\u3072\u3068\u304b\u305a", "word": "\u4eba\u6570" },
            { "roman": "kazuhagond\u014d", "ruby": "\u30ab\u30ba\u30cf\u30b4\u30f3\u30c9\u30a6", "word": "\u6570\u6b6f\u5de8\u982d" }
          ] }] }
  end

  def self.sample_romanization
    { "pos" => "romanization",
      "head_templates" => [
        { "name" => "head", "args" => { "1" => "ja", "2" => "romanization", "head" => "", "sc" => "Latn" }, "expansion" => "kun" }
      ],
      "word" => "kun",
      "lang" => "Japanese",
      "lang_code" => "ja",
      "senses" => [
        { "raw_glosses" => ["Rōmaji transcription of くん"],
          "tags" => ["Rōmaji", "alt-of", "romanization"],
          "glosses" => ["Rōmaji transcription of くん"],
          "alt_of" => [{ "word" => "くん" }],
          "id" => "kun-ja-romanization-vAWbA1F8",
          "categories" => [{ "name" => "Japanese romanizations", "kind" => "other", "parents" => [], "source" => "w" }]
        }]
    }
  end

  def self.sample_counter
    { "pos" => "counter",
      "head_templates" => [
        { "name" => "ja-pos", "args" => { "1" => "counter", "2" => "げつ", "hhira" => "ぐゑつ" }, "expansion" => "月(げつ) • (-getsu) ^(←ぐゑつ (gwetu)?)" }
      ],
      "forms" => [
        { "form" => "-getsu", "tags" => ["romanization"] },
        { "form" => "gwetu", "tags" => ["romanization"] },
        { "form" => "ぐゑつ", "roman" => "gwetu",
          "tags" => ["hiragana", "historical"] },
        { "form" => "げつ", "tags" => ["hiragana"] }
      ],
      "etymology_number" => 3,
      "etymology_text" => "/ɡʷetu/ → /ɡet͡su/\nFrom Middle Chinese 月 (ŋʉɐt̚).\nThe 漢音 (kan'on) reading, so likely a later borrowing. Compare modern Hakka 月 (ngie̍t), Min Nan 月 (ge̍h).",
      "etymology_templates" => [
        { "name" => "ja-kanjitab",
          "args" => { "yomi" => "kanon", "1" => "げつ" }, "expansion" => "" },
        { "name" => "der", "args" => { "1" => "ja", "2" => "ltc", "sort" => "かつ", "3" => "月", "tr" => "ŋʉɐt̚" }, "expansion" => "Middle Chinese 月 (ŋʉɐt̚)" },
        { "name" => "m", "args" => { "1" => "ja", "2" => "漢音", "tr" => "kan'on" }, "expansion" => "漢音 (kan'on)" },
        { "name" => "cog", "args" => { "1" => "hak", "2" => "月", "tr" => "ngie̍t" }, "expansion" => "Hakka 月 (ngie̍t)" },
        { "name" => "cog", "args" => { "1" => "nan", "2" => "月", "tr" => "ge̍h" }, "expansion" => "Min Nan 月 (ge̍h)" }
      ],
      "word" => "月",
      "lang" => "Japanese",
      "lang_code" => "ja",
      "derived" => [{ "roman" => "-kagetsu", "word" => "ヶ月", "_dis1" => "0 0" }],
      "senses" => [
        { "raw_glosses" => ["a month as a duration of time"],
          "glosses" => ["a month as a duration of time"],
          "id" => "月-ja-counter-1NoRn6hC",
          "categories" => [{ "name" => "Japanese affixes", "kind" => "other", "parents" => [], "source" => "w+disamb", "_dis" => "11 12 28 27 6 17" }, { "name" => "Days of the week", "kind" => "topical", "parents" => ["List of sets", "Periodic occurrences", "All sets", "Time", "Fundamental", "All topics"], "source" => "w+disamb", "orig" => "ja:Days of the week", "langcode" => "ja", "_dis" => "1 0 14 0 14 6 0 16 7 3 1 0 0 1 1 1 12 2 5 3 5 1 7" }, { "name" => "Time", "kind" => "topical", "parents" => ["All topics", "Fundamental"], "source" => "w+disamb", "orig" => "ja:Time", "langcode" => "ja", "_dis" => "0 0 11 0 11 9 0 31 6 0 0 0 0 0 0 0 9 2 7 1 7 0 6" }
          ] },
        { "raw_glosses" => ["(possibly obsolete) month of the year"], "tags" => ["obsolete", "possibly"], "glosses" => ["month of the year"], "id" => "月-ja-counter-osLdExlH", "categories" => [] }] }
  end

  def self.sample_dvd
    { "pos" => "noun",
      "head_templates" => [{ "name" => "ja-noun", "args" => { "1" => "ディー%ブイ%ディー" }, "expansion" => "D(ディー)V(ブイ)D(ディー) • (dībuidī)" }],
      "forms" => [{ "form" => "D (ディー)V (ブイ)D", "tags" => ["canonical"] }, { "form" => "dībuidī", "tags" => ["romanization"] },
                  { "form" => "ディー", "tags" => ["error-unknown-tag"] }], "etymology_text" => "From English DVD.",
      "etymology_templates" => [{ "name" => "bor", "args" => { "1" => "ja", "2" => "en", "3" => "DVD", "sort" => "てぃいぶいでぃい'" }, "expansion" => "English DVD" }], "word" => "DVD", "lang" => "Japanese", "lang_code" => "ja", "senses" => [{ "raw_glosses" => ["a DVD"], "glosses" => ["a DVD"], "wikipedia" => ["ja:DVD"], "id" => "DVD-ja-noun-KpmdQgmJ", "categories" => [], "related" => [{ "roman" => "dejitaru", "word" => "デジタル" }, { "roman" => "bideo", "word" => "ビデオ" }, { "roman" => "disuku", "word" => "ディスク" }] }] }
  end

end