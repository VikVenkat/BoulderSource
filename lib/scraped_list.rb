class ScrapedList
  require 'uri'
  require 'nokogiri'
  require 'httparty'
  require 'pry'
  require 'json'

#  def initialize(list)
#    @list = list
#  end

  def parsed_page(input)
    usaUrl = "https://www.houzz.com/professionals/home-builders/p/#{input}"
    unparsed_page = HTTParty.get(usaUrl)
    parsed_page = Nokogiri::HTML(unparsed_page)
    print "Loaded records page #{input} // "
    return parsed_page
  end

  def find_max_page(start_page, max_pages, big_max)
    @last_page = big_max/15
    if max_pages < @last_page
      max = max_pages
    else
      max = @last_page
    end
  end

  def get_basic_list(start_page, max_pages)
    page = parsed_page(0)
    @pagination_increment = 15
  	contact_url_list = Array.new

  	big_max = page.css('h1.main-title').children.first.text.gsub(",","").to_i

  	start = 0 # should be start_page?
    max = find_max_page(start_page, max_pages, big_max)
    puts "running to #{max}"
  	input_record = start_page

  	while start <= max do

  		page = parsed_page(input_record)
  		contact = page.css('div.name-info')

  		contact.each do |c|
        @url = c.css('a.pro-title').first.attributes['href'].value
        if @url.include?('javascript')
          next
        else
  				contact_data = {
  					company: c.css('a.pro-title').text,
  					url: @url,
  				}
  				contact_url_list << contact_data
        end
  		end
      puts "Scraped List for #{contact_url_list.size} peeps"
  		input_record += @pagination_increment
      start += 1
  	end #while

    return contact_url_list

  end

end
