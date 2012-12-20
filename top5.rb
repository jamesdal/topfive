$LOAD_PATH << "."
require 'CSV'
require 'descriptive_statistics'
require 'debugger'
#csvinput = File.new(trainfile)
#can use values_at to reference averages for standards, blanks, and experimental samples-- by using it as a string and using interpolation
def progress(message, num, time = '') #https://github.com/princelab/mspire-simulator/blob/master/lib/progress.rb
                                      # move cursor to beginning of line
  cr = "\r"

  # ANSI escape code to clear line from cursor to end of line
  # "\e" is an alternative to "\033"
  # cf. http://en.wikipedia.org/wiki/ANSI_escape_code
  clear = "\e[0K"

  # reset lines
  reset = cr + clear
  if time == ''
    print "#{reset} #{message}" + "#{num}%".rjust(60-message.length)
    $stdout.flush
  else
    str = "#{reset} #{message}" + "#{num}%".rjust(60-message.length)
    print str + "Took: #{"%.2f" % time} sec.".rjust(100-str.length)
    $stdout.flush
  end
end

Array.class_eval do
  def mean
    #puts "mean" + self.to_s
    self.map.reduce(:+)/self.size
  end

  def variance
    #puts "variance" + self.to_s
    (self.inject { |ssd, v| ssd + (v-self.mean)*(v-self.mean) })/(self.size-1)
  end

  def stdev
    Math.sqrt(self.variance)
  end
end
class Top5
  def initialize
  end

  def read(blanks=23..25, standards=198..200, samples=26..197, csvinput="input.csv", output="output.csv")
arrayinput = CSV.read(csvinput)
puts "read CSV"
    #arrayinput = []

    #CSV.parse("input.csv") do |row|
     # row[samples].map!.to_f
     # arrayinput << row
    #end
    header = arrayinput[0]
    arrayinput = arrayinput[1..-1]
    arrayinput.each do |line|
#puts "BEFORE" + line.to_s
#line = [line[0..22]].push(line[23..-1].each{|w| w = w.to_f }).flatten
#puts "AFTER" + line.to_s
#progresscount = 0
      line.map! do |v|
        begin
          Float(v)
        rescue
          v
        end
#progresscount += 1
#progress("completed floating point conversion for line ", (progresscount).to_i)

#puts line
#puts line.class
       # line[23..-1].each do |v|
        #  if v.is_a?(String)
            #puts "boo"
        #  else
            #puts "yay"
      #    end
      #  end


      end
    end
    puts "string to numeric conversion complete"
    progresscount = 0
    arrayinput.each do |v|
      v.push((v[samples].stdev)/(v[samples].mean)) #modified from http://stackoverflow.com/questions/7749568/how-can-i-do-standard-deviation-in-ruby
      progresscount += 1
progress("computed mean corrected standard deviation for line", (progresscount/(arrayinput.size)).to_f)
    end
    sorted = arrayinput.sort { |a, b| b[-1] <=> a[-1] } #modified from http://stackoverflow.com/questions/7033719/sorting-a-two-dimensional-array-by-second-value
#    puts header.to_s
 #   puts sorted[0..4].to_s
    CSV.open(output,"wb") do |csvline| #modified from http://stackoverflow.com/questions/4822422/output-array-to-csv-in-ruby
    csvline << header
    sorted[0..4].each{|v| csvline << v}
    end
    CSV.open("fulloutsorted.csv","wb") do |csvline| #modified from http://stackoverflow.com/questions/4822422/output-array-to-csv-in-ruby
    csvline << header
    sorted.each{|v| csvline << v}
    end
  end
end
a= Top5.new
a.read
