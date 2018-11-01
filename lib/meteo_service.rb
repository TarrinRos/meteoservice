require 'net/http'
require 'uri'
require 'rexml/document'
require 'date'

class MeteoService
  CLOUDINESS = {-1 => 'туман', 0 => 'ясно', 1 => 'малооблачно', 2 => 'облачно', 3 => 'пасмурно'}
  TOD = {0 => 'ночь', 1 => 'утро', 2 => 'день', 3 => 'вечер'}

  def self.get_data_from_xml(response)
    doc = REXML::Document.new(response.body)
    new(doc)
  end

  def initialize(doc)

  end

  def to_s
    # Возвращает многострочный текст
    <<~EOM
    #{parsed_date}, #{time_of_day}
    #{min_temp}..#{max_temp}, ветeр #{max_wind} м/с, #{clouds}
    EOM
  end
end