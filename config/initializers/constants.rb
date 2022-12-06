# frozen_string_literal: true

#定数設定

INVITATION_OF_SLACK = "https://join.slack.com/t/booqsguild/shared_invite/enQtNzc2NjI3MTY3MDEyLTczMGZmMGMzMDQ0NTUxMWM3NmNlNWU4YzdhZDEwMTkwODVmOWVhYTI1Y2IyYjUzMWU1MzZjZDgwZTc3YTEyNDU"

INVITATION_OF_DISCORD = "https://discord.gg/N7zUGMJ"

QUESTIONNAIRE_URL = "https://forms.gle/fUcTxYizJ9Fg5aXK8"

BUCKET_URL = "https://diqt.s3.ap-northeast-1.amazonaws.com"
ASSETS_URL = "#{BUCKET_URL}/assets"
IMAGES_URL = "#{ASSETS_URL}/images"
INTRODUCTIONS_URL = "#{IMAGES_URL}/introductions"
MAIN_IMAGES_URL = "#{IMAGES_URL}/main"
DIQT_NO_IMAGE = "#{MAIN_IMAGES_URL}/diqt_no_image.png"
NOT_FOUND_ICON = "#{MAIN_IMAGES_URL}/not_found_icon.png"
DIQT_ICON = "#{MAIN_IMAGES_URL}/diqt_icon.png"
LOADING_GIF = "#{MAIN_IMAGES_URL}/loading.gif"

STRIPE_FEE = 0.036

MARKETING_INVESTMENT = 0

# 利用可能な辞書
APPLICABLE_DICT_IDS = [1,2,5, 6]
# 利用可能な言語
APPLICABLE_LANG_CODES = ['en', 'ja']

# デフォルトで利用するPLANのreference_number
MONTHLY_PREMIUM_PLAN_NUMBER = 1
ANNUAL_PREMIUM_PLAN_NUMBER = 5
SCHOOL_PLAN_NUMBER = 100

module Experience_points
  ## Constants::NUMでアクセスできる
  INITIAL_VALUE = 10
  MAGNIFICATION = 1.1
end


module Answer_settings
  DEFAULT_SETTING = { interval_step_up_condition: 1,
                      initial_interval: 0,
                      choices_covered: false,
                      daily_goal: 30,
                      weakness_condition: 2}.freeze
end

module Extension_settings
  DEFAULT_SETTING = {
    daily_translation_count: 0,
    popup_displayed: false
  }.freeze
end

module Mobile_settings
  DEFAULT_SETTING = {
    onetime_token: nil,
  }.freeze
end

module Medal_number
  # チュートリアルメダル
  DRILL_CLEAR = 25
  GOAL_ACHIEVEMENT = 26
  REVIEW_COMPLETION = 27
  CONTINUOUS_ANSWER = 28
  CONTINUOUS_GOAL_ACHIEVEMENT = 29
  CONTINUOUS_REVIEW_COMPLETION = 30
  FOLLOW = 31
  CHEERING = 32
  CONTINUATION_ALL_WEEK = 34
  # 解答数メダル
  ANSWERS_100 = 1
  ANSWERS_500 = 2
  ANSWERS_1000 = 3
  ANSWERS_2000 = 4
  ANSWERS_5000 = 5
  ANSWERS_10000 = 6
  ANSWERS_20000 = 7
  ANSWERS_30000 = 8
  ANSWERS_40000 = 9
  ANSWERS_50000 = 10
  ANSWERS_60000 = 11
  ANSWERS_70000 = 12
  ANSWERS_80000 = 13
  ANSWERS_90000 = 14
  ANSWERS_100000 = 15
  # 解答日数メダル
  ANSWER_DAYS_2 = 16
  ANSWER_DAYS_7 = 17
  ANSWER_DAYS_14 = 18
  ANSWER_DAYS_30 = 19
  ANSWER_DAYS_60 = 20
  ANSWER_DAYS_100 = 21
  ANSWER_DAYS_200 = 22
  ANSWER_DAYS_300 = 23
  ANSWER_DAYS_365 = 24
  # マスターメダル
  LV_100 = 40
  RANK_1 = 41
  ALL_YEAR = 42
  TUTORIAL = 43
  ALL_ANSWERS = 44
  ALL_ANSWER_DAYS = 45
end

