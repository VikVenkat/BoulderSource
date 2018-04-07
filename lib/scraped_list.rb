class ScrapedList
  require 'uri'
  require 'nokogiri'
  require 'httparty'
  require 'pry'
  require 'json'

#  def initialize(list)
#    @list = list
#  end
  def get_url(start_page, state = nil, url= nil)

    if state.nil? == false
      default_url = "https://www.houzz.com/professionals/home-builders/c/#{state}/p/"
    else
      default_url = "https://www.houzz.com/professionals/home-builders/p/"
    end

    url ||= default_url
    input = start_page
    exURL = URI.encode("#{url}#{input}")
    puts "#{exURL}"

    return exURL

  end

  def get_parsed_page(input, state = nil, url = nil)
    exURL = get_url(input, state, url)
    unparsed_page = HTTParty.get(exURL,{headers: {"User-Agent" => "Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_1_2 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7D11 Safari/528.16"}})
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

    page = get_parsed_page(options[:start_page], options[:state])#, options[:no_pages])
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

  		page = get_parsed_page(input_record, options[:state])#, options[:no_pages])
  		contact = page.css('div.name-info')

  		contact.each do |c|
        begin
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
        rescue => e
        end
  		end
      puts "Scraped List for #{contact_url_list.size} peeps"
  		input_record += @pagination_increment
      start += 1
  	end #while

    return contact_url_list, get_url(options[:start_page])


  end

end
