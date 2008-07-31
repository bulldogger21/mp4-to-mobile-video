#!/usr/bin/env ruby

require "fileutils"
include FileUtils
count = 0

if ARGV.empty?
  puts "Usage: psp.sh video_name.m4v"
end

target = File.join("/home", ENV["LOGNAME"], "Movies", "PSP", "Video")

mkdir_p target

ARGV.each do |video_file|
  count +=1
  puts "Starting conversion..." + count.to_s + "/" + ARGV.size.to_s
  output = 10001
  while File.exists?(output_file = File.join(target, "MAQ#{output}.MP4"))
    output +=1
  end

  #If there's a number in the file name, let's use that in the output file name too.
  #This way Railscast 120 becomes MAQ10120.MP4 so you can recognize it on the PSP.
  if video_file.first.scan(/([0-9]+)/).first.to_s.size >= 3
    output = ("1" + video_file.first.scan(/([0-9]+)/).first.to_s.rjust(4, '0')).to_i
    output_file = File.join(target, "MAQ#{output}.MP4")
  end

  touch output_file
  thumbnail = output_file.sub('MP4', 'THM')
  video_conversion = system %Q{ffmpeg -y -i "#{video_file}" -f mp4 -title "#{video_file}" -vcodec libx264 -level 21 -s 480x272 -b 768k -bufsize 400k -maxrate 4000k -g 250 -coder 1 -acodec libfaac -ac 2 -ab 128k "#{output_file}"}
  thumbnail_conversion = system %Q{ffmpeg -y -i "#{video_file}" -f image2 -ss 5 -vframes 1 -s 160x120 -an "#{thumbnail}"}
  unless video_conversion && thumbnail_conversion
    puts "We had a problem with " + video_file
  end
end

