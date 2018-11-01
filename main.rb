require 'net/http'
require 'uri'
require_relative 'lib/meteo_service'

if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

uri = URI.parse('https://xml.meteoservice.ru/export/gismeteo/point/312.xml')

response = Net::HTTP.get_response(uri)

service = MeteoService.get_data_from_xml(response)

puts service.city_name

service.node.each do |forecast|
  puts MeteoData.new(forecast)
end