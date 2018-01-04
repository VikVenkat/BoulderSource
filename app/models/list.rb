class List < ApplicationRecord
  require 'scraped_list'
  require 'scraped_item'

  after_create :set_builder_info
    def builder_list
      a = ScrapedList.new.get_basic_list
  #    puts "#{a.length} items in list"
  #    puts "#{a.find(1)}"
  #    puts a.basic_list
  #    puts "the list should be above"
    end

    def set_builder_info
      b = builder_list

      b.each do |b|
        x = ScrapedItem.new(b).update_builder
      end
#      binding.pry
    end

end
