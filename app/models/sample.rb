class Sample < ApplicationRecord
  require 'ox'
  require "json"
  require "csv"

  def self.parse
    filename = 'tmp/jawiktionary_sample.xml'
    doc = REXML::Document.new(open(filename))
    doc.elements.each('/mediawiki/page') do |name|
      puts name.text # one, two, threeを順に表示する
    end
  end

  def self.test
    filename = 'sample.xml'
    dom = REXML::Document.new(open(filename))
    dom.elements.each('/root/data') do |name|
      puts name.text # one, two, threeを順に表示する
    end
  end

  def self.test_2
    filename = 'tmp/jawiktionary_sample.xml'
    file_str = open(filename).read
    hash = Ox.load(file_str, mode: :hash_no_attrs)
    hash[:mediawiki][:page]
    #pages = hash[:mediawiki][:page]
    #pages.each {|p| p[:title]}

    #dom = REXML::Document.new()
    #title = []
    #text = []
    #dom.elements.each('/mediawiki/page/revision/text') do |name|
    #  puts name.text   # one, two, threeを順に表示する
    #end
  end


  def self.export_test
    # 参考： https://www.buildinsider.net/language/rubytips/0021
    title_ary = []
    text_ary = []
    filename = 'tmp/jawiktionary.xml'
    p 'open file START'
    file = open(filename)
    p 'open file END'
    p 'Document.new START'
    dom = REXML::Document.new(file)
    p 'Document.new END'
    # title
    dom.elements.each('/mediawiki/page/title') do |name|
      p name.text
      title_ary << name.text
    end
    # 本文
    dom.elements.each('/mediawiki/page/revision/text') do |name|
      text_ary << name.text
    end

    # 原文と翻訳文を１行にまとめて、配列を組み直す。
    array = [title_ary, text_ary].transpose

    csv_data = CSV.generate do |csv|
      header = %w[title text]
      csv << header
      array.each_with_index do |a, i|
        p a[0]
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

  def self.json_load
    data = File.open('sample.txt') do |f|
      JSON.load(f)
    end
    data
  end

  def self.text_load
    #f = File.open("sample_text.txt")
    #s = f.read  # 全て読み込む
    #f.close
    #s
    File.open("tmp/sample_text.txt", mode = "rt") { |f|
      f.readlines
    }
  end

  # メモ
  # Entry: json_1['word']
  # IPA: json_1['sounds'][0]['ipa']
  # Meaning: json_1['senses'][1]['raw_glosses'][0]
  # Explanation: json_1['etymology_text']
  # Etymologies: json_1['etymology_text']
  # Synonyms: json_1['senses'][1]['synonyms'][0]['word']
  # Antonyms: json_1['senses'][1]['antonyms'][0]['word']
  # Related: json_1['related'][0]['word']




  def self.verbs
    '{"pos": "verb",
