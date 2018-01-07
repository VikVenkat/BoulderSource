class Builder < ActiveRecord::Base

  require 'scraped_list'
  require 'scraped_item'

#attr_accessible :company, :phone, :email, :location, :typical, :url, :type, :contact_name

  # def self.dedupe # Not quite working
  #   # returns only duplicates in the form of [[name1, year1, trim1], [name2, year2, trim2],...]
  #   duplicate_row_values = Builder.select('url, count(*)').group('url').having('count(*) > 1').pluck(:url)
  #   @count = duplicate_row_values.count
  #
  #   # load the duplicates and order however you wantm and then destroy all but one
  #   duplicate_row_values.each do |url|
  #     Builder.where(url: url).order(id: :desc)[1..-1].map(&:destroy)
  #   end
  #   puts "Builder Table Deduped #{@count}x"
  # end

  def self.dedupe
    @counter = 0
    ::Builder.all.each do |loc| #1
      ::Builder.where('url == ? AND id > ?', loc.url, loc.id).each do |comp| #2
          puts "Deleted Builder ID #{comp.id}"
          comp.destroy
          @counter += 1
      end #do 2
    end #do 1
    return @counter
  end


end
#Builder.dedupe
