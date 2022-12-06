class JsonUtility < ApplicationRecord
  require 'ox'
  require "json"
  require "csv"

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
    words.join(';')
  end

end