class Builder < ActiveRecord::Base

  require 'scraped_list'
  require 'scraped_item'

  def self.dedupe
    @counter = 0
    ::Builder.all.each do |loc| #1
      ::Builder.where('url == ? AND id > ?', loc.url, loc.id).each do |comp| #2
          puts "Deleted Builder ID #{comp.id}"
          comp.destroy
          @counter += 1
      end #do 2
    end #do 1
    puts "============================"
    puts "Cleaned up #{@counter} duplicates"
  end

  def self.to_csv
    attributes = %w{id contact_name company phone location site}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |item|
        csv << attributes.map{ |attr| item.send(attr) }
      end
    end

  end


end
#Builder.dedupe
