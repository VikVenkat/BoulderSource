class FindEmail
  require 'net/http'
  # require 'URI'
  require 'json'

  # don't lose this awesome tool
  # https://jhawthorn.github.io/curl-to-ruby/

  def permutate (first, last, middle = nil, company = nil)
    variants = Array.new
    @fn = first
    @fn_fi = first.to_s[0]
    @ln = last
    @ln_fi = last.to_s[0]

    variants[0] = "#{@fn}" #michelle@example.com
    variants[1] = "#{@fn_fi}#{@ln}" #mlagrande@example.com
    variants[2] = "#{@fn_fi}.#{@ln}" #b.smith@domain.com
    variants[3] = "#{@fn}.#{@ln_fi}" #bob.s@domain.com
    variants[4] = "#{@fn_fi}#{@ln_fi}" #bs@domain.com
    variants[5] = "#{@fn}.#{@ln}" #michelle.lagrande@example.com
    variants[6] = "#{@fn}#{@ln}" #michellelagrande@example.com
    variants[7] = "#{@ln}" #lagrande@example.com
    variants[8] = "#{@fn}_#{@ln}" #michelle_lagrande@example.com
    variants[9] = "#{@fn_fi}_#{@ln}" #m_lagrande@example.com
    variants[10] = "#{@fn}#{@ln_fi}" #michellel@example.com
    variants[11] = "#{@ln}.#{@fn}"
    variants[12] = "#{@ln}.#{@fn_fi}"
    variants[13] = "#{@ln}#{@fn}"
    variants[14] = "#{@fn_fi}#{@ln[0..6]}"
    variants[15] = "admin"
    variants[16] = "team"
    variants[17] = "support"
    variants[18] = "help"
    variants[19] = "info"

    return variants
  end

  def test_email_variants(first, last, domain)
    begin
    @local_parts = permutate(first, last).dup
      @local_parts.each do |lp|

        @email = "#{lp}@#{domain}"
        @success = EmailVerifier.check(@email)

        if @success == true
          puts "Found valid email #{@email}"
          return @email
        end
      # in the futute, note this captures only the first email, come back later and get them all
      end
    rescue EmailVerifier::FailureException => e
      puts " // #{e.message} Intentional timeout 1 min ==> Failed: #{@email}"
      sleep(60)
      return
    rescue EmailVerifier::OutOfMailServersException => e
      puts " // #{e.message} ==> Failed: #{@email}"
      return
    rescue EmailVerifier::NoMailServerException => e
      puts " // #{e.message} ==> Failed: #{@email}"
      return "No server at domain"
    rescue Net::SMTPServerBusy => e
      puts " // #{e.message} ==> Failed: #{@email}"
      return
    rescue Dnsruby::ResolvTimeout => e
      puts " // #{e.message} ==> Failed: #{@email}"
      return
    rescue Errno::ECONNRESET => e
      puts " // #{e.message} ==> Failed: #{@email}"
      return
    rescue Net::SMTPFatalError => e
      puts " // #{e.message} ==> Failed: #{@email}"
      return "spamfilter at domain"
    rescue EOFError => e
      puts " // #{e.message} ==> Failed: #{@email}"
      return
    end
  end


####################################
# the below for Findthat.email API #
####################################

  def get_findthat_email(first, last, domain)
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

end
