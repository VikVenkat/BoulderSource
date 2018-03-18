class DigiCall

def get_sik_candy
  exURL = URI.encode("http://parcelstream.com/admin/getsik.aspx?login=Adobe&account=ProspectSandbox")
  unparsed_page = HTTParty.get(exURL)
  parsed_page = Nokogiri.XML(unparsed_page.body)
  message = parsed_page.css("Response Success").attribute('message').value
  tokens = message.split('/')

  neURL = URI.encode("http://#{tokens[1]}.parcelstream.com/#{tokens[2]}/InitSession.aspx?sik=#{tokens[2]}/#{tokens[3]}&output=xml")
  unparsed_page = HTTParty.get(neURL)
  parsed_page = Nokogiri.XML(unparsed_page.body)
  # Getting invalid session key
end
