# wiktionaryをパースして辞書を作るなどする
# データは、https://github.com/tatuylonen/wiktextract
# https://kaikki.org/dictionary/English/index.html
class EnWiktionary < ApplicationRecord
  require 'ox'
  require "json"
  require "csv"

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
    File.foreach('tmp/en_dictionary.json') do |line|
      json = JSON.parse(line)
      next if json.blank?
      meaning_text = JsonUtility.meaning(json['senses'], 200)
      next if meaning_text.blank?

      entry << json['word']
      entry_en << json['word']
      lang_number_of_entry << 21
      meaning << meaning_text
      lang_number_of_meaning << 21
      ipa << EnWiktionary.ipa(json['sounds'])
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
      wiktextract_json << json
      #
      sentence_id << nil
      # 要設定
      dictionary_id << 8
      created_at << '2022-12-06 15:44:44.834394'
      updated_at << '2022-12-06 15:44:44.834394'
    end

    # 原文と翻訳文を１行にまとめて、配列を組み直す。
    array = [entry, entry_en, lang_number_of_entry, meaning, lang_number_of_meaning, ipa, pos, etymologies, explanation,
             synonyms, antonyms, hypernyms, holonyms, meronyms, coordinate_terms, related, derived,
             wiktextract_json,
             sentence_id, dictionary_id, created_at, updated_at].transpose

    csv_data = CSV.generate do |csv|
      header = %w[entry entry_en lang_number_of_entry meaning lang_number_of_meaning ipa pos etymologies explanation
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


  ##### sampleデータ #####
  def sample_noun
    {"pos" => "noun",
     "head_templates" => [{"name" => "en-noun", "args" => {"1" => "~"}, "expansion" => "grape (countable and uncountable, plural grapes)"}],
     "forms" => [{"form" => "grapes", "tags" => ["plural"]}],
     "etymology_text" => "From Middle English grape, from Old French grape, grappe, crape (“cluster of fruit or flowers, bunch of grapes”), from graper, craper (“to pick grapes”, literally “to hook”), of Germanic origin, from Frankish *krappō (“hook”), from Proto-Indo-European *greb- (“hook”), *gremb- (“crooked, uneven”), from *ger- (“to turn, bend, twist”). Cognate with Middle Dutch krappe (“hook”), Old High German krapfo (“hook”) (whence German Krapfen (“Berliner doughnut”). Doublet of grappa. More at cramp.",
     "etymology_templates" => [
       {"name" => "inh", "args" => {"1" => "en", "2" => "enm", "3" => "grape"}, "expansion" => "Middle English grape"},
       {"name" => "der", "args" => {"1" => "en", "2" => "fro", "3" => "grape, grappe, crape", "t" => "cluster of fruit or flowers, bunch of grapes"}, "expansion" => "Old French grape, grappe, crape (“cluster of fruit or flowers, bunch of grapes”)"},
       {"name" => "m", "args" => {"1" => "fro", "2" => "graper, craper", "t" => "to pick grapes", "lit" => "to hook"}, "expansion" => "graper, craper (“to pick grapes”, literally “to hook”)"},
       {"name" => "cog", "args" => {"1" => "gem"}, "expansion" => "Germanic"},
       {"name" => "der", "args" => {"1" => "en", "2" => "frk", "3" => "*krappō", "t" => "hook"}, "expansion" => "Frankish *krappō (“hook”)"},
       {"name" => "der", "args" => {"1" => "en", "2" => "ine-pro", "3" => "*greb-", "t" => "hook"}, "expansion" => "Proto-Indo-European *greb- (“hook”)"},
       {"name" => "m", "args" => {"1" => "ine-pro", "2" => "*gremb-", "t" => "crooked, uneven"}, "expansion" => "*gremb- (“crooked, uneven”)"},
       {"name" => "m", "args" => {"1" => "ine-pro", "2" => "*ger-", "t" => "to turn, bend, twist"}, "expansion" => "*ger- (“to turn, bend, twist”)"},
       {"name" => "cog", "args" => {"1" => "dum", "2" => "krappe", "t" => "hook"}, "expansion" => "Middle Dutch krappe (“hook”)"},
       {"name" => "cog", "args" => {"1" => "goh", "2" => "krapfo", "t" => "hook"}, "expansion" => "Old High German krapfo (“hook”)"},
       {"name" => "cog", "args" => {"1" => "de", "2" => "Krapfen", "t" => "Berliner doughnut"}, "expansion" => "German Krapfen (“Berliner doughnut”)"},
       {"name" => "doublet", "args" => {"1" => "en", "2" => "grappa"}, "expansion" => "Doublet of grappa"},
       {"name" => "l", "args" => {"1" => "en", "2" => "cramp"}, "expansion" => "cramp"}
     ],
     "sounds" => [
       {"ipa" => "/ɡɹeɪp/"},
       {"rhymes" => "-eɪp"},
       {"audio" => "En-uk-grape.ogg", "text" => "Audio (UK)", "tags" => ["UK"], "ogg_url" => "https://upload.wikimedia.org/wikipedia/commons/6/62/En-uk-grape.ogg", "mp3_url" => "https://upload.wikimedia.org/wikipedia/commons/transcoded/6/62/En-uk-grape.ogg/En-uk-grape.ogg.mp3"},
       {"audio" => "en-us-grape.ogg", "text" => "Audio (US)", "tags" => ["US"], "ogg_url" => "https://upload.wikimedia.org/wikipedia/commons/0/0f/En-us-grape.ogg", "mp3_url" => "https://upload.wikimedia.org/wikipedia/commons/transcoded/0/0f/En-us-grape.ogg/En-us-grape.ogg.mp3"},
       {"enpr" => "grāp"}
     ],
     "word" => "grape",
     "lang" => "English",
     "lang_code" => "en",
     "derived" => [
       {"taxonomic" => "Vitis amurensis", "word" => "Amur grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis vulpina", "word" => "arroyo grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Arctostaphylos uva-ursi", "word" => "bear's grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis munsoniana", "word" => "bird grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis rotundifolia", "word" => "bullace grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis rotundifolia", "word" => "bull grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis aestivalis", "word" => "bunch grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Baccaurea ramiflora", "word" => "Burmese grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"alt" => "Vitis rupestris; Vitis acerifolia", "word" => "bush grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis arizonica", "word" => "canyon grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Cissus capensis", "word" => "Cape grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis palmata", "word" => "catbird grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis palmata", "word" => "cat grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis vulpina", "word" => "chicken grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis labrusca variety", "word" => "Concord grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"alt" => "Ampelopsis cordata; Vitis labrusca", "word" => "coon grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis cinerea", "word" => "downy grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Phytolacca americana", "word" => "dyer's grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis vinifera", "word" => "European grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis munsoniana", "word" => "everbearing grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"alt" => "Vitis labrusca et al.", "word" => "fox grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis vulpina", "word" => "frost grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"word" => "grape fern", "_dis1" => "0 0 0 0 0 0 0"},
       {"word" => "grapefruit", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Muscari spp.", "word" => "grape hyacinth", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Parthenocissus tricuspidata", "word" => "grape ivy", "_dis1" => "0 0 0 0 0 0 0"},
       {"word" => "grapeshot", "_dis1" => "0 0 0 0 0 0 0"},
       {"word" => "grape sugar", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis spp.", "word" => "grapevine", "_dis1" => "0 0 0 0 0 0 0"},
       {"word" => "grapey", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Cissus antarctica", "word" => "kangaroo grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"word" => "Mission grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis palmata", "word" => "Missouri grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"alt" => "Vitis rupestris; Mahonia aquifolium", "word" => "mountain grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis rotundifolia", "word" => "muscadine grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis candicans", "word" => "mustang grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis candicans", "word" => "mustard grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Mahonia aquifolium", "word" => "Oregon grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis aestivalis", "word" => "pigeon grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis labrusca var. lincecumii", "word" => "pinewoods grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"alt" => "Vitis labrusca et al.", "word" => "plum grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"alt" => "Vitis vulpina; Vitis baileyana; Cissus spp.", "word" => "possum grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis labrusca var. lincecumii", "word" => "post-oak grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"alt" => "Vitis labrusca et al.; Ampelopsis cordata", "word" => "racoon grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis riparia", "word" => "riverbank grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis vulpina", "word" => "river grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"alt" => "Vitis vulpina; Vitis riparia", "word" => "riverside grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Mahonia aquifolium", "word" => "Rocky Mountain grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Medinilla magnifica", "word" => "rose grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis rupestris", "word" => "sandbeach grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis rupestris", "word" => "sand grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"word" => "sea grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"word" => "seaside grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"alt" => "Vitis labrusca et al.", "word" => "shore grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis lambrusca", "word" => "skunk grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"english" => "Concord grape", "word" => "slipskin grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"word" => "sour grapes", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis rupestris", "word" => "sugar grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis aestivalis", "word" => "summer grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Artabotrys spp.", "word" => "tail grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis labrusca var. lincecumii", "word" => "turkey grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Rhoicissus capensis", "word" => "wild grape (Vitis spp.;", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis vinifera", "word" => "wine grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"taxonomic" => "Vitis vulpina", "word" => "winter grape", "_dis1" => "0 0 0 0 0 0 0"},
       {"alt" => "Vitis vulpina; Solanum dulcamara", "word" => "wolf grape", "_dis1" => "0 0 0 0 0 0 0"}
     ],
     "related" => [
       {"word" => "grapnel", "_dis1" => "0 0 0 0 0 0 0"},
       {"word" => "grappa", "_dis1" => "0 0 0 0 0 0 0"},
       {"word" => "grapple", "_dis1" => "0 0 0 0 0 0 0"}
     ],
     "senses" => [
       {"raw_glosses" => ["(countable) A woody vine that bears clusters of grapes; a grapevine; of genus Vitis."],
        "tags" => ["countable"],
        "glosses" => ["A woody vine that bears clusters of grapes; a grapevine; of genus Vitis."],
        "id" => "grape-en-noun-IALeOIAq",
        "categories" => [
          {"name" => "Grapevines",
           "kind" => "lifeform",
           "parents" => ["Grape family plants", "List of sets", "Wine", "Plants", "All sets", "Alcoholic beverages", "Lifeforms", "Fundamental", "Beverages", "Drinking", "Recreational drugs", "Nature", "Food and drink", "Liquids", "Human behaviour", "Drugs", "All topics", "Matter", "Human", "Pharmacology", "Chemistry", "Biochemistry", "Medicine", "Sciences", "Biology"],
           "source" => "w+disamb",
           "orig" => "en:Grapevines",
           "langcode" => "en",
           "_dis" => "5 2 14 26 3 7 2 4 8 4 4 6 5 10"}
        ]
       }
     ]}
  end

  def sample_noun_2
    {"pos"=>"noun", "head_templates"=>[{"name"=>"en-noun", "args"=>{}, "expansion"=>"vintner (plural vintners)"}],
     "forms"=>[{"form"=>"vintners", "tags"=>["plural"]}],
     "etymology_text"=>"From Middle English vyntener, variant of viniter, from Old French vineter, vinetier (“wine-merchant, grape-harvester”), from Medieval Latin vīnētārius (“wine dealer”), from vīnētum (“vineyard”), from vīnum (“wine”).",
     "etymology_templates"=>[{"name"=>"inh", "args"=>{"1"=>"en", "2"=>"enm", "3"=>"vyntener"}, "expansion"=>"Middle English vyntener"}, {"name"=>"m", "args"=>{"1"=>"enm", "2"=>"viniter"}, "expansion"=>"viniter"}, {"name"=>"der", "args"=>{"1"=>"en", "2"=>"fro", "3"=>"vineter"}, "expansion"=>"Old French vineter"}, {"name"=>"m", "args"=>{"1"=>"fro", "2"=>"vinetier", "3"=>"", "4"=>"wine-merchant, grape-harvester"}, "expansion"=>"vinetier (“wine-merchant, grape-harvester”)"}, {"name"=>"der", "args"=>{"1"=>"en", "2"=>"ML.", "3"=>"vīnētārius", "4"=>"", "5"=>"wine dealer"}, "expansion"=>"Medieval Latin vīnētārius (“wine dealer”)"}, {"name"=>"m", "args"=>{"1"=>"la", "2"=>"vīnētum", "3"=>"", "4"=>"vineyard"}, "expansion"=>"vīnētum (“vineyard”)"}, {"name"=>"m", "args"=>{"1"=>"la", "2"=>"vīnum", "3"=>"", "4"=>"wine"}, "expansion"=>"vīnum (“wine”)"}],
     "sounds"=>[{"ipa"=>"/ˈvɪntnɚ/", "tags"=>["General-American"]}, {"ipa"=>"/ˈvɪntnə/", "tags"=>["Received-Pronunciation"]}],
     "word"=>"vintner",
     "lang"=>"English",
     "lang_code"=>"en",
     "senses"=>[
       {"raw_glosses"=>["A seller of wine."],
        "glosses"=>["A seller of wine."],
        "id"=>"vintner-en-noun-PH76qgCa",
        "translations"=>[
          {"lang"=>"Bulgarian", "code"=>"bg", "sense"=>"seller of wine", "roman"=>"tǎrgovec na vino", "word"=>"търговец на вино", "_dis1"=>"87 13"},
          {"lang"=>"Finnish", "code"=>"fi", "sense"=>"seller of wine", "word"=>"viininmyyjä", "_dis1"=>"87 13"},
          {"lang"=>"Finnish", "code"=>"fi", "sense"=>"seller of wine", "word"=>"viinikauppias", "_dis1"=>"87 13"},
          {"lang"=>"French", "code"=>"fr", "sense"=>"seller of wine", "tags"=>["masculine"], "word"=>"négociant en vins", "_dis1"=>"87 13"},
          {"lang"=>"Galician", "code"=>"gl", "sense"=>"seller of wine", "word"=>"arrieiro", "_dis1"=>"87 13"},
          {"lang"=>"German", "code"=>"de", "sense"=>"seller of wine", "tags"=>["masculine"], "word"=>"Weinhändler", "_dis1"=>"87 13"},
          {"lang"=>"German", "code"=>"de", "sense"=>"seller of wine", "tags"=>["feminine"], "word"=>"Weinhändlerin", "_dis1"=>"87 13"},
          {"lang"=>"Middle English", "code"=>"enm", "sense"=>"seller of wine", "word"=>"vyntener", "_dis1"=>"87 13"},
          {"lang"=>"Middle English", "code"=>"enm", "sense"=>"seller of wine", "word"=>"viniter", "_dis1"=>"87 13"},
          {"lang"=>"Russian", "code"=>"ru", "sense"=>"seller of wine", "roman"=>"vinotorgóvec", "tags"=>["masculine"], "word"=>"виноторго́вец", "_dis1"=>"87 13"}
        ],
        "categories"=>[
          {"name"=>"Grapevines",
           "kind"=>"lifeform",
           "parents"=>["Grape family plants", "List of sets", "Wine", "Plants", "All sets", "Alcoholic beverages", "Lifeforms", "Fundamental", "Beverages", "Drinking", "Recreational drugs", "Nature", "Food and drink", "Liquids", "Human behaviour", "Drugs", "All topics", "Matter", "Human", "Pharmacology", "Chemistry", "Biochemistry", "Medicine", "Sciences", "Biology"],
           "source"=>"w+disamb", "orig"=>"en:Grapevines", "langcode"=>"en", "_dis"=>"51 49"},
          {"name"=>"Occupations", "kind"=>"topical", "parents"=>["List of sets", "People", "All sets", "Human", "Fundamental", "All topics"], "source"=>"w+disamb", "orig"=>"en:Occupations", "langcode"=>"en", "_dis"=>"76 24"},
          {"name"=>"People", "kind"=>"topical", "parents"=>["Human", "All topics", "Fundamental"], "source"=>"w+disamb", "orig"=>"en:People", "langcode"=>"en", "_dis"=>"73 27"}
        ]
       },
       {"raw_glosses"=>["A manufacturer of wine."],
        "glosses"=>["A manufacturer of wine."],
        "id"=>"vintner-en-noun-AYe0cDYP",
        "translations"=>[
          {"lang"=>"Bulgarian", "code"=>"bg", "sense"=>"manufacturer of wine", "roman"=>"proizvoditel na vino", "word"=>"производител на вино", "_dis1"=>"13 87"},
          {"lang"=>"Dutch", "code"=>"nl", "sense"=>"manufacturer of wine", "tags"=>["masculine"], "word"=>"wijnboer", "_dis1"=>"13 87"},
          {"lang"=>"Dutch", "code"=>"nl", "sense"=>"manufacturer of wine", "tags"=>["masculine"], "word"=>"wijndruiventeler", "_dis1"=>"13 87"},
          {"lang"=>"Dutch", "code"=>"nl", "sense"=>"manufacturer of wine", "tags"=>["masculine"], "word"=>"wijngaardenier", "_dis1"=>"13 87"},
          {"lang"=>"Finnish", "code"=>"fi", "sense"=>"manufacturer of wine", "word"=>"viinintuottaja", "_dis1"=>"13 87"},
          {"lang"=>"Finnish", "code"=>"fi", "sense"=>"manufacturer of wine", "word"=>"viinintekijä", "_dis1"=>"13 87"},
          {"lang"=>"French", "code"=>"fr", "sense"=>"manufacturer of wine", "tags"=>["masculine"], "word"=>"vinificateur", "_dis1"=>"13 87"},
          {"lang"=>"Galician", "code"=>"gl", "sense"=>"manufacturer of wine", "word"=>"adegueiro", "_dis1"=>"13 87"},
          {"lang"=>"Galician", "code"=>"gl", "sense"=>"manufacturer of wine", "word"=>"viticultor", "_dis1"=>"13 87"},
          {"lang"=>"German", "code"=>"de", "sense"=>"manufacturer of wine", "tags"=>["masculine"], "word"=>"Winzer", "_dis1"=>"13 87"},
          {"lang"=>"German", "code"=>"de", "sense"=>"manufacturer of wine", "tags"=>["feminine"], "word"=>"Winzerin", "_dis1"=>"13 87"},
          {"lang"=>"Greek", "code"=>"grc", "tags"=>["Ancient", "masculine"], "sense"=>"manufacturer of wine", "roman"=>"oinopoiós", "word"=>"οἰνοποιός", "_dis1"=>"13 87"},
          {"lang"=>"Italian", "code"=>"it", "sense"=>"manufacturer of wine", "tags"=>["masculine"], "word"=>"vinificatore", "_dis1"=>"13 87"},
          {"lang"=>"Romanian", "code"=>"ro", "sense"=>"manufacturer of wine", "tags"=>["masculine"], "word"=>"viticultor", "_dis1"=>"13 87"},
          {"lang"=>"Russian", "code"=>"ru", "sense"=>"manufacturer of wine", "roman"=>"vinodél", "tags"=>["masculine"], "word"=>"виноде́л", "_dis1"=>"13 87"},
          {"lang"=>"Spanish", "code"=>"es", "sense"=>"manufacturer of wine", "tags"=>["masculine"], "word"=>"vinatero", "_dis1"=>"13 87"}
        ],
        "synonyms"=>[{"sense"=>"manufacturer of wine", "word"=>"winemaker", "_dis1"=>"13 87"}],
        "categories"=>[
          {"name"=>"Grapevines", "kind"=>"lifeform",
           "parents"=>["Grape family plants", "List of sets", "Wine", "Plants", "All sets", "Alcoholic beverages", "Lifeforms", "Fundamental", "Beverages", "Drinking", "Recreational drugs", "Nature", "Food and drink", "Liquids", "Human behaviour", "Drugs", "All topics", "Matter", "Human", "Pharmacology", "Chemistry", "Biochemistry", "Medicine", "Sciences", "Biology"],
           "source"=>"w+disamb",
           "orig"=>"en:Grapevines",
           "langcode"=>"en",
           "_dis"=>"51 49"}
        ]
       }
     ]
    }
  end

  def self.sample_verb
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



end