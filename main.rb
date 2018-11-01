require 'net/http'
require 'uri'
require 'rexml/document'
require 'date'

if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

CLOUDINESS = {-1 => 'туман', 0 => 'ясно', 1 => 'малооблачно', 2 => 'облачно', 3 => 'пасмурно'}
TOD = {0 => 'ночь', 1 => 'утро', 2 => 'день', 3 => 'вечер'}

uri = URI.parse('https://xml.meteoservice.ru/export/gismeteo/point/312.xml')

response = Net::HTTP.get_response(uri)

doc = REXML::Document.new(response.body)


def return_data_from_xml(forecast)
  raw_date = "#{forecast.attributes['day']}.#{forecast.attributes['month']}.#{forecast.attributes['year']}"
  parsed_date = Date.parse(raw_date).strftime('%d.%m.%Y')

  parsed_date == Date.today ? parsed_date = 'Сегодня' : parsed_date

  min_temp = forecast.elements['TEMPERATURE'].attributes['min'].to_i
  max_temp = forecast.elements['TEMPERATURE'].attributes['max'].to_i

  min_temp = "+#{min_temp}" if min_temp > 0
  max_temp = "+#{max_temp}" if max_temp > 0

  max_wind = forecast.elements['WIND'].attributes['max']

  cloudiness_index = forecast.elements['PHENOMENA'].attributes['cloudiness'].to_i
  clouds = CLOUDINESS[cloudiness_index]

  time_of_day_index = forecast.attributes['tod'].to_i
  time_of_day = TOD[time_of_day_index]

  # Возвращает многострочный текст
  <<~EOM
    #{parsed_date}, #{time_of_day}
    #{min_temp}..#{max_temp}, ветeр #{max_wind} м/с, #{clouds}
  EOM
end

# Вытаскивает название города и преобразует его из "%D0%A0%D0" в читаемый вид
city_name = URI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])
puts city_name

node = doc.root.elements['REPORT/TOWN'].elements.to_a

node.each do |forecast|
  puts

  puts return_data_from_xml(forecast)
end