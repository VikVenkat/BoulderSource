class NameSplitter

  def split (fullname)
    if fullname.blank?
      return
    else
      @name = fullname
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

      return hash

    end
  end
end
