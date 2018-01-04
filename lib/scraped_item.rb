
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

  def page_to_parse
    exURL = @url
     #exURL = "https://www.houzz.com/pro/morningstarbuilders/morning-star-builders-ltd"
    unparsed_page = HTTParty.get(exURL)
    page = Nokogiri::HTML(unparsed_page)
  end

  def builder_notes
    company_info = page_to_parse.css('div.profile-about-right').css('div.info-list-label').css('div.info-list-text')

    notes_string = String.new
    notes = Hash.new

    #Zayne notes
    # `my_hash = Hash.new`
    # `#start iterator`
    # `item = a.text`
    # `if item.include?('contact:')`
    # `my_hash[:contact] = item.gsub('contact:', '')`
    # `end`
    # `#end iterator`

    company_info.css('div.info-list-text').each do |a|
      if a.text.include?('Contact:')
        notes[:contact_name] = a.text.gsub('Contact: ','')
      end

      if a.text.include?('Location:')
        notes[:location] = a.text.gsub('Location: ','')
      end

      if a.text.include?('Typical Job Costs:')
        notes[:typical] = a.text.gsub('Typical Job Costs: ','')
      end


      notes_string << a.text.squish
      notes_string << ", "
    end
    return notes
  end

  def get_builder_info
    	page = page_to_parse

    	contact_array = Array.new

    	contact_info = page.css('div.pro-contact-methods')
    	company_info = page.css('div.profile-about-right').css('div.info-list-label').css('div.info-list-text')

			contact_data = {
        company: @company,
        phone: contact_info.css('span.pro-contact-text').css('a.click-to-call-link').first.attributes['phone'].value.to_s,
        site: contact_info.css('a.proWebsiteLink').first.attributes['href'].value,
        url: @url,
        type: company_info.css("span[itemprop = 'title']").children[1].text,
#       notes: builder_notes,
        contact_name: builder_notes[:contact_name],
#       email:
        location: builder_notes[:location],
        typical: builder_notes[:typical]

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
