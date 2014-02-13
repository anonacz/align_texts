require 'net/http'
require 'uri'
require 'fileutils'
require 'open-uri'


#http://mojetitulky.com/
#http://www.s4c.co.uk/
#http://www.moviesubtitles.org/
#http://www.podnapisi.net
#http://www.sub-titles.net
#http://www.opensubtitles.org


#http://www.subtitles4free.com
#product_download_url=http%3A%2F%2Fwww.getsubtitle.com%2Fsubtitles%2Fbsplayer%2F08-09-2010%2F416476.zip

#require 'uri'
#p URI.unescape("http%3A%2F%2Fwww.getsubtitle.com%2Fsubtitles%2Fbsplayer%2F08-09-2010%2F416476.zip")

path = "./links/"
FileUtils.mkdir_p(path) unless File.exists?(path)
path = "./subtitles/"
FileUtils.mkdir_p(path) unless File.exists?(path)




#f = open('http://dl.opensubtitles.org/en/download/sub/4492521')
#cd = f.meta['content-disposition']
#filename = cd.match(/filename=(\"?)(.+)\1/)[2]
#
#File.open(filename, "wb") do |file|
#  file.write open('http://dl.opensubtitles.org/en/download/sub/4492521').read
#end



file = File.open("./links/subtitles.txt", "a")
file1 = File.open("./links/subtitlesWrongID.txt", "a")


url2 = 'http://dl.opensubtitles.org/en/download/sub/4492521'
url3 = 'http://www.opensubtitles.org/en/search/sublanguageid-all/idmovie-325'
#url4 = 'http://www.opensubtitles.org/en/search/idmovie-325' # asi nechci, hleda pouze pro dany jazyk

test = 0
movID = 237
while true
  break if test == 20

  if movID % 100 == 0
    sleep(rand(30..60))
  end

  url3 = 'http://www.opensubtitles.org/en/search/sublanguageid-all/idmovie-' + String(movID)
  uri = URI.parse(url3)
  response = Net::HTTP.get_response uri
  body = response.body

  p url3

  page = 0
  if body.include? "<b>No results</b>"
    test += 1
    file1.write(url3 + "\n")
  else
    if /<span style="float:right;">.+?<b>.+?<b>.+?<b>(.+?)<\/b>/.match(body)
      pages = ((/<span style="float:right;">.+?<b>.+?<b>.+?<b>(.+?)<\/b>/.match(body))[1]).to_i
    else
      file1.write(url3 + "\n")
      test += 1
      movID += 1
      next
    end    

    body.scan(/"servOC\((.+?),'.+?style="padding-left:7px;"><a title="(.+?)"/m) do |subId1|
      str_to_write = url3 + " " + String(movID) + " " + subId1[0] + " " + subId1[1] + "\n"
      file.write(str_to_write)
    end
    page += 40    

    while page < pages

    
      url4 = 'http://www.opensubtitles.org/en/search/sublanguageid-all/idmovie-' + String(movID) + '/offset-' + String(page)
      uri4 = URI.parse(url4)
      response4 = Net::HTTP.get_response uri4
      body4 = response4.body
    
#      p url3
    
      if body.include? "<b>No results</b>"
        break
      else
        body.scan(/"servOC\((.+?),'.+?style="padding-left:7px;"><a title="(.+?)"/m) do |subId|
#pridat jazyk titulku, pocet stahnuti, hodnoceni, velikost, typ souboru s titulky -- budu podle toho vybirat titulky, ktere chci stahnout
          str_to_write = url3 + " " + String(movID) + " " + subId[0] + " " + subId[1] + "\n"
          file.write(str_to_write)
        end
      end
      page += 40
    end
    test = 0
  end
  movID += 1
  break if test == 10
end


file.close unless file == nil

