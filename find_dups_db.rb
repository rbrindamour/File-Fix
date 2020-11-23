require 'digest'
require 'exifr/jpeg'
require 'sqlite3'
DBNAME = "/home/rodb/Projects/file_fixing/files_db.sqlite"
db = SQLite3::Database.open(DBNAME)

subdir = "2009"
buildcmd = true
$buildsha = nil
exec_name = "" #"xviewer" #"celluloid"

target_list = Dir.glob("/media/rodb/VERBATIM HD/Photos/#{subdir}/**/*.*")
source_list = Dir.glob("/home/rodb/Photos/#{subdir}/**/*.*")
puts target_list.length

$dir_hash = {}

cur_loc_rec = 1
Dir.glob("/media/rodb/VERBATIM HD/Photos/**/**/*").select {|directory| if (directory.match(/2009/) and File.directory? directory) then
 ins_loc = "INSERT INTO Locations (Id, Directory) Values" + %$(#{cur_loc_rec}, "#{directory}")$
 $dir_hash[directory] = cur_loc_rec
 db.execute ins_loc
 cur_loc_rec += 1
end
}

Dir.glob("/home/rodb/Photos/**/**/*").select {|directory| if (directory.match(/2009/) and File.directory? directory) then
 ins_loc = "INSERT INTO Locations (Id, Directory) Values" + %$(#{cur_loc_rec}, "#{directory}")$
 $dir_hash[directory] = cur_loc_rec
 db.execute ins_loc
 cur_loc_rec += 1
end
}
#puts $dir_hash
#puts "$dir_hash contains #{$dir_hash} directories"
#temp.each {|x| puts "directory = #{x}"}

#output = File.new("/home/rodb/temp/to_move_t1.txt",'w')

     #change hash content from array to hash
     # to-do
     #  1. Create RDB DONE
     #  2. Create a count variable to use as the foreign key value to use between tables.
     #     Base it on the highest value from the targeted table (Files and File_Location only) DONE
     #  3. Set File_Location.Location_Id to hash of Location DONE

#file_name        = File.basename(file_input)
#file_location    = File.dirname(file_input)
#file_ext         = File.extname(file_input)
#file_sha         = Digest::SHA256.hexdigest File.read(file_input) if $buildsha
#file_size        = File.size(file_input)
#date_digitized   = EXIFR::JPEG.new(file_input).date_time_digitized
#name_without_ext = File.basename(file_input, file_ext)    
#count = 0


source_file_hash = {}
target_file_hash = {}
source_digitized = {}
target_digitized = {}
source_multiple = []
target_multiple = []
#puts source_list
cur_fil_rec = 1
cur_loc_rec = 1
cur_fil_loc_rec = 1
#puts  cur_fil_rec

#source_file_hash = source_list.map {|fil| [File.basename(fil),1]}.to_h

temp = 1 if (db.execute "SELECT Files.Id FROM Files LIMIT 1") == []
#puts "Temp = #{temp}"
#puts "Select is #{temp}"

    if (db.execute "SELECT Files.Id FROM Files LIMIT 1") != [] then
    cur_fil_rec = (db.execute "SELECT Files.Id FROM Files ORDER BY Files.ID
                    DESC LIMIT 1").flatten[0]
 #   puts "Cur_fil 1 = #{cur_fil_rec.class}"
    else cur_fil_rec = 1
 #   puts "Cur_fil 2 = #{cur_fil_rec}"
    end
    
    if (db.execute "SELECT Locations.Id FROM Locations ORDER BY Locations.Id LIMIT 1") != [] then
    cur_loc_rec = (db.execute "SELECT Locations.Id FROM Locations ORDER BY Locations.ID
                    DESC LIMIT 1").flatten[0]
    else cur_loc_rec = 0
    end
    #
    #if (db.execute "SELECT File_location.Id FROM File_Location ORDER BY File_Location.Id LIMIT 1") != [] then
    #cur_fil_loc_rec = (db.execute "SELECT File_Location.Id FROM File_Location ORDER BY File_Location.ID
    #                DESC LIMIT 1").flatten[0]
    #else cur_fil_loc_rec = 1
    #end
 #puts  cur_fil_rec
 #puts  cur_loc_rec
 #puts  cur_fil_loc_rec


source_names = source_list.map {|x| File.basename(x)}
target_names = target_list.map {|x| File.basename(x)}
#source_notin_tgt = (source_names - target_names).sort
#target_notin_src = (target_names - source_names).sort

    [source_list,target_list].each {|file_list|
    file_list.flatten.each {|infile|
  #puts infile
        
       file_name        = File.basename(infile)
       file_location    = File.dirname(infile)
       file_sha         = Digest::SHA256.hexdigest File.read(infile) if $buildsha
       file_size        = File.size(infile)
  #     date_digitized   = ""
  #     if (["jpg","JPG","jpeg"].include?(File.extname(infile)) and EXIFR::JPEG.new(infile).date_time_digitized) then
       date_digitized   = EXIFR::JPEG.new(infile).date_time_digitized
  #     end
       if source_file_hash[file_name] then
        found_id = source_file_hash[file_name]
        cur_loc_rec = $dir_hash[file_location]
   #puts "#{file_name} exists and ID = #{found_id}"
        #ins_file = "INSERT INTO Files (Id, Name, Size, Date_Digitized, Target) Values" + %$(#{found_id}, "#{file_name}","#{file_size}", "#{date_digitized}", 1)$
        ins_fil_loc = "INSERT INTO File_Location (Id, File_Id, Location_Id) Values"+ %$(#{cur_fil_loc_rec}, #{found_id}, #{cur_loc_rec})$
        cur_fil_loc_rec += 1
        #puts "ins_fil_loc =#{ins_fil_loc}"
        db.execute ins_fil_loc
       else
        source_file_hash[file_name] = cur_fil_rec
        if $dir_hash[file_location] then
        cur_loc_rec = $dir_hash[file_location]
   #puts "#{file_name} is new and ID = #{cur_fil_rec}"
        ins_file = "INSERT INTO Files (Id, Name, Size, Date_Digitized, Target) Values" + %$(#{cur_fil_rec}, "#{file_name}","#{file_size}", "#{date_digitized}", 1)$
        ins_fil_loc = "INSERT INTO File_Location (Id, File_Id, Location_Id) Values"+ %$(#{cur_fil_loc_rec}, #{cur_fil_rec}, #{cur_loc_rec})$
   #     puts "ins_fil_loc =#{ins_fil_loc}"
        cur_fil_loc_rec += 1
        cur_fil_rec += 1
        db.execute ins_file
        db.execute ins_fil_loc
       else
       end
       end
        
      # if ["jpg","JPG","jpeg"].include?(File.extname(infile)) then
      # date_digitized = EXIFR::JPEG.new(infile).date_time_digitized
      #end
  #puts "Cur_Fil before INSERT #{cur_fil_rec}"
  #puts "file_location = #{file_location}"
  #puts "dir_hash class = #{$dir_hash[file_location]}"
  #puts "cur_fil_loc_rec = #{cur_fil_loc_rec}"

     #ins_fil_loc = "INSERT INTO File_Location (Id, File_Id, Location_Id) Values"+ %$(#{cur_fil_loc_rec}, #{cur_fil_rec}, #{cur_loc_rec})$
     
      }
    }

#target_list.flatten.each {|infile|
#   puts infile
#   temp = File_Compare.new(infile)
#   if ! target_digitized[temp.dt_digitized] then
#    target_digitized = {temp.dt_digitized => 1}
#   else target_digitized[temp.dt_digitized] += 1
#   end
#   hash_array(target_file_hash,temp.name_without_ext.downcase,temp)
#  }

#source_notin_tgt.each {|f|
#  temp = f[/(.*)\./][0..-2].downcase
#  source_file_hash[temp].each {|x| puts x.file_location+"/"+x.file_name if x.file_name == temp}
#}

#size_diff_count = 0
#missed_total = 0
#command = [""]

#  Build the command to review photos
       #source_file_hash.keys.each {|key|
       # source_file_hash[key].each {|sfh|
       # output.puts "#{sfh.file_sha} \t #{sfh.id}" if $buildsha
       # }
       #  if ! target_file_hash[key] then
       #    missed_total += 1
       #   command[0] += parms(source_file_hash[key][0].file_location, source_file_hash[key][0].file_name) if buildcmd
       #  elsif target_file_hash[key][0].file_size != source_file_hash[key][0].file_size
       #    size_diff_count += 1
       #  command[0] += parms(source_file_hash[key][0].file_location, source_file_hash[key][0].file_name) if buildcmd
       #  end
       #  }
###

#system(exec_name + " " + command[0].to_s) if buildcmd

#source_multiple.each {|x| puts x}

#puts "source list length = #{source_list.length}"
#puts "target list length = #{target_list.length}"
#puts "source files not in target = #{source_notin_tgt.length}"
#puts "target files not in source = #{target_notin_src.length}"

#puts "source missing from target = #{missed_total}"
#puts "files with size difference = #{size_diff_count}"

 