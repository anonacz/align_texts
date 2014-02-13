#!/usr/bin/ruby -w

require 'net/http'
require 'uri'
require 'fileutils'

path = "./lyrics/source/"
FileUtils.mkdir_p(path) unless File.exists?(path)
path = "./lyrics/target/"
FileUtils.mkdir_p(path) unless File.exists?(path)


fileIN = File.open("./lyrics/allLanguagePairs.txt", "r")
fileSRC = File.open("./lyrics/source/sourceLyrics.txt", "w")
fileTRG = File.open("./lyrics/target/targetLyrics.txt", "w")

content = fileIN.read
content.gsub!(/\r\n?/, "\n")

spid = 0
ssid = 0
tpid = 0
tsid = 0

# go throuw every lyric
content.scan(/(<lyric id=".+?" position="start">.+?<lyric id=".+?" position="end">)/m) do |pair|
  id = (/(<lyric id=".+?" position="start">)/.match(pair[0]))[0]
  idend = (/(<lyric id=".+?" position="end">)/.match(pair[0]))[0]
  time = (/(<lyric downloadTime=".+?">)/.match(pair[0]))[0]
  letter = (/(<lyric letterLink=".+?">)/.match(pair[0]))[0]
  interpret = (/(<lyric interpretLink=".+?">)/.match(pair[0]))[0]
  song = (/(<lyric songLink=".+?">)/.match(pair[0]))[0]

# find aligned texts
  src = pair[0].scan(/<p class="text">(.+?)<\/p>/m)[0][0]
  trg = pair[0].scan(/<p class="text">(.+?)<\/p>/m)[1][0]

# repair wrong aligned texts
  src_array = src.split(/<br \/>\n/)
  trg_array = trg.split(/<br \/>\n/)

# to write last lines of texts
  src_array.push("")
  trg_array.push("")

  src_wr_array = Array.new
  trg_wr_array = Array.new

  tmp_src = Array.new
  tmp_trg = Array.new

  differ = 0

  i = 0
  j = 0
  row_diff = false
  while src_array[i] != nil && trg_array[j] != nil do

    if spid % 10000 == 0
      p src_array[i], trg_array[j]
    end

    write = false
    src_array[i].strip.gsub("<br />","")
    trg_array[j].strip.gsub("<br />","")


    if src_array[i] == "" && trg_array[j] == ""
      write = true
    elsif src_array[i] == ""
      row_diff = true
      tmp_trg.push(trg_array[j])
      j += 1
      differ += 1
      next
    elsif trg_array[j] == ""
      row_diff = true
      tmp_src.push(src_array[i])
      i += 1
      differ += 1
      next
    else
      tmp_src.push(src_array[i] + "\n")
      tmp_trg.push(trg_array[j] + "\n")
    end

    if write && not row_diff
      src_wr_array.push(tmp_src)
      trg_wr_array.push(tmp_trg)
      tmp_src = Array.new
      tmp_trg = Array.new
      differ = 0
    elsif write && row_diff
      src_wr_array.push( [tmp_src.join(" ") + "\n"] )
      trg_wr_array.push( [tmp_trg.join(" ") + "\n"] )
      tmp_src = Array.new
      tmp_trg = Array.new
      row_diff = false
      differ = 0
    end

    break if differ > 3 # break if the shift is more then set border

    i += 1
    j += 1
  end

  fileSRC.write(id + "\n")
  fileSRC.write(time + "\n")
  fileSRC.write(letter + "\n")
  fileSRC.write(interpret + "\n")
  fileSRC.write(song + "\n")

  src_wr_array.each do |list|
    spid += 1
    fileSRC.write('<p id="' + spid.to_s + '">' + "\n")
    list.each do |item|
      ssid += 1
      fileSRC.write('<s id="' + ssid.to_s + '">' + "\n" + item + "</s>" + "\n")
    end
    fileSRC.write('</p>' + "\n")
  end
  fileSRC.write(idend + "\n")

  fileTRG.write(id + "\n")
  fileTRG.write(time + "\n")
  fileTRG.write(letter + "\n")
  fileTRG.write(interpret + "\n")
  fileTRG.write(song + "\n")

  trg_wr_array.each do |list|
    tpid += 1
    fileTRG.write('<p id="' + tpid.to_s + '">' + "\n")
    list.each do |item|
      tsid += 1
      fileTRG.write('<s id="' + tsid.to_s + '">' + "\n" + item + "</s>" + "\n")
    end
    fileTRG.write('</p>' + "\n")
  end
  fileTRG.write(idend + "\n")

end


