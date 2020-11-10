#list all extentions found
files = Dir.glob('/media/rodb/VERBATIM HD/Photos/2009/**/*.*')
exts = files.map {|x| File.extname(x)}
ext_list = exts.uniq.sort
puts ext_list
File.rename("/home/rodb/Photos/2009/2009-08/#{oldfile}.jpg","/home/rodb/Photos/2009/2009-08/#{oldfile}"1.jpg)

missing2.each {|fnin| fn =  File.basename("/home/rodb/Photos/2009/2009-08/#{fnin}", ".jpg")
  File.rename("/home/rodb/Photos/2009/2009-08/#{fnin}","/home/rodb/Photos/2009/2009-08/#{fn}_lc.jpg")}

target_list = Dir.glob("/media/rodb/VERBATIM HD/Photos/2009/2009-08/**/*.*")
source_list = Dir.glob("/home/rodb/Photos/2009/2009-08/**/*.*")
source_files = source_list.map {|x| [[File.dirname(x)], [File.basename(x)], [File.extname(x)]]}
target_files = target_list.map {|x| [[File.dirname(x)], [File.basename(x)], [File.extname(x)]]}
source_name = source_files.map {|x| x[1]}
target_name = target_files.map {|x| x[1]}
missing = target_name - source_name

source_files.each {|dir,name,ext| test_name = name.to_s + ext.to_s
  if missed.include? test_name then
    puts test_name
    #puts dir.to_s+name.to_s+"01"+ext.to_s
  end
}

#separate fn from ext
#build fn + "01" + ext