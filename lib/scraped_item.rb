
class ScrapedItem
  require 'uri'
  require 'nokogiri'
  require 'httparty'
  require 'pry'
  require 'json'

  def initialize(list_item)
    @builder = list_item
    @url = @builder[:url]
    @company = @builder[:company]
  end

  def get_builder_info
      exURL = @url
  	   #exUrl = "https://www.houzz.com/pro/morningstarbuilders/morning-star-builders-ltd"
    	unparsed_page = HTTParty.get(exURL)
    	page = Nokogiri::HTML(unparsed_page)
    	contact_array = Array.new


    	contact_info = page.css('div.pro-contact-methods')
    	company_info = page.css('div.profile-about-right').css('div.info-list-label').css('div.info-list-text')

			contact_data = {
        company: @company,
        phone: contact_info.css('span.pro-contact-text').css('a.click-to-call-link').first.attributes['phone'].value.to_s,
#          email:
#          location:
#          typical:
        site: contact_info.css('a.proWebsiteLink').first.attributes['href'].value,
        url: @url,
        type: company_info.css("span[itemprop = 'title']").children[1].text
#          contact_name:

			}
  		contact_array << contact_data
      binding.pry
      return contact_array

    end #def

    def update_builder
      b = get_builder_info
      @builder[:company] ||= b[:company].to_s
      @builder[:phone] ||= b[:phone].to_s
      @builder[:site] ||= b[:site].to_s
      @builder[:url] ||= b[:url].to_s
      binding.pry
      return @builder
    end

#scrape()
end
