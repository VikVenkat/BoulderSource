class ScrapedList
  require 'uri'
  require 'nokogiri'
  require 'httparty'
  require 'pry'
  require 'json'

#  def initialize(list)
#    @list = list
#  end
  def get_url(start_page, url= nil)
    default_url = "https://www.houzz.com/professionals/home-builders/p/"
    # usaUrl = "https://www.houzz.com/professionals/home-builders/p/#{input}"
    url ||= default_url
    input = start_page
    exURL = URI.encode("#{url}#{input}")

  end

  def get_parsed_page(input, url = nil)
    exURL = get_url(input, url)
    # binding.pry
    unparsed_page = HTTParty.get(exURL)
    parsed_page = Nokogiri::HTML(unparsed_page)
    print "Loaded records page #{input} // "
    return parsed_page
  end

  def find_max_page(start_page, no_pages, big_max)
    @last_page = big_max/15
    if no_pages < @last_page
      max = no_pages
    else
      max = @last_page
    end
  end


  def get_basic_list(options = {})

    page = get_parsed_page(options[:start_page])#, options[:no_pages])
    @pagination_increment = 15
    @start_page = options[:start_page].to_i

  	contact_url_list = Array.new

  	big_max = page.css('h1.main-title').children.first.text.gsub(",","").to_i
    # binding.pry
  	start = 0 # should be start_page?
    max = find_max_page(@start_page, options[:no_pages].to_i, big_max)
    puts "running to #{max}"
  	input_record = @start_page

  	while start <= max do

  		page = get_parsed_page(input_record)#, options[:no_pages])
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

    return contact_url_list, get_url(options[:start_page])


  end

end