"head_templates": [{"name": "en-verb", "args": {"1": "abegges", "2": "abegging", "3": "abought", "past2": "abegged"}, "expansion": "abegge (third-person singular simple present abegges, present participle abegging, simple past and past participle abought or abegged)"}],
"forms": [{"form": "abegges", "tags": ["present", "singular", "third-person"]}, {"form": "abegging", "tags": ["participle", "present"]}, {"form": "abought", "tags": ["participle", "past"]}, {"form": "abought", "tags": ["past"]}, {"form": "abegged", "tags": ["participle", "past"]}, {"form": "abegged", "tags": ["past"]}], "word": "abegge", "lang": "English", "lang_code": "en",
"sounds": [{"ipa": "/\u0259\u02c8b\u025bd\u0361\u0292/"}, {"rhymes": "-\u025bd\u0292"}], "senses": [{"raw_glosses": ["(obsolete) Alternative form of aby"], "tags": ["alt-of", "alternative", "obsolete"], "glosses": ["Alternative form of aby"], "alt_of": [{"word": "aby"}], "id": "abegge-en-verb-9gXbcJ2g", "categories": []}]}'
  end

  def self.json_verb
    {"pos"=>"verb",
     "head_templates"=>[
         {"name"=>"en-verb", "args"=>{"1"=>"abegges", "2"=>"abegging", "3"=>"abought", "past2"=>"abegged"}, "expansion"=>"abegge (third-person singular simple present abegges, present participle abegging, simple past and past participle abought or abegged)"}
     ],
     "forms"=>[
         {"form"=>"abegges", "tags"=>["present", "singular", "third-person"]},
         {"form"=>"abegging", "tags"=>["participle", "present"]},
         {"form"=>"abought", "tags"=>["participle", "past"]},
         {"form"=>"abought", "tags"=>["past"]},
         {"form"=>"abegged", "tags"=>["participle", "past"]},
         {"form"=>"abegged", "tags"=>["past"]}],
     "word"=>"abegge", "lang"=>"English", "lang_code"=>"en",
     "sounds"=>[{"ipa"=>"/əˈbɛd͡ʒ/"}, {"rhymes"=>"-ɛdʒ"}],
     "senses"=>[{"raw_glosses"=>["(obsolete) Alternative form of aby"], "tags"=>["alt-of", "alternative", "obsolete"],
                 "glosses"=>["Alternative form of aby"], "alt_of"=>[{"word"=>"aby"}], "id"=>"abegge-en-verb-9gXbcJ2g", "categories"=>[]}]}

  end

  def self.json_parse_1
    text = '{"pos": "noun", "head_templates": [{"name": "en-noun", "args": {}, "expansion": "vintner (plural vintners)"}], "forms": [{"form": "vintners", "tags": ["plural"]}], "etymology_text": "From Middle English vyntener, variant of viniter, from Old French vineter, vinetier (\u201cwine-merchant, grape-harvester\u201d), from Medieval Latin v\u012bn\u0113t\u0101rius (\u201cwine dealer\u201d), from v\u012bn\u0113tum (\u201cvineyard\u201d), from v\u012bnum (\u201cwine\u201d).", "etymology_templates": [{"name": "inh", "args": {"1": "en", "2": "enm", "3": "vyntener"}, "expansion": "Middle English vyntener"}, {"name": "m", "args": {"1": "enm", "2": "viniter"}, "expansion": "viniter"}, {"name": "der", "args": {"1": "en", "2": "fro", "3": "vineter"}, "expansion": "Old French vineter"}, {"name": "m", "args": {"1": "fro", "2": "vinetier", "3": "", "4": "wine-merchant, grape-harvester"}, "expansion": "vinetier (\u201cwine-merchant, grape-harvester\u201d)"}, {"name": "der", "args": {"1": "en", "2": "ML.", "3": "v\u012bn\u0113t\u0101rius", "4": "", "5": "wine dealer"}, "expansion": "Medieval Latin v\u012bn\u0113t\u0101rius (\u201cwine dealer\u201d)"}, {"name": "m", "args": {"1": "la", "2": "v\u012bn\u0113tum", "3": "", "4": "vineyard"}, "expansion": "v\u012bn\u0113tum (\u201cvineyard\u201d)"}, {"name": "m", "args": {"1": "la", "2": "v\u012bnum", "3": "", "4": "wine"}, "expansion": "v\u012bnum (\u201cwine\u201d)"}], "sounds": [{"ipa": "/\u02c8v\u026antn\u025a/", "tags": ["General-American"]}, {"ipa": "/\u02c8v\u026antn\u0259/", "tags": ["Received-Pronunciation"]}], "word": "vintner", "lang": "English", "lang_code": "en", "senses": [{"raw_glosses": ["A seller of wine."], "glosses": ["A seller of wine."], "id": "vintner-en-noun-PH76qgCa", "translations": [{"lang": "Bulgarian", "code": "bg", "sense": "seller of wine", "roman": "t\u01cergovec na vino", "word": "\u0442\u044a\u0440\u0433\u043e\u0432\u0435\u0446 \u043d\u0430 \u0432\u0438\u043d\u043e", "_dis1": "87 13"}, {"lang": "Finnish", "code": "fi", "sense": "seller of wine", "word": "viininmyyj\u00e4", "_dis1": "87 13"}, {"lang": "Finnish", "code": "fi", "sense": "seller of wine", "word": "viinikauppias", "_dis1": "87 13"}, {"lang": "French", "code": "fr", "sense": "seller of wine", "tags": ["masculine"], "word": "n\u00e9gociant en vins", "_dis1": "87 13"}, {"lang": "Galician", "code": "gl", "sense": "seller of wine", "word": "arrieiro", "_dis1": "87 13"}, {"lang": "German", "code": "de", "sense": "seller of wine", "tags": ["masculine"], "word": "Weinh\u00e4ndler", "_dis1": "87 13"}, {"lang": "German", "code": "de", "sense": "seller of wine", "tags": ["feminine"], "word": "Weinh\u00e4ndlerin", "_dis1": "87 13"}, {"lang": "Middle English", "code": "enm", "sense": "seller of wine", "word": "vyntener", "_dis1": "87 13"}, {"lang": "Middle English", "code": "enm", "sense": "seller of wine", "word": "viniter", "_dis1": "87 13"}, {"lang": "Russian", "code": "ru", "sense": "seller of wine", "roman": "vinotorg\u00f3vec", "tags": ["masculine"], "word": "\u0432\u0438\u043d\u043e\u0442\u043e\u0440\u0433\u043e\u0301\u0432\u0435\u0446", "_dis1": "87 13"}], "categories": [{"name": "Grapevines", "kind": "lifeform", "parents": ["Grape family plants", "List of sets", "Wine", "Plants", "All sets", "Alcoholic beverages", "Lifeforms", "Fundamental", "Beverages", "Drinking", "Recreational drugs", "Nature", "Food and drink", "Liquids", "Human behaviour", "Drugs", "All topics", "Matter", "Human", "Pharmacology", "Chemistry", "Biochemistry", "Medicine", "Sciences", "Biology"], "source": "w+disamb", "orig": "en:Grapevines", "langcode": "en", "_dis": "51 49"}, {"name": "Occupations", "kind": "topical", "parents": ["List of sets", "People", "All sets", "Human", "Fundamental", "All topics"], "source": "w+disamb", "orig": "en:Occupations", "langcode": "en", "_dis": "76 24"}, {"name": "People", "kind": "topical", "parents": ["Human", "All topics", "Fundamental"], "source": "w+disamb", "orig": "en:People", "langcode": "en", "_dis": "73 27"}]}, {"raw_glosses": ["A manufacturer of wine."], "glosses": ["A manufacturer of wine."], "id": "vintner-en-noun-AYe0cDYP", "translations": [{"lang": "Bulgarian", "code": "bg", "sense": "manufacturer of wine", "roman": "proizvoditel na vino", "word": "\u043f\u0440\u043e\u0438\u0437\u0432\u043e\u0434\u0438\u0442\u0435\u043b \u043d\u0430 \u0432\u0438\u043d\u043e", "_dis1": "13 87"}, {"lang": "Dutch", "code": "nl", "sense": "manufacturer of wine", "tags": ["masculine"], "word": "wijnboer", "_dis1": "13 87"}, {"lang": "Dutch", "code": "nl", "sense": "manufacturer of wine", "tags": ["masculine"], "word": "wijndruiventeler", "_dis1": "13 87"}, {"lang": "Dutch", "code": "nl", "sense": "manufacturer of wine", "tags": ["masculine"], "word": "wijngaardenier", "_dis1": "13 87"}, {"lang": "Finnish", "code": "fi", "sense": "manufacturer of wine", "word": "viinintuottaja", "_dis1": "13 87"}, {"lang": "Finnish", "code": "fi", "sense": "manufacturer of wine", "word": "viinintekij\u00e4", "_dis1": "13 87"}, {"lang": "French", "code": "fr", "sense": "manufacturer of wine", "tags": ["masculine"], "word": "vinificateur", "_dis1": "13 87"}, {"lang": "Galician", "code": "gl", "sense": "manufacturer of wine", "word": "adegueiro", "_dis1": "13 87"}, {"lang": "Galician", "code": "gl", "sense": "manufacturer of wine", "word": "viticultor", "_dis1": "13 87"}, {"lang": "German", "code": "de", "sense": "manufacturer of wine", "tags": ["masculine"], "word": "Winzer", "_dis1": "13 87"}, {"lang": "German", "code": "de", "sense": "manufacturer of wine", "tags": ["feminine"], "word": "Winzerin", "_dis1": "13 87"}, {"lang": "Greek", "code": "grc", "tags": ["Ancient", "masculine"], "sense": "manufacturer of wine", "roman": "oinopoi\u00f3s", "word": "\u03bf\u1f30\u03bd\u03bf\u03c0\u03bf\u03b9\u03cc\u03c2", "_dis1": "13 87"}, {"lang": "Italian", "code": "it", "sense": "manufacturer of wine", "tags": ["masculine"], "word": "vinificatore", "_dis1": "13 87"}, {"lang": "Romanian", "code": "ro", "sense": "manufacturer of wine", "tags": ["masculine"], "word": "viticultor", "_dis1": "13 87"}, {"lang": "Russian", "code": "ru", "sense": "manufacturer of wine", "roman": "vinod\u00e9l", "tags": ["masculine"], "word": "\u0432\u0438\u043d\u043e\u0434\u0435\u0301\u043b", "_dis1": "13 87"}, {"lang": "Spanish", "code": "es", "sense": "manufacturer of wine", "tags": ["masculine"], "word": "vinatero", "_dis1": "13 87"}], "synonyms": [{"sense": "manufacturer of wine", "word": "winemaker", "_dis1": "13 87"}], "categories": [{"name": "Grapevines", "kind": "lifeform", "parents": ["Grape family plants", "List of sets", "Wine", "Plants", "All sets", "Alcoholic beverages", "Lifeforms", "Fundamental", "Beverages", "Drinking", "Recreational drugs", "Nature", "Food and drink", "Liquids", "Human behaviour", "Drugs", "All topics", "Matter", "Human", "Pharmacology", "Chemistry", "Biochemistry", "Medicine", "Sciences", "Biology"], "source": "w+disamb", "orig": "en:Grapevines", "langcode": "en", "_dis": "51 49"}]}]}'
    JSON.parse(text)
  end

  # formsに保存する内容
  # forms = json['forms']
  # forms[0]['form'] + forms['tags']
  # array = [forms[0]['form']] << forms[0]['tags']
  # array.to_s

  def self.line_first
    #text = File.open('sample_text.txt').read
    #first_text = text.lines.first
    #JSON.parse(first_text)

    i = 0
    json = ""
    File.foreach('tmp/en_dictionary_text.txt') do |line|
      if i.zero?
        json = JSON.parse(line)
      end
      i += 1
    end
    json
  end

  def self.export_csv(file_name)
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
    dictionary_id = []
    File.foreach(file_name) do |line|
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
      forms_json << json['forms']
      sounds_json << json['sounds']
      senses_json << json['senses']
      categories_json << json['categories']
      topics_json << json['topics']
      translations_json << json['translations']
      etymology_templates_json << json['etymology_templates']
      head_templates_json << json['head_templates']
      inflection_templates_json << json['inflection_templates']
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
      dictionary_id << 5
    end

    # 原文と翻訳文を１行にまとめて、配列を組み直す。
    array = [entry, entry_en, lang_number_of_entry, meaning, lang_number_of_meaning, ipa, pos, etymologies, explanation,
             forms_json, sounds_json, senses_json, categories_json, topics_json, translations_json,
             etymology_templates_json, head_templates_json, inflection_templates_json,
             synonyms, antonyms, hypernyms, holonyms, meronyms, coordinate_terms, related, derived,
             wikidata, wiktionary, dictionary_id].transpose

    csv_data = CSV.generate do |csv|
      header = %w[entry entry_en lang_number_of_entry meaning lang_number_of_meaning ipa pos etymologies explanation
                  forms_json sounds_json senses_json categories_json topics_json translations_json
                  etymology_templates_json head_templates_json inflection_templates_json
                  synonyms antonyms hypernyms holonyms meronyms coordinate_terms related derived
                  wikidata wiktionary dictionary_id]
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


  def self.limit_1000
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
    sentence_id = []
    dictionary_id = []
    created_at = []
    updated_at = []

    i = 0
    CSV.foreach('tmp/en_dictionary_csv.csv', headers: true) do |data|
      break if i > 1000

      entry << data['entry']
      entry_en << data['entry_en']
      lang_number_of_entry << data['lang_number_of_entry']
      meaning << data['meaning']
      lang_number_of_meaning << data['lang_number_of_meaning']
      ipa << data['ipa']
      pos << data['pos']
      etymologies << data['etymologies']
      explanation << data['explanation']

      forms_json << data['forms_json']
      sounds_json << data['sounds_json']
      senses_json << data['senses_json']
      categories_json << data['categories_json']
      topics_json << data['topics_json']
      translations_json << data['translations_json']
      etymology_templates_json << data['etymology_templates_json']
      head_templates_json << data['head_templates_json']
      inflection_templates_json << data['inflection_templates_json']

      synonyms << data['synonyms']
      antonyms << data['antonyms']
      hypernyms << data['hypernyms']
      holonyms << data['holonyms']
      meronyms << data['meronyms']
      coordinate_terms << data['coordinate_terms']
      related << data['related']
      derived << data['derived']
      wikidata << data['wikidata']
      wiktionary << data['wiktionary']
      sentence_id << nil
      dictionary_id << data['dictionary_id']
      created_at << data['created_at']
      updated_at << data['updated_at']
      i += 1
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
    File.open("./#{current_time}_limit_1000.csv", 'w') do |file|
      file.write(csv_data)
    end
  end




end