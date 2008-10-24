#!/usr/bin/env ruby

#Authors: Lou Scoras, Vince Wadhwani
#http://urbanpuddle.com/

require "fileutils"
require "optparse"
include FileUtils
count = 0

if ARGV.empty?
  puts "Usage: vid2go.rb video_name.m4v"
end

#defaults
@resolution = "480x352"
@player = "HTCg1"

# accept options.. we can add more resolutions later
OPTIONS = {
  :psp       => "480x252",
  :htcg1     => "480x352"}

ARGV.options do |o|
  script_name = File.basename($0)
  # if you add more devices, set it in options and also here
  o.on("-psp") {@resolution= OPTIONS[:psp]; @player = "PSP"}
  o.on("-htcg1") {@resolution= OPTIONS[:htcg1]; @player = "HTCg1"}
  
  o.separator ""
  o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }
  o.parse!
end

puts "Converting to " + @resolution + " for your " + @player

target = File.join(ENV["HOME"], "Movies", @player, "Video")
mkdir_p target

ARGV.each do |video_file|
  count +=1
  puts "Starting conversion..." + count.to_s + "/" + ARGV.size.to_s
  output = File.basename(video_file, '.m4v')
  output_file = File.join(target, "#{output}.MP4")

  unless File.exists?(output_file = File.join(target, "#{output}.MP4"))
    touch output_file
    thumbnail = output_file.sub('MP4', 'THM')
    
    if @player == "PSP"  #need a special output for the PSP
      video_conversion = system %Q{ffmpeg -y -i "#{video_file}" -f mp4 -title "#{video_file}" -vcodec libx264 -level 21 -s 480x272 -b 768k -bufsize 400k -maxrate 4000k -g 250 -coder 1 -acodec libfaac -ac 2 -ab 128k "#{output_file}"}

      thumbnail_conversion = system %Q{ffmpeg -y -i "#{video_file}" -f image2 -ss 5 -vframes 1 -s 160x120 -an "#{thumbnail}"}
      
    else  #otherwise default to this smaller format for phones
      video_conversion = system %Q{ffmpeg -y -i "#{video_file}" -v 1 -threads 1 -vcodec libx264 -b 500k -bt 175k -refs 1 -loop 1 -deblockalpha 0 -deblockbeta 0 -parti4x4 1 -partp8x8 1 -me full -subq 6 -me_range 21 -chroma 1 -slice 2 -bf 0 -level 30 -g 300 -keyint_min 30 -sc_threshold 40 -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.7 -qmax 51 -qdiff 4 -i_qfactor 0.71428572 -maxrate 768k -bufsize 2M -cmp 1 -s "#{@resolution}" -acodec libfaac -ab 192k -ar 48000 -ac 2 -f mp4 "#{output_file}"}
    end

    unless video_conversion
      puts "We had a problem with " + video_file
    end
  end
end

