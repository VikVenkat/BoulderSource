class List < ApplicationRecord
  require 'scraped_list'
  require 'scraped_item'

  after_create :set_builder_info
    def builder_list
      a = ScrapedList.new.get_basic_list(0)
    end

    def updated_list #this does not work
      @list = builder_list

      self.update_attributes(:source => "Houzz + #{@list[:id].to_s}")
      self.update_attributes(:length => @list.length.to_s)
      self.update_attributes(:content => @list.to_s)

    end

    def set_builder_info
      a = builder_list

      a.each do |b|
        x = ScrapedItem.new(b).create_builder
      end

    end

end
