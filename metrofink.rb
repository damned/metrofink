require 'nokogiri'
require 'open-uri'

class Metrofink
  @@stations = {
    'gardens' => 'piccadilly-gardens-tram',
    'piccadilly' => 'piccadilly-tram',
    'piccadilly-gardens' => 'piccadilly-gardens-tram',
    'shudehill' => 'shudehill-tram',
    'st-peters' => 'st-peters-square-tram',
    'st-peters-square' => 'st-peters-square-tram',
    'victoria' => 'victoria-tram'
  }
  
  def stations
    @@stations.keys
  end
  
  def trams(station)
    station_id = @@stations[station]

    raise "Unknown station '#{station}': only know about: #{stations.join ', '}" if station_id.nil?

    doc = Nokogiri::HTML(open("https://beta.tfgm.com/public-transport/tram/stops/#{station_id}"))

    doc.css('#departure-items .tram').map {|f| TramFragment.new(f) }
  end
  
end


class TramFragment
  def initialize(nokogiri_element)
    @el = nokogiri_element
  end
  
  def double?
    carriages.downcase.include?('double')
  end

  def carriages
    field '.departure-carriages'
  end

  def destination
    field '.departure-destination'
  end

  def wait
    field '.departure-wait'
  end

  private

  def field(selector)
    @el.css(selector).text.strip
  end
end

metrofink = Metrofink.new

stopname = ARGV.to_a.first
puts "looking for tram times for: #{stopname}"

metrofink.trams(stopname).each{ |tram| 
  desc = tram.wait + ': ' + tram.destination
  desc += ' (dbl)' if tram.double?
  puts desc
}
