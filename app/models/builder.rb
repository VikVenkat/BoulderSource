class Builder < ActiveRecord::Base

  require 'scraped_list'
  require 'scraped_item'

  def self.dedupe
    @counter = 0
    ::Builder.all.each do |loc| #1
      ::Builder.where('url == ? AND id > ?', loc.url, loc.id).each do |comp| #2
          # Merge or fill blanks here
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

  def self.split_names
    @counter = 0
    ::Builder.all.each do |loc|
      if loc.first_name.blank?
        if loc.contact_name.blank?
          next
        else
          @name = loc.contact_name
          parts = @name.split

          # If any part is "and", then put together the two parts around it
          # For example, "Mr. and Mrs." or "Mickey and Minnie"
          parts.each_with_index do |part, i|
            if ["and", "&"].include?(part) and i > 0
              p3 = parts.delete_at(i+1)
              p2 = parts.at(i)
              p1 = parts.delete_at(i-1)
              parts[i-1] = [p1, p2, p3].join(" ")
            end
          end

          # Build a hash of the remaining parts
          hash = {
            :suffix => (s = parts.pop unless parts.last !~ /(\w+\.|[IVXLM]+|[A-Z]+)$/),
            :last_name  => (l = parts.pop),
            :prefix => (p = parts.shift unless parts[0] !~ /^\w+\./),
            :first_name => (f = parts.shift),
            :middle_name => (m = parts.join(" "))
          }

          #Reverse name if "," was used in Last, First notation.
          if hash[:first_name] =~ /,$/
            hash[:first_name] = hash[:last_name]
            hash[:last_name] = $` # everything before the match
          end

          hash[:first_name] ||= loc.first_name
          hash[:last_name] ||= loc.last_name

          loc.update_attributes(:first_name => hash[:first_name])
          loc.update_attributes(:last_name => hash[:last_name])
          @counter += 1
        end
      else
        next
      end
    end
    puts "============================"
    puts "Cleaned up #{@counter} names"

  end

  def self.fill_emails(limit = 50)
    # do this y = FindEmail.new.get_email(Builder.first[:first_name].to_s,Builder.first[:last_name].to_s, Builder.first[:site].to_s)
    @counter = 0
    @skip_count = 0


    ::Builder.all.each do |loc|
      if loc.email.nil? || loc.email.include?("[") || loc.email.include?("60")
        if loc.first_name.blank? || loc.site.blank? || loc.site.include?("Missing")
          @skip_count += 1
        else
          @first = loc.first_name.to_s
          @last = loc.last_name.to_s
          @site = loc.site.to_s

          @email = FindEmail.new.test_email_variants(@first, @last, @site)

          loc.update_attributes(:email => @email.to_s)
          @counter += 1
        end
      end
      puts "#{@counter} out of #{limit}, #{loc.company} has #{loc.email}"
      break if @counter >= limit
    end
    puts "Updated #{@counter} emails, skipped #{@skip_count}"

  end

end
