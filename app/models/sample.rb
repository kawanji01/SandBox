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


  def hash_example
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

  def json_2
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