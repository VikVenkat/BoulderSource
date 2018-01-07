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
    puts "Loaded records #{input}"
    return parsed_page
  end


  def get_basic_list(start_page, max_pages)
    page = parsed_page(0)
  	contact_url_list = Array.new

  	big_max = page.css('h1.main-title').children.first.text.gsub(",","").to_i
    if max_pages < big_max
      max = max_pages
    else
      max = big_max
    end
  	start = 0
  	input_record = start_page
  	while start <= max do

  		page = parsed_page(input_record)
  		contact = page.css('div.name-info')
  		contact.each do |c|
  			## Here put the URLs into an Array
				contact_data = {
					company: c.css('a.pro-title').text,
					url: c.css('a.pro-title').first.attributes['href'].value,
				}
				contact_url_list << contact_data
  		end
      puts "Scraped List for #{contact_url_list.size} peeps"
  		input_record += 15
      start += 1
  	end #while

    return contact_url_list

  end

end
