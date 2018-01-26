class FindEmail
  require 'net/http'
  require 'URI'
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
    # puts 'hello world'
    e = post_request(first,last,domain)
    hash = JSON.parse(e.body)
    confidence_level = hash.dig('message', 'confidence').to_i
    email = hash.dig('message', 'email')
    puts "Found #{email} at #{confidence_level}% CL"
    return email

  end

end
