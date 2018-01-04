class ScrapedList
  require 'uri'
  require 'nokogiri'
  require 'httparty'
  require 'pry'
  require 'json'



  def get_basic_list
  	usaUrl = "https://www.houzz.com/professionals/home-builders/c/United-States"
  	unparsed_page = HTTParty.get(usaUrl)
  	parsed_page = Nokogiri::HTML(unparsed_page)
  	contact_url_list = Array.new

  	big_max = parsed_page.css('h1.main-title').children.first.text.gsub(",","").to_i

  	max = 3
  	start = 0
  	input = 0
  	while start < max do
  		usaUrl = "https://www.houzz.com/professionals/home-builders/c/United-States/p/#{input}"
  		unparsed_page = HTTParty.get(usaUrl)
  		parsed_page = Nokogiri::HTML(unparsed_page)
  		page = parsed_page
  		contact = page.css('div.name-info')
  		contact.each do |c|
  			## Here put the URLs into an Array
  				contact_data = {
  					company: c.css('a.pro-title').text,
  					url: c.css('a.pro-title').first.attributes['href'].value,
  				}
  				contact_url_list << contact_data
  			# end
  		end
  		input += 15
      start += 1
  	end #while
    return contact_url_list
  end
end
