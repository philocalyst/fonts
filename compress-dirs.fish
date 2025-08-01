#!/usr/bin/env /home/miles/fish-shell/target/release/fish
# input dir (default = pwd)
set input_dir (pwd)
if test (count $argv) -ge 1
   set input_dir $argv[1]
end

set input_dirs (find $input_dir -maxdepth 1 )

for file in $input_dirs
 set innards (find $file -maxdepth 1)
 tar -czvf $file.tar.gzip $innards
end