module Review_setting
  TOMORROW = 0
  AFTER_3_DAYS = 1
  AFTER_1_WEEK = 2
  AFTER_2_WEEKS = 3
  AFTER_3_WEEKS = 4
  AFTER_1_MONTH = 5
  AFTER_2_MONTHS = 6
  AFTER_3_MONTHS = 7
  AFTER_6_MONTHS = 8
  AFTER_1_YEAR = 9
end

#NOTIFIED_USERS = ["229003",'916356']
NOTIFIED_USERS = ["aaa"]

USER_PARAMETERS = [:name, :email, :password, :password_confirmation, :profile, :icon, :remove_icon, :website, :facebook, :twitter, :notification_deliver,
                   :public_uid, :lang_number,
                   answer_setting_attributes: %i[id user_id interval_step_up_condition initial_interval default_review_off choices_covered se_enabled]]

# Cloud Translationに合わせる。https://cloud.google.com/translate/docs/languages?hl=ja
module Languages
  CODE_MAP = {
    'undefined' => 0,
    'af' => 1,
    'sq' => 2,
    'am' => 3,
    'ar' => 4,
    'hy' => 5,
    'az' => 6,
    'eu' => 7,
    'be' => 8,
    'bn' => 9,
    'bs' => 10,
    'bg' => 11,
    'ca' => 12,
    'ceb' => 13,
    'zh-CN' => 14,
    'zh-Hans' => 14,
    'zh' => 14,
    'zh-TW' => 15,
    'zh-Hant' => 15,
    'co' => 16,
    'hr' => 17,
    'cs' => 18,
    'da' => 19,
    'nl' => 20,
    'en' => 21,
    'eo' => 22,
    'et' => 23,
    'fi' => 24,
    'fr' => 25,
    'fy' => 26,
    'gl' => 27,
    'ka' => 28,
    'de' => 29,
    'el' => 30,
    'gu' => 31,
    'ht' => 32,
    'ha' => 33,
    'haw' => 34,
    'he' => 35,
    'iw' => 35,
    'hi' => 36,
    'hmn' => 37,
    'hu' => 38,
    'is' => 39,
    'ig' => 40,
    'id' => 41,
    'ga' => 42,
    'it' => 43,
    'ja' => 44,
    'jv' => 45,
    'kn' => 46,
    'kk' => 47,
    'km' => 48,
    'rw' => 49,
    'ko' => 50,
    'ku' => 51,
    'ky' => 52,
    'lo' => 53,
    'la' => 54,
    'lv' => 55,
    'lt' => 56,
    'lb' => 57,
    'mk' => 58,
    'mg' => 59,
    'ms' => 60,
    'ml' => 61,
    'mt' => 62,
    'mi' => 63,
    'mr' => 64,
    'mn' => 65,
    'my' => 66,
    'ne' => 67,
    'no' => 68,
    'ny' => 69,
    'or' => 70,
    'ps' => 71,
    'fa' => 72,
    'pl' => 73,
    'pt' => 74,
    'pa' => 75,
    'ro' => 76,
    'ru' => 77,
    'sm' => 78,
    'gd' => 79,
    'sr' => 80,
    'st' => 81,
    'sn' => 82,
    'sd' => 83,
    'si' => 84,
    'sk' => 85,
    'sl' => 86,
    'so' => 87,
    'es' => 88,
    'su' => 89,
    'sw' => 90,
    'sv' => 91,
    'tl' => 92,
    'fil' => 92,
    'tg' => 93,
    'ta' => 94,
    'tt' => 95,
    'te' => 96,
    'th' => 97,
    'tr' => 98,
    'tk' => 99,
    'uk' => 100,
    'ur' => 101,
    'ug' => 102,
    'uz' => 103,
    'vi' => 104,
    'cy' => 105,
    'xh' => 106,
    'yi' => 107,
    'yo' => 108,
    'zu' => 109
  }

  BCP47_MAP = {
    'af-ZA' => 'af',
    'sq-AL' => 'sq',
    'am-ET' => 'am',
    'ar-DZ' => 'ar',
    'ar-BH' => 'ar',
    'ar-EG' => 'ar',
    'ar-IQ' => 'ar',
    'ar-IL' => 'ar',
    'ar-JO' => 'ar',
    'ar-KW' => 'ar',
    'ar-LB' => 'ar',
    'ar-MA' => 'ar',
    'ar-OM' => 'ar',
    'ar-QA' => 'ar',
    'ar-SA' => 'ar',
    'ar-PS' => 'ar',
    'ar-TN' => 'ar',
    'ar-AE' => 'ar',
    'ar-YE' => 'ar',
    'hy-AM' => 'hy',
    'az-AZ' => 'az',
    'eu-ES' => 'eu',
    'bn-BD' => 'bn',
    'bn-IN' => 'bn',
    'bs-BA' => 'bs',
    'bg-BG' => 'bg',
    'my-MM' => 'my',
    'ca-ES' => 'ca',
    'yue-Hant-HK' => 'zh-TW',
    'cmn-Hans-CN' => 'zh-CN',
    'cmn-Hant-TW' => 'zh-TW',
    'hr-HR' => 'hr',
    'cs-CZ' => 'cs',
    'da-DK' => 'da',
    'nl-BE' => 'nl',
    'nl-NL' => 'nl',
    'en-US' => 'en',
    'en-AU' => 'en',
    'en-CA' => 'en',
    'en-GH' => 'en',
    'en-HK' => 'en',
    'en-IN' => 'en',
    'en-IE' => 'en',
    'en-KE' => 'en',
    'en-NZ' => 'en',
    'en-NG' => 'en',
    'en-PK' => 'en',
    'en-PH' => 'en',
    'en-SG' => 'en',
    'en-ZA' => 'en',
    'en-TZ' => 'en',
    'en-GB' => 'en',
    'et-EE' => 'et',
    'fil-PH' => 'tl',
    'fi-FI' => 'fi',
    'fr-BE' => 'fr',
    'fr-CA' => 'fr',
    'fr-FR' => 'fr',
    'fr-CH' => 'fr',
    'gl-ES' => 'gl',
    'ka-GE' => 'ka',
    'de-AT' => 'de',
    'de-DE' => 'de',
    'de-CH' => 'de',
    'el-GR' => 'el',
    'gu-IN' => 'gu',
    'iw-IL' => 'iw',
    'hi-IN' => 'hi',
    'hu-HU' => 'hu',
    'is-IS' => 'is',
    'id-ID' => 'id',
    'it-IT' => 'it',
    'it-CH' => 'it',
    'ja-JP' => 'ja',
    'jv-ID' => 'jv',
    'kn-IN' => 'kn',
    'kk-KZ' => 'kk',
    'km-KH' => 'km',
    'ko-KR' => 'ko',
    'lo-LA' => 'lo',
    'lv-LV' => 'lv',
    'lt-LT' => 'lt',
    'mk-MK' => 'mk',
    'ms-MY' => 'ms',
    'ml-IN' => 'ml',
    'mr-IN' => 'mr',
    'mn-MN' => 'mn',
    'ne-NP' => 'ne',
    'no-NO' => 'no',
    'fa-IR' => 'fa',
    'pl-PL' => 'pl',
    'pt-BR' => 'pt',
    'pt-PT' => 'pt',
    'pa-Guru-IN' => 'pa',
    'ro-RO' => 'ro',
    'ru-RU' => 'ru',
    'sr-RS' => 'sr',
    'si-LK' => 'si',
    'sk-SK' => 'sk',
    'sl-SI' => 'sl',
    'es-AR' => 'es',
    'es-BO' => 'es',
    'es-CL' => 'es',
    'es-CO' => 'es',
    'es-CR' => 'es',
    'es-DO' => 'es',
    'es-EC' => 'es',
    'es-SV' => 'es',
    'es-GT' => 'es',
    'es-HN' => 'es',
    'es-MX' => 'es',
    'es-NI' => 'es',
    'es-PA' => 'es',
    'es-PY' => 'es',
    'es-PE' => 'es',
    'es-PR' => 'es',
    'es-ES' => 'es',
    'es-US' => 'es',
    'es-UY' => 'es',
    'es-VE' => 'es',
    'su-ID' => 'su',
    'sw-KE' => 'sw',
    'sw-TZ' => 'sw',
    'sv-SE' => 'sv',
    'ta-IN' => 'ta',
    'ta-MY' => 'ta',
    'ta-SG' => 'ta',
    'ta-LK' => 'ta',
    'te-IN' => 'te',
    'th-TH' => 'th',
    'tr-TR' => 'tr',
    'uk-UA' => 'uk',
    'ur-IN' => 'ur',
    'ur-PK' => 'ur',
    'uz-UZ' => 'uz',
    'vi-VN' => 'vi',
    'zu-ZA' => 'zu',
  }
end