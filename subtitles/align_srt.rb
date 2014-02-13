#!/usr/bin/ruby -w

#require 'net/http'
#require 'uri'
require 'fileutils'
require 'date'

def get_dic(src_array)
  src_dic = Array.new
#  index = 0
  src_array.each do |triple|
    triple.strip
    p_triple = triple.split(/\n/)
    time = p_triple[1]
    text = p_triple[2..-1].join("\n")
    src_dic.push([time, text])
#    index += 1
  end
  return src_dic
end

begin
  fileSRC = File.open(ARGV[0], "r")
  fileTRG = File.open(ARGV[1], "r")
rescue
  p "ruby parseSRTSubtitles.rb subtitles1 subtitles2"
  exit 1
end  

src = (fileSRC.read).gsub!(/\r\n?/, "\n")
trg = (fileTRG.read).gsub!(/\r\n?/, "\n")

src_array = src.split(/\n\n/)
trg_array = trg.split(/\n\n/)

src_dic = get_dic(src_array)

trg_dic = get_dic(trg_array)



index_src = 0
index_trg = 0

aligned =  Array.new
index = 0
src_w = ""
trg_w = ""
test_write = false
test = 0
while true do
  src_time = (src_dic[index_src][0]).split(" --> ")
  trg_time = (trg_dic[index_trg][0]).split(" --> ")

  src_time_b = src_time[0]
  src_time_e = src_time[1]

  trg_time_b = trg_time[0]
  trg_time_e = trg_time[1]

  sb = DateTime.strptime(src_time_b, '%H:%M:%S,%L')
  se = DateTime.strptime(src_time_e, '%H:%M:%S,%L')
  tb = DateTime.strptime(trg_time_b, '%H:%M:%S,%L')
  te = DateTime.strptime(trg_time_e, '%H:%M:%S,%L')

  limit = DateTime.strptime( '5', '%S')


  if sb < tb
    if test > 0
      test_write = true
    else
      src_w += src_dic[index_src][1] + "\n"
      trg_w = trg_dic[index_trg][1] + "\n"
      index_src += 1
      test -= 1
      if src_dic[index_src] == nil
        break
      else
        next
      end
    end
  else
    if test < 0
      test_write = true
    else
      trg_w += trg_dic[index_trg][1] + "\n"
      src_w = src_dic[index_src][1] + "\n"
      index_trg += 1
      test += 1
      if trg_dic[index_trg] == nil
        break
      else
        next
      end
    end
  end

  if test_write
    aligned.push([src_w, trg_w])
    src_w = ""
    trg_w = ""
    test = 0
    index += 1
    test_write = false
  end


  index_src += 1
  index_trg += 1
  if src_dic[index_src] == nil || trg_dic[index_trg] == nil
    break
  end
end

aligned.each do|value| 
  p "------------------------"
  puts value[0], value[1] 
end



##p src[0..10000]
##p src_array
#exit 2
#
#
#path = "./aligned/source/"
#FileUtils.mkdir_p(path) unless File.exists?(path)
#path = "./aligned/target/"
#FileUtils.mkdir_p(path) unless File.exists?(path)
#
#
#fileSRC = File.open("./aligned/source/sourceLyrics.txt", "w")
#fileTRG = File.open("./aligned/target/targetLyrics.txt", "w")
#
#content = fileIN.read
#content.gsub!(/\r\n?/, "\n")
##content.encode(content.encoding, :universal_newline => true)
#
#spid = 0
#ssid = 0
#tpid = 0
#tsid = 0
#
## go throuw every lyric
#content.scan(/(<lyric id=".+?" position="start">.+?<lyric id=".+?" position="end">)/m) do |pair|
#  id = (/(<lyric id=".+?" position="start">)/.match(pair[0]))[0]
#  idend = (/(<lyric id=".+?" position="end">)/.match(pair[0]))[0]
#  time = (/(<lyric downloadTime=".+?">)/.match(pair[0]))[0]
#  letter = (/(<lyric letterLink=".+?">)/.match(pair[0]))[0]
#  interpret = (/(<lyric interpretLink=".+?">)/.match(pair[0]))[0]
#  song = (/(<lyric songLink=".+?">)/.match(pair[0]))[0]
#
## find aligned texts
#  src = pair[0].scan(/<p class="text">(.+?)<\/p>/m)[0][0]
#  trg = pair[0].scan(/<p class="text">(.+?)<\/p>/m)[1][0]
#
## repair wrong aligned texts
#  src_array = src.split(/<br \/>\n/)
#  trg_array = trg.split(/<br \/>\n/)
#
## to write last lines of texts
#  src_array.push("")
#  trg_array.push("")
#
#  src_wr_array = Array.new
#  trg_wr_array = Array.new
#
#  tmp_src = Array.new
#  tmp_trg = Array.new
#
#  differ = 0
#
#  i = 0
#  j = 0
#  row_diff = false
#  while src_array[i] != nil && trg_array[j] != nil do
#
#    if spid % 10000 == 0
#      p src_array[i], trg_array[j]
#    end
#
#    write = false
#    src_array[i].strip.gsub("<br />","")
#    trg_array[j].strip.gsub("<br />","")
#
#
#    if src_array[i] == "" && trg_array[j] == ""
#      write = true
#    elsif src_array[i] == ""
#      row_diff = true
#      tmp_trg.push(trg_array[j])
#      j += 1
#      differ += 1
#      next
#    elsif trg_array[j] == ""
#      row_diff = true
#      tmp_src.push(src_array[i])
#      i += 1
#      differ += 1
#      next
#    else
#      tmp_src.push(src_array[i] + "\n")
#      tmp_trg.push(trg_array[j] + "\n")
#    end
#
#    if write && not row_diff
#      src_wr_array.push(tmp_src)
#      trg_wr_array.push(tmp_trg)
#      tmp_src = Array.new
#      tmp_trg = Array.new
#      differ = 0
#    elsif write && row_diff
#      src_wr_array.push( [tmp_src.join(" ") + "\n"] )
#      trg_wr_array.push( [tmp_trg.join(" ") + "\n"] )
#      tmp_src = Array.new
#      tmp_trg = Array.new
#      row_diff = false
#      differ = 0
#    end
#
#    break if differ > 3 # break if the shift is more then set border
#
#    i += 1
#    j += 1
#  end
#
#  fileSRC.write(id + "\n")
#  fileSRC.write(time + "\n")
#  fileSRC.write(letter + "\n")
#  fileSRC.write(interpret + "\n")
#  fileSRC.write(song + "\n")
#
#  src_wr_array.each do |list|
#    spid += 1
#    fileSRC.write('<p id="' + spid.to_s + '">' + "\n")
#    list.each do |item|
#      ssid += 1
#      fileSRC.write('<s id="' + ssid.to_s + '">' + "\n" + item + "</s>" + "\n")
#    end
#    fileSRC.write('</p>' + "\n")
#  end
#  fileSRC.write(idend + "\n")
#
#  fileTRG.write(id + "\n")
#  fileTRG.write(time + "\n")
#  fileTRG.write(letter + "\n")
#  fileTRG.write(interpret + "\n")
#  fileTRG.write(song + "\n")
#
#  trg_wr_array.each do |list|
#    tpid += 1
#    fileTRG.write('<p id="' + tpid.to_s + '">' + "\n")
#    list.each do |item|
#      tsid += 1
#      fileTRG.write('<s id="' + tsid.to_s + '">' + "\n" + item + "</s>" + "\n")
#    end
#    fileTRG.write('</p>' + "\n")
#  end
#  fileTRG.write(idend + "\n")
#
#end


