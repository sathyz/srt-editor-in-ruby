#!/usr/bin/ruby
# author : sathyz@gmail.com
#

class String
	# two strings of time instances can be added
	# TODO : subtracted

        def to_tlist( )
		# convert string to a list - "12:23:34,567" => ["12","23","34","567"]
                time_list = self.split(":")
                sec, msec = time_list.pop().split(",") 
		time_list.push(sec)

                time_list.unshift("%.2d"%0) while time_list.size<3

                time_list.each_with_index {|x,i| 
			time_list[i] = "%.2d" % x.to_i if x.size<2
		}
                
                time_list.push("%.3d" % msec.to_i)
		p time_list if $DEBUG
		time_list
        end

        def add(other)
		# >> "12:23:59,545".add("5,455") 
		# => "12:24:05,000"
		(p other; p self) if $DEBUG 
		other_list = other.to_tlist
		self_list = self.to_tlist
		result_list = Array.new(4,0)
		(0..3).each do |i| 
			i = 3 - i
			
			result_list[i] = ( result_list[i].to_i + self_list[i].to_i + other_list[i].to_i )
			
			quo = i==3? 1000:60
			#result_list[i-1] = (result_list[i].to_i/quo).to_s if (result_list[i].to_i/quo > 0)
			if (result_list[i].to_i/quo > 0)
				result_list[i-1] = result_list[i]/quo
				result_list[i] = result_list[i]%quo
			end
			
			result_list[i] = "%.#{i==3? 3:2}d"%result_list[i]
			p result_list,i,quo if $DEBUG
		end
		"%s:%s:%s,%s"%result_list
        end

        def subt( other )
                other_list = other.to_tlist
                self_list = self.to_tlist
                result_list = Array.new(4,0)
                (0..3).each do |i|
                        i = 3 - i
                        quo = i==3? 1000: 60

                        if self_list[i].to_i < other_list[i].to_i
                                self_list[i] = (self_list[i].to_i + quo ).to_s
                                self_list[i-1] = (self_list[i-1].to_i - 1).to_s
                        end
                        result_list[i] = ( self_list[i].to_i - other_list[i].to_i ) 
                end
                p result_list if $DEBUG
                "%.2d:%.2d:%.2d,%.3d"%result_list
        end

end

def srt_delay(srt_file, delay)
	puts "Using Subtitle File: #{srt_file}, delay : #{delay}\n"

	if !FileTest::exists?(srt_file)
		print "#{srt_file} doesn't exist.. \n"
		return
	end

	srt_out_file = "delayed.srt"
	srt_out = File.new(srt_out_file,"w")
	puts "Open output file #{srt_out_file}" if $DEBUG
	srt_in = File.new(srt_file,"r")
	puts "Open input file #{srt_file}" if $DEBUG
	seq = "1"
	line = ""

	dir = "+" #delay.match("^[+-]")
	delay.delete(dir)

	while (line = srt_in.gets) do
		#line = srt_in.readline() while line.chop!()!=seq
		srt_out.puts( line )
		p line if $DEBUG
		if  line.chop()==seq
			srt_out.puts( delay( srt_in.gets(), delay))
			seq = "%d"%(seq.to_i + 1)
		end
	end
	
	srt_in.close
	srt_out.close
end

def delay(line, delay)
	p "delaying line: #{line}, #{delay}" if $DEBUG
	original_instances = line.split("-->").each{|instance| instance.chop!}

	dir = ( dir = delay.match("^[+-]") ) ? dir[0] : "+" 
	delay = delay.delete(dir)
	p dir if $DEBUG

	if dir == "-"
	       delayed_line =  "%s --> %s\r\n" % original_instances.collect { |x| x.subt(delay) }
	else
	       delayed_line = "%s --> %s\r\n" % original_instances.collect { |x| x.add(delay) }
	end
	p delayed_line if $DEBUG
	delayed_line
end

if __FILE__ == $0
	if ARGV.size != 2
		print "Usage #{$0} SRT_FILE DELAY\n DELAY specified as 59 => 59 secs, 23:59 => 23 mins 59 secs\n"
		exit
	end
	srt_delay(ARGV[0],ARGV[1])
end
