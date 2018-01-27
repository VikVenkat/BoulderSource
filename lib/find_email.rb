class FindEmail
  require 'net/http'
  # require 'URI'
  require 'json'

  # don't lose this awesome tool
  # https://jhawthorn.github.io/curl-to-ruby/

  def post_request(first, last, domain)
    uri = URI.parse("https://findthat.email/api_json/find_email")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = JSON.dump({
      "api_key" => "ixn97fvw-5zSFbUQx",
      "secret_key" => "fIKYDhoS3JFw0k2R-VgDZzWpFou67A4nK",
      "first_name" => first,
      "last_name" => last,
      "company_domain" => domain
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end

  def get_email(first, last, domain)
    # @fail_count = 0
    begin
      x = post_request(first,last,domain)
      hash = JSON.parse(x.body)
      # binding.pry
      confidence_level = hash.dig('message', 'confidence').to_i
      email = hash.dig('message', 'email')
    rescue Net::ReadTimeout => e
      puts " // #{e.message} ==> Failed: #{first} @ #{domain}"
    rescue TypeError => e
      puts " // #{e.message} ==> Failed: #{first} @ #{domain}"
    end


    if email.blank?
      # puts "Failed to get #{first} @ #{domain}"
    else
      puts "Found #{email} at #{confidence_level}% CL"
    end

    return email

  end

end
