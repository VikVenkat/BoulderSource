class List < ApplicationRecord
  require 'scraped_list'
  require 'scraped_item'

  #after_create :set_builder_info
    def builder_list
      a = ScrapedList.new.get_basic_list(6315,1000) #Confirm if this finished, 2055 start
    end


    def set_builder_info
      a = builder_list
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
          #binding.pry
      end
      puts " "
      puts "Failed to save #{@fail_count} records"
      puts "==============================================="
      puts "Success! Builder info set for #{a.size} records"
      puts "==============================================="

      # self.update_attributes(:source => "Houzz + #{@list[:id].to_s}")
      # self.update_attributes(:length => @list.length.to_s)
      # self.update_attributes(:content => @list.to_s)
    end

end
