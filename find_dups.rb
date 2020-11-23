require 'digest'
require 'exifr/jpeg'
require 'sqlite3'
DBNAME = "/home/rodb/Projects/file_fixing/files_db.sqlite"
db = SQLite3::Database.open(DBNAME)

subdir = "2009/2009-01"
buildcmd = true
$buildsha = nil
exec_name = "" #"xviewer" #"celluloid"

target_list = Dir.glob("/media/rodb/VERBATIM HD/Photos/#{subdir}/**/*.*")
source_list = Dir.glob("/home/rodb/Photos/#{subdir}/**/*.*")
output = File.new("/home/rodb/temp/to_move_t1.txt",'w')

     #change hash content from array to hash
     # to-do
     #  1. Create RDB
     #  2. Create a count variable to use as the foreign key value to use between tables.
     #     Base it on the highest value from the targeted table
     #  3.


class File_Compare < File
 
  attr_accessor :file_name, :file_location, :file_ext, :file_sha, :file_size, :dt_digitized, :name_without_ext, :id, :count

  def initialize(file_input)
    @file_name = File.basename(file_input)
    @file_location = File.dirname(file_input)
    @file_ext = File.extname(file_input)
    @file_sha = Digest::SHA256.hexdigest File.read(file_input) if $buildsha
    @file_size = File.size(file_input)
    @dt_digitized = EXIFR::JPEG.new(file_input).date_time_digitized
    @name_without_ext = File.basename(file_input, @file_ext)    
    @count = 0
  end
  
  def id
    return @file_location+"/"+@file_name  
  end
end

def hash_array(file_hash, file_name, fc)
 if !file_hash[file_name] then
  file_hash[file_name] = [1]
  file_hash[file_name] = file_hash[file_name] + [fc]
  #puts "1st file_hash = #{file_hash[file_name]} file name #{file_name}"
  db.execute =
 else
  file_hash[file_name][0] += 1
  #puts "file #{file_name} count is #{file_hash[file_name][0]}" if (file_hash[file_name][0] > 2)
  file_hash[file_name] = file_hash[file_name] + [fc] #file_hash.merge(file_location, file_sha, file_size)
 # puts "2nd file_hash = #{file_hash.class} value = #{file_hash[file_name]} file name #{file_name}"
 end
 #puts "#{file_name} = #{file_hash[file_name]}"
end

def parms(instring,inkey)
 return "\'"+instring+'/'+inkey+"\'"+' '
end



source_file_hash = {}
target_file_hash = {}
source_digitized = {}
target_digitized = {}
source_multiple = []
target_multiple = []
#puts source_list

    if db.execute "SELECT * FROM Files LIMIT 1" then
    cur_fil_rec = (db.execute "SELECT Files.Id FROM Files ORDER BY Files.ID
                    DESC LIMIT 1").flatten[0]
    else cur_fil_rec = 0
    end
    
    if db.execute "SELECT * FROM Files LIMIT 1" then
    cur_loc_rec = (db.execute "SELECT Locations.Id FROM Locations ORDER BY Locations.ID
                    DESC LIMIT 1").flatten[0]
    else cur_loc_rec = 0
    end
    
    if db.execute "SELECT * FROM Files LIMIT 1" then
    cur_fil_loc_rec = (db.execute "SELECT File_Location.Id FROM File_Location ORDER BY File_Location.ID
                    DESC LIMIT 1").flatten[0]
    else cur_fil_loc_rec = 0
    end


source_names = source_list.map {|x| File.basename(x)}
target_names = target_list.map {|x| File.basename(x)}
source_notin_tgt = (source_names - target_names).sort
target_notin_src = (target_names - source_names).sort
#puts source_notin_tgt
#source_notin_tgt[/(.*)\./][0..-2].each {|x| puts "source_file_hash[x] #{source_file_hash[x]} file_name = #{x}"} #.file_location+'/'+source_file_hash[x].file_name}
#puts "start of source_notin_tgt"
#puts "end of source_notin_tgt"
#####################
#############
#source_file_hash = source_list.map {|filename| fc = File_Compare.new(filename)
# [fc.name_without_ext, [fc]]}.to_h
#
#puts source_file_hash.length
#############

source_list.flatten.each {|infile|
   puts infile
   temp = File_Compare.new(infile)
   if ! source_digitized[temp.dt_digitized] then
    source_digitized = {temp.dt_digitized => 1}
   else source_digitized[temp.dt_digitized] += 1
    source_multiple += [infile]
   end
   hash_array(source_file_hash,temp.name_without_ext.downcase,temp)
#   puts "source file #{temp.file_name} count is #{temp.count}" if (temp.count > 1)
   #puts temp.file_size
  }

target_list.flatten.each {|infile|
   puts infile
   temp = File_Compare.new(infile)
   if ! target_digitized[temp.dt_digitized] then
    target_digitized = {temp.dt_digitized => 1}
   else target_digitized[temp.dt_digitized] += 1
   end
   hash_array(target_file_hash,temp.name_without_ext.downcase,temp)
   #puts "target file #{temp.file_name} count is #{temp.count}" if (temp.count > 1)
   #puts temp.file_size
  }

source_notin_tgt.each {|f|
  temp = f[/(.*)\./][0..-2].downcase
  source_file_hash[temp].each {|x| puts x.file_location+"/"+x.file_name if x.file_name == temp}
}

size_diff_count = 0
missed_total = 0
#command = Array.new(6)
command = [""]
#command[0] = ""

#  Build the command to review photos
       source_file_hash.keys.each {|key|
        source_file_hash[key].each {|sfh|
        output.puts "#{sfh.file_sha} \t #{sfh.id}" if $buildsha
        }
         if ! target_file_hash[key] then
           missed_total += 1
           #puts "class of source_file #{source_file_hash[key][0][0].class}"
          command[0] += parms(source_file_hash[key][0].file_location, source_file_hash[key][0].file_name) if buildcmd
         elsif target_file_hash[key][0].file_size != source_file_hash[key][0].file_size
           size_diff_count += 1
         command[0] += parms(source_file_hash[key][0].file_location, source_file_hash[key][0].file_name) if buildcmd
         end
          #if missing_count >= 500 then
           #puts "missing count = #{missing_count}"
           #puts "command length = #{command[cmdind].length}"
           #puts "command = #{command[cmdind].to_s} and cmdind = #{cmdind}"
        #  system("xviewer "+ command[0].to_s)
           #missing_count = 0
           #command = [""]
           ##cmdind = cmdind + 1
          #end
         }
###

    #puts "command = #{command.to_s} and cmdind = #{cmdind}"

    system(exec_name + " " + command[0].to_s) if buildcmd
#
#puts "command is #{command} "
#puts "cmdind = #{cmdind}"
#["0","1","2","3","4","5"].each {|x| system("xviewer "+ command[x])}
source_multiple.each {|x| puts x}

puts "source list length = #{source_list.length}"
puts "target list length = #{target_list.length}"
puts "source files not in target = #{source_notin_tgt.length}"
puts "target files not in source = #{target_notin_src.length}"

puts "source missing from target = #{missed_total}"
puts "files with size difference = #{size_diff_count}"

########## source_file_hash = source_file_hash.merge(temph) {|key, old, new| [old, new]}  ############
 