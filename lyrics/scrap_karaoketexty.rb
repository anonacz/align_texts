#!/usr/bin/ruby -w

time = Time.new

require 'net/http'
require 'uri'
require 'fileutils'


path = "./links/"
FileUtils.mkdir_p(path) unless File.exists?(path)
path = "./lyrics/"
FileUtils.mkdir_p(path) unless File.exists?(path)


fileCUR = File.open("./links/savedLinksOfSongs.txt", "w")
fileOUT = File.open("./lyrics/allLanguagePairs.txt", "w")
fileERR = File.open("./links/errorLyricsLinks.txt", "w")

# ID of parallel lyric
id = 0

uri = URI.parse("http://www.karaoketexty.cz")
response = Net::HTTP.get_response uri
body = response.body

# match part with links of alphabet
letters = (/<div id="letter_list">.+?<\/div>/.match(body))[0]

# go through links of alphabet
letters.scan(/href="(.+?)">/) do |letter|

# print letter in process  
  puts letter[0]
  letter_link = "http://www.karaoketexty.cz" + letter[0]

# slow queries frequency
#  sleep(rand(0..2))
  uri2 = URI.parse(letter_link)
  response2 = Net::HTTP.get_response uri2
  letter_html = response2.body
# match part with links of authors
  interprets = (/<table class="album">.+?<\/table>/m.match(letter_html))[0]
# go through links of authors
  interprets.scan(/href="(.+?)">/) do |interpret|
# slow queries frequency
#    sleep(rand(0..1))
    interpret_link = "http://www.karaoketexty.cz" + interpret[0]
    uri3 = URI.parse(interpret_link)
    response3 = Net::HTTP.get_response uri3
    interpret_html = response3.body
# go through links of albums of author
    interpret_html.scan(/<table class="album">(.+?)<\/table>/m) do |album|
# go through links of songs in album
      album[0].scan(/<td class="left">.+?href="(.+?)".*?class="center width_60">(.*?)<\/td>/m) do |song|
# skip non-parallel lyrics
        if song[1] != ''
# skip karaoke lyrics
          if song[0].match(/^\/texty-pisni\//)
            id += 1
            song_link = "http://www.karaoketexty.cz" + song[0]

            fileOUT.write('<lyric id="' + String(id) + '" position="start">' + "\n" )
            fileOUT.write('<lyric downloadTime="' + time.strftime("%Y-%m-%d %H:%M:%S") + '">' + "\n" )
            fileOUT.write('<lyric letterLink="' + letter_link + '">' + "\n")
            fileOUT.write('<lyric interpretLink="' + interpret_link + '">' + "\n")
            fileOUT.write('<lyric songLink="' + song_link + '">' + "\n")

            uri4 = URI.parse(song_link)
            response4 = Net::HTTP.get_response uri4
            body4 = response4.body
            test = 0
# go through parallel texts of song (there should be two texts, source language text and target language text)
            body4.scan(/(<p class="text">.+?<\/p>)/m) do |paralel_text|
              fileOUT.write(paralel_text[0] + "\n")
              test += 1
            end
# bad structure of parallel text, to check later
            if test != 2:
              fileERR.write(song_link + "\n")
            end

            fileOUT.write('<lyric id="' + String(id) + '" position="end">' + "\n"  )


            fileCUR.write(song_link + "\n") 

          end
        end
      end  
    end
  end
end

fileOUT.close unless fileOUT == nil            
fileCUR.close unless fileCUR == nil

