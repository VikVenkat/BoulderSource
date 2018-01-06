
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
    puts @url
  end

  def page_to_parse
    exURL = @url
     #exURL = "https://www.houzz.com/pro/morningstarbuilders/morning-star-builders-ltd"
    unparsed_page = HTTParty.get(exURL)
    page = Nokogiri::HTML(unparsed_page)
  end

  def company_notes
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

      if company_info.css("span[itemprop = 'title']").children[1].text.present?
        notes[a] = company_info.css("span[itemprop = 'title']").children[1].text
      else
        notes[:builder_type] = company_info.css("span[itemprop = 'title']").text
      end
#      notes_string << a.text.squish
#      notes_string << ", "
    end
    return notes
  end

  def contact_notes
    contact_info = page_to_parse.css('div.pro-contact-methods')
    notes_string = String.new
    notes = Hash.new

    if contact_info.css('span.pro-contact-text').css('a.click-to-call-link').first.attributes['phone'].value.to_s.present?
      notes[:phone] = contact_info.css('span.pro-contact-text').css('a.click-to-call-link').first.attributes['phone'].value.to_s
    else
      notes[:phone] = "Missing"
    end

    if contact_info.css('a.proWebsiteLink').first.nil?
      notes[:site] = "Missing"
    else
      @site = contact_info.css('a.proWebsiteLink').first.attributes['href'].value
      if @site.to_s.include?('www.')
        @site = @site.gsub('www.', '')
      end
      if @site.to_s.include?('https://')
        @site = @site.gsub('https://', '')
      elsif @site.to_s.include?('http://')
        @site = @site.gsub('http://', '')
      end
      if @site.to_s.include?('/')
        @site = @site.gsub('/','')
      end

      notes[:site] = @site
    end
    return notes
  end


  def get_builder_info

    	contact_array = Array.new

			contact_data = {
        company: @company,
        phone: contact_notes[:phone],
        site: contact_notes[:site],
        url: @url,
        builder_type: company_notes[:builder_type],
        contact_name: company_notes[:contact_name],
        location: company_notes[:location],
        typical: company_notes[:typical]
#       notes: company_notes,
#       email:

			}
  		contact_array << contact_data

      return contact_array

    end #def

    def create_builder
      a = Builder.new
      b = get_builder_info
      a[:company] ||= b.at(0)[:company].to_s
      a[:phone] ||= b.at(0)[:phone].to_s
      a[:site] ||= b.at(0)[:site].to_s
      a[:url] ||= b.at(0)[:url].to_s
      a[:builder_type] ||= b.at(0)[:builder_type]
      a[:contact_name] ||= b.at(0)[:contact_name]
      a[:location] ||= b.at(0)[:location]
      a[:typical] ||= b.at(0)[:typical]
      a.save
      return a

    end

#scrape()
end
