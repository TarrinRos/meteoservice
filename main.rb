require 'net/http'
require 'uri'
require_relative 'lib/meteo_collector'

if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

TOWNS = {'Москва': '37', 'Рига': '312', 'ГонКонг': '256', 'Женева': '374', 'Вашингтон': '384', 'Каир': '334'}

# Получает все названия городов, формирует из них массив, сортирует по алфавиту
towns_list = TOWNS.keys.to_a.sort

puts
puts 'В каком городе Вы хотели бы посмотреть прогноз погоды?'
puts

# выводт список на экран с индексом
towns_list.each_with_index do |town, index|
  puts "#{index + 1}. #{town}"
end

user_choice = STDIN.gets.to_i
user_choice -= 1
choiced_town = towns_list[user_choice]

# Формирует ссылку на XML файл исходя из выбранного города и отправляет запрос
uri = URI.parse("https://xml.meteoservice.ru/export/gismeteo/point/#{TOWNS[choiced_town]}.xml")

# Получает ответ от сервера по указаной ссылке
response = Net::HTTP.get_response(uri)

collector = MeteoCollector.get_data_from_xml(response)

puts collector.city_name

collector.node.each do |forecast|
  puts MeteoData.new(forecast)
end