require 'uri'
require 'rexml/document'
require_relative 'meteo_data'

class MeteoService
  attr_reader :node, :city_name

  def self.get_data_from_xml(response)
    doc = REXML::Document.new(response.body)
    new(doc)
  end

  def initialize(doc)
    @node = to_a(doc)
    @city_name = get_city_name(doc)
  end

  def to_a(doc)
    doc.root.elements['REPORT/TOWN'].elements.to_a
  end

  def get_city_name(doc)
    # Вытаскивает название города и преобразует его из "%D0%A0%D0" в читаемый вид
    URI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])
  end
end