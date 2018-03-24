class List < ApplicationRecord
  require 'scraped_list'
  require 'scraped_item'

  #after_create :set_builder_info
    def builder_list(start_page = 0, no_pages = 0, state = nil)
      a = ScrapedList.new.get_basic_list(:start_page => start_page, :no_pages => no_pages, :state => state)
      # binding.pry

    end


    def set_builder_info(start_page, no_pages, state = nil)
      a, b = builder_list(start_page, no_pages, state) #start_page, no_pages, url
      @fail_count = 0
      a.each do |b|
        begin
          x = ScrapedItem.new(b).create_builder
        rescue HTTParty::UnsupportedURIScheme => e
          puts " // #{e.message} ==> Failed: #{b[:company].to_s[0,15]}..."
          @fail_count += 1
        rescue => e
          puts " // #{e.message} ==> Failed: #{b[:company].to_s[0,15]}..."
          @fail_count += 1
        end

      end
      puts " "
      puts "Failed to save #{@fail_count} records"
      puts "==============================================="
      puts "Success! Builder info set for #{a.size} records"
      puts "==============================================="

      self.update_attributes(:source => b)
      self.update_attributes(:length => a.size)
      self.update_attributes(:fail_count => @fail_count)
      ::Builder.dedupe
      # self.update_attributes(:content => @list.to_s)
    end

end
