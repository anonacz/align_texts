#!/usr/bin/ruby -w

require 'net/http'
require 'uri'
require 'fileutils'
require 'open-uri'
require 'thread'

#http://mojetitulky.com/
#http://www.s4c.co.uk/
#http://www.moviesubtitles.org/
#http://www.podnapisi.net
#http://www.sub-titles.net
#http://www.opensubtitles.org

#http://www.subtitles4free.com
#product_download_url=http%3A%2F%2Fwww.getsubtitle.com%2Fsubtitles%2Fbsplayer%2F08-09-2010%2F416476.zip

# currently contain 8392 movies
# presumption: need around 500 GB
def fetch ( letter )
  time = Time.new
  url = 'http://www.subtitles4free.com/'
  file3 = File.open("./links/subtitles4freeWrongID#{letter}.txt", "a")
  page = 1
  id = 0
  while true do
    url1 = url + "movies-" + letter + "-" + page.to_s + ".htm"
    uri1 = URI.parse(URI.encode(url1))
    begin
      response1 = Net::HTTP.get_response uri1
    rescue
      file3.write("url1 " + url1 + "\n")
      sleep(rand(0..2))
      next
    end
    body1 = response1.body
    
#    p url1, URI.encode(url1)
  
    if /Results: 0 - 0 of 0/.match(body1)
      break
    else
      movie_links = body1.scan(/href="http:\/\/imdb\.com\/title\/(.+?)\/">.+?<a target="_self" href="(.+?)1\.htm" style="/m)
  
      imdb = Array.new
      links = Array.new
      movie_links.each do |pair|
        imdb.push( pair[0] )
        link = url + pair[1]
        links.push( link ) 
      end
  
      index = 0
      page2 = 1
      while true do
        
        url2 = links[index] + page2.to_s + ".htm"
        uri2 = URI.parse(URI.encode(url2))
        begin 
          response2 = Net::HTTP.get_response uri2
        rescue
          file3.write("url2 " + url2 + "\n")
          sleep(rand(0..2))
          next
        end
        body2 = response2.body
  
        if /0 a 0/.match(body2)
          index += 1
          page2 = 0
          if links[index] == nil
            break
          end
        else
          subtitles_links = body2.scan(/<table class="tbResults">.+?<b>(.+?)<\/b>.+?title="">(.+?)<\/td>.+?href=".+?">(.+?)<\/a>.+?<td width="80">(.+?)<\/td>.+?<a href="(.+?)" style="/m)
          subtitles_links.each do |tuple|
            title = tuple[0]
            subtitle = tuple[1]
            language = tuple[2]
            type = tuple[3]
            refer = tuple[4]
            
#------------------------------------only cs en
            if (language != "Czech" || type != "SRT") && (language != "English" || type != "SRT")
              next
            end 
  
            path = "./subtitles/" + imdb[index] + "/" + page2.to_s + "/"
            FileUtils.mkdir_p(path) unless File.exists?(path)
  
            url3 = url + refer
            uri3 = URI.parse(URI.encode(url3))
            begin
              response3 = Net::HTTP.get_response uri3
            rescue
              file3.write("url3 " + url3 + "\n")
              sleep(rand(0..2))
              next
            end
            body3 = response3.body
  
            download_link = URI.unescape( (/product_download_url=(.+?)&/.match(body3))[1] )
  
            fname = (URI.unescape( (/product_download_url=(.+?)&/.match(body3))[1] )).split("/")[-1]
  
            File.open(path + fname + "-" + id.to_s + "-" + fname, "wb") do |file|
              file.write open(download_link).read
            end
            
            file1 = File.open(path + fname + "-" + id.to_s + ".information.txt", "w")
            file1.write(title + "\n" )
            file1.write(subtitle + "\n" )
            file1.write(language + "\n" )
            file1.write(type + "\n" )
            file1.write(refer + "\n" )
            file1.write(time.strftime("%Y-%m-%d %H:%M:%S") + "\n" )
            file1.write(path + fname + "-" + id.to_s + "-" + fname + "\n" )
            file1.write(url3 + "\n" )
            file1.write(url2 + "\n" )
            file1.write(url1 + "\n" )
  
            file1.close unless file1 == nil
  
            id += 1
          end
        end
  
        page2 += 1 
      end
    end
    page += 1
  end
end

# get array of starting letters of all movies
url = 'http://www.subtitles4free.com/'
uri = URI.parse(URI.encode(url))
response = Net::HTTP.get_response uri
body = response.body
letters = body.scan(/<a target="_self" href="movies-(.)-1\.htm">.<\/a>/m)

## launching letter by letter
#letters.each do |letter|
##  p letter[0]
#  fetch(letter[0])
#end

# parallel launching (process all letter at the same time
threads = []
letters.each do |letter|
  threads << Thread.new do
    fetch(letter[0])
  end
end

threads.each {|t| t.join }
