class DMP_call

def get_sik
  exURL = URI.encode("http://parcelstream.com/admin/getsik.aspx?login=Adobe&account=ProspectSandbox")
  unparsed_page = HTTParty.get(exURL)
  parsed_page = Nokogiri.XML(unparsed_page.body)
  tokens = parsed_page.css("Response Success").attribute('message').value
end

def get_tokens
  a = get_sik.split('/')
end

def get_candy
  tokens = get_tokens
  exURL = URI.encode("http://#{tokens[1]}.parcelstream.com/#{tokens[2]}/InitSession.aspx?sik=#{tokens[2]}/#{tokens[3]}&output=xml")
  unparsed_page = HTTParty.get(exURL)
  parsed_page = Nokogiri.XML(unparsed_page.body)
  # Getting invalid session key
end
