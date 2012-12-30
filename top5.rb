$LOAD_PATH << "."
require 'CSV'
require 'trollop'
#require 'descriptive_statistics'
require 'debugger'
#csvinput = File.new(trainfile)
#can use values_at to reference averages for standards, blanks, and experimental samples-- by using it as a string and using interpolation
#debugger
#to do: need to add fraction observed in experimental runs
#to do: need to add
$opts = Trollop::options do
  opt :blanks, "Blank columns", :default => "23..25"
  #opt :standards, "Standard columns", :default => "198..200" # standard columns are incompatible with nomis-- with NOMIS, you spike each sample with standard.
  opt :samples, "Sample columns", :default => "26..197" #sample should be spiked with standard, otherwise NOMIS won't work
  opt :infile, "CSV input file", :default => "input.csv"
  opt :outfile, "CSV input file", :default => "output.csv"
  opt :fa, "Fatty Acyls [FA]"
  opt :gl, "Glycerolipids [GL]"
  opt :gp, "Glycerophospholipids [GP]"
  opt :pk, "Polyketides [PK]"
  opt :pr, "Prenol Lipids [PR]"
  opt :sl, "Saccharolipids [SL]"
  opt :sp, "Sphingolipids [SP]"
  opt :st, "Sterol Lipids [ST]"
end

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
  @blanks = $opts[:blanks].split('..').inject { |beginning,ending| beginning.to_i..ending.to_i }#http://stackoverflow.com/questions/53472/best-way-to-convert-a-ruby-string-range-to-a-range-object
  @samples = $opts[:samples].split('..').inject { |beginning,ending| beginning.to_i..ending.to_i }#http://stackoverflow.com/questions/53472/best-way-to-convert-a-ruby-string-range-to-a-range-object
  @csvinput = $opts[:infile]
  @output = $opts[:outfile]
  end

  def read(blanks=23..25, standards=198..200, samples=26..197, csvinput="input.csv", output="output.csv")
    blanks = @blanks #these need to be removed, just better coding to reference class variables instead
    samples = @samples
    csvinput = @csvinput
    output = @output
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
      line.map! do |v| #this process ought to be moved so only filtered ones are done, this was designed for a program that had no filter
        begin
          Float(v)
        rescue
          v
        end
        
#progresscount += 1
#progress("completed floating point conversion for line ", (progresscount).to_i)
      end
    end
    #debugger
    puts "string to numeric conversion complete"
    progresscount = 0
    @filteredarray=[]
    @foundamatch=false
    arrayinput.each do |v| #v is a line [a,b,b,....,d]
      
      #debugger
      #coefficient of variance
      #puts $opts.to_s
      if ((($opts[:fa] and ("Fatty Acyls [FA]"==v[19])) || ($opts[:gl] and ("Glycerolipids [GL]"==v[19])) || ($opts[:gp] and ("Glycerophospholipids [GP]"==v[19])) || ($opts[:pk] and ("Polyketides [PK]"==v[19])) || ($opts[:pr] and ("Prenol Lipids [PR]"==v[19])) || ($opts[:sl] and ("Saccharolipids [SL]"==v[19])) || ($opts[:sp] and ("Sphingolipids [SP]"==v[19])) || ($opts[:st] and ("Sterol Lipids [ST]"==v[19]))) || (($opts[:fa] and ("Fatty Acyls [FA]"==v[12])) || ($opts[:gl] and ("Glycerolipids [GL]"==v[12])) || ($opts[:gp] and ("Glycerophospholipids [GP]"==v[12])) || ($opts[:pk] and ("Polyketides [PK]"==v[12])) || ($opts[:pr] and ("Prenol Lipids [PR]"==v[12])) || ($opts[:sl] and ("Saccharolipids [SL]"==v[12])) || ($opts[:sp] and ("Sphingolipids [SP]"==v[12])) || ($opts[:st] and ("Sterol Lipids [ST]"==v[12]))) ||  (($opts[:fa] and ("Fatty Acyls [FA]"==v[5])) || ($opts[:gl] and ("Glycerolipids [GL]"==v[5])) || ($opts[:gp] and ("Glycerophospholipids [GP]"==v[5])) || ($opts[:pk] and ("Polyketides [PK]"==v[5])) || ($opts[:pr] and ("Prenol Lipids [PR]"==v[5])) || ($opts[:sl] and ("Saccharolipids [SL]"==v[5])) || ($opts[:sp] and ("Sphingolipids [SP]"==v[5])) || ($opts[:st] and ("Sterol Lipids [ST]"==v[5]))))
      then
      @foundamatch=true
          else
            next
            end
        #lipidgroup=v[19]
        #case lipidgroup
        #when
      #then next
      #else
        v.push((v[samples].stdev)/(v[samples].mean)) #modified from http://stackoverflow.com/questions/7749568/how-can-i-do-standard-deviation-in-ruby
        @filteredarray << v
        progresscount += 1
        progress("computed mean corrected standard deviation for line", (progresscount).to_f)
        #if (progresscount%5000==0) then puts @filteredarray.size.to_s #+ @filteredarray.to_s
        #placeholder = 0
        #CSV.open("dumpfile.csv", "wb") do |csv|
        #csv << @filteredarray
        #end
        #end


      end

    if (@foundamatch==true) then
      sorted = @filteredarray.sort { |a, b| b[-1] <=> a[-1] } #modified from http://stackoverflow.com/questions/7033719/sorting-a-two-dimensional-array-by-second-value
                                                          #    puts header.to_s
                                                          #   puts sorted[0..4].to_s
      CSV.open(output, "wb") do |csvline| #modified from http://stackoverflow.com/questions/4822422/output-array-to-csv-in-ruby
        csvline << header
        sorted[0..4].each { |v| csvline << v }
      end
      CSV.open("fulloutsorted.csv", "wb") do |csvline| #modified from http://stackoverflow.com/questions/4822422/output-array-to-csv-in-ruby
        csvline << header
        sorted.each { |v| csvline << v }
      end
      else
  puts "no matches found!"
      end
  end

  end
a= Top5.new
a.read
