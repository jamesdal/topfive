$LOAD_PATH << '.'
require 'CSV'
require 'roo'
require 'spreadsheet'
require 'trollop'
#trim the data
#give it to matlab
#call matlab to run the data
#in the matlab code, have it write a new csv with the X array
#put the X array back where it belongs
#pass it along to top5
#please note, this build works best on windows-- calling NOMIS.exe doens't work great on linux, but it works fine on win64
$opts = Trollop::options do
  opt :blanks, "Blank columns", :default => "29..31"
  #opt :standards, "Standard columns", :default => "4..28" #.split('..').inject { |s,e| s.to_i..e.to_i }
  opt :samples, "Sample columns", :default => "4..28"
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
  opt :stdinfile, "Experimental input file from mspire-lipidomics, xlsx format", :default => "input.xlsx"
  opt :expinfile, "Standard input file from mspire-lipidomics, xlsx format", :default => "input.xlsx"
  opt :stdrange, "experimental range, in A1:c2 format (top left:bottom right)", :default => "e2:ac6"
  opt :exprange, "experimental range, in A1:c2 format (top left:bottom right)", :default => "e7:ac1476"
  #opt :blankinfile, "blank infile", :default => "input.xlsx"#blanks must be in the experimental file, specified by cols
  #opt :blankrange, "blank range", :default => "AD2:af1476"  
end

#class Nomis
#fix this with a file copy instead of overwriting
#def bias_correction #this assumes the blanks are in the experimental 
 wb = Spreadsheet.open %Q{#{$opts[:expinfile].to_s}} #http://spreadsheet.rubyforge.org/files/GUIDE_txt.html from "Modifying an existing document"
 page = wb.worksheet 0
linecount = 0 
 page.each do |row|
 if (linecount != 0)
 puts row.to_s
 #http://stackoverflow.com/questions/53472/best-way-to-convert-a-ruby-string-range-to-a-range-object
 blankarray=row[$opts[:blanks].split('..').inject { |start,stop| start.to_i..stop.to_i }]
 blankarray.select!{|cell| cell != 0}
 puts blankarray.to_s + blankarray.class.to_s
 nonzeroblankavg=(blankarray.map.reduce(:+))/(blankarray.size)
 samplearray=row[$opts[:samples].split('..').inject { |start,stop| start.to_i..stop.to_i }]
 puts samplearray.to_s + samplearray.class.to_s
 observedfraction = 1.0-(samplearray.count(0.0).to_f)/(samplearray.length.to_f)
row.push(observedfraction) 
 row[$opts[:blanks].split('..').inject { |start,stop| start.to_i..stop.to_i }] = samplearray.map{|cell| cell != 0 ? cell - nonzeroblankavg : cell} 
 
 end
 linecount += 1
 end
 wb.write %Q{#{$opts[:expinfile].to_s}}
#end
#def performNOMIS
%x{NOMIS.exe #{$opts[:expinfile]} #{$opts[:stdinfile]} #{$opts[:exprange]} #{$opts[:stdrange]}}
puts "NOMIS calculations complete, output is found in NOMISout.xls"
msloutput = Excel.new('NOMISout.xls')
msloutput.to_csv("NOMISout.csv")
puts "CSV conversion complete, csv is named NOMISout.csv"
#output to top5, need some way to convert the top 5 options above to go into the command line execution of top5.  For the moment, I'll table it.
#%x{top5.rb -fa
#end
#end
#a= Nomis.new()
#a.bias_correction
#a.performNOMIS
