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
    @counter = 0
    # puts "- - - - - - - - - - - - - "
    print "Start: #{@company.to_s[0,15]}... @ #{@url}"
    @page = page_to_parse
    #exURL = "https://www.houzz.com/pro/morningstarbuilders/morning-star-builders-ltd"
  end

  def page_to_parse
    exURL = URI.encode(@url)
    unparsed_page = HTTParty.get(exURL)
    page = Nokogiri::HTML(unparsed_page)
    @counter += 1
    return page
  end

  def company_notes
    company_info = @page.css('div.profile-about-right').css('div.info-list-label').css('div.info-list-text')
    company_info_2 = @page.css('div.profile-about-right').css('profile-content-narrow')

    notes_string = String.new
    notes = Hash.new


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

      if a.text.include?('License Number:')
        notes[:license] = a.text.gsub('License Number: ','')
      end

      if company_info.css("span[itemprop = 'title']").children[1].text.present?
        notes[:builder_type] = company_info.css("span[itemprop = 'title']").children[1].text
      else
        notes[:builder_type] = company_info.css("span[itemprop = 'title']").text
      end

      company_info_2.css("div.info-list-label").each do |a|
        if a.css('i.hzi-Man-Outline').present?
          notes[:contact_name] ||= a.text.gsub('Contact: ','')
        end

        if a.css('i.hzi-Location').present?
          notes[:location] ||= a.text.gsub('Location: ','')
        end

        if a.css('i.hzi-Cost-Estimate').present?
          notes[:typical] ||= a.text.gsub('Typical Job Costs: ','')
        end

        if a.css('i.hzi-Ruler').present?
          notes[:builder_type] ||= a.text.gsub('Professionals','').squish
        end

        if a.css('i.hzi-License').present?
          notes[:license] ||= a.text.gsub('License Number:','')
        end
      end
#      notes_string << a.text.squish
#      notes_string << ", "
    end
    return notes
  end

  def contact_notes
    contact_info = @page.css('div.pro-contact-methods')
    notes_string = String.new
    notes = Hash.new

    if contact_info.css('span.pro-contact-text').css('a.click-to-call-link').first.nil?
      notes[:phone] = "Missing"
    else
      notes[:phone] = contact_info.css('span.pro-contact-text').css('a.click-to-call-link').first.attributes['phone'].value.to_s
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

  def address
    company_info = @page.css('div.profile-about-right').css('div.info-list-label').css('div.info-list-text')
    company_info_2 = @page.css('div.profile-about-right').css('profile-content-narrow')

    notes_string = String.new
    notes = Hash.new

    company_info.css('div.info-list-text').each do |a|
      if a.css("span[itemprop=streetAddress]").present?
        notes[:street] = a.css("span[itemprop=streetAddress]").text
      end
      if a.css("span[itemprop=addressLocality]").present?
        notes[:city] = a.css("span[itemprop=addressLocality]").text
      end
      if a.css("span[itemprop=addressRegion]").present?
        notes[:state] = a.css("span[itemprop=addressRegion]").text
      end
      if a.css("span[itemprop=postalCode]").present?
        notes[:zip] = a.css("span[itemprop=postalCode]").text
      end
    end

    company_info_2.css('div.info-list-text').each do |a|
      if a.css("span[itemprop=streetAddress]").present?
        notes[:street] ||= a.css("span[itemprop=streetAddress]").text
      end
      if a.css("span[itemprop=addressLocality]").present?
        notes[:city] ||= a.css("span[itemprop=addressLocality]").text
      end
      if a.css("span[itemprop=addressRegion]").present?
        notes[:state] ||= a.css("span[itemprop=addressRegion]").text
      end
      if a.css("span[itemprop=postalCode]").present?
        notes[:zip] ||= a.css("span[itemprop=postalCode]").text
      end
    end

    if notes.empty?
      puts company_info
      # binding.pry
    end

    return notes


  end

  def get_builder_info
  	contact_array = Array.new
    @contact_notes = contact_notes.dup
    @company_notes = company_notes.dup
    @address = address.dup
		contact_data = {
      company: @company,
      phone: @contact_notes[:phone],
      site: @contact_notes[:site],
      url: @url,
      builder_type: @company_notes[:builder_type],
      contact_name: @company_notes[:contact_name],
      location: @company_notes[:location],
      typical: @company_notes[:typical],
      license: @company_notes[:license],
      street: @address[:street],
      city: @address[:city],
      state: @address[:state],
      zip: @address[:zip]
#       notes: company_notes,
#       email:

		}
		contact_array << contact_data

    return contact_array
  end #def


  def split_names
    hash = NameSplitter.new.split(company_notes[:contact_name])
  end
  def get_email
    loc = get_builder_info
    if split_names[:first_name].blank? || contact_notes[:site].blank? || contact_notes[:site].include?("Missing") || split_names[:first_name].nil? || contact_notes[:site].include?("houzz")
      return
    else
      @first = split_names[:first_name].to_s
      @last = split_names[:last_name].to_s
      @site = contact_notes[:site]

      @email = FindEmail.new.test_email_variants(@first, @last, @site)
    end
  end

  def create_builder
    a = Builder.new
    b = get_builder_info.dup
    a[:company] ||= b.at(0)[:company].to_s
    a[:phone] ||= b.at(0)[:phone].to_s
    a[:site] ||= b.at(0)[:site].to_s
    a[:url] ||= b.at(0)[:url].to_s
    a[:builder_type] ||= b.at(0)[:builder_type]
    a[:contact_name] ||= b.at(0)[:contact_name]
    a[:location] ||= b.at(0)[:location]
    a[:typical] ||= b.at(0)[:typical]
    a[:license] ||= b.at(0)[:license]
    a[:street] ||= b.at(0)[:street]
    a[:city] ||= b.at(0)[:city]
    a[:state] ||= b.at(0)[:state]
    a[:zip] ||= b.at(0)[:zip]
    begin
      a[:first_name] ||= split_names[:first_name].to_s
      a[:last_name] ||= split_names[:last_name].to_s
    rescue => e
      puts " // Name missing for #{b.at(0)[:company].to_s}"
    end
    # a[:email] ||= get_email.to_s #slows the thing WAY down.
    a.save
    puts " ==> Save: #{a[:company].to_s[0,10]}..."
    return a
  end
end
