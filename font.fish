#!/usr/bin/env /home/miles/fish-shell/target/release/fish

# common extensions
set -x font_exts ttf otf woff2 woff eot

# style mapping: lowercase key → canonical form
set -x style_keys     regular bold    italic  oblique \
                     light   medium  thin    black   \
                     extra   condensed expanded semi
set -x style_vals     Regular Bold    Italic  Oblique \
                     Light   Medium  Thin    Black   \
                     Extra   Condensed Expanded Semi

function main
    # input dir (default = pwd)
    set input_dir (pwd)
    if test (count $argv) -ge 1
        set input_dir $argv[1]
    end

    # validate
    if not test -d $input_dir
        echo "Error: '$input_dir' is not a directory" >&2
        exit 1
    end

    # prepare dist/
    set dist_dir (realpath $input_dir)/dist
    mkdir -p $dist_dir
    or begin
        echo "Error: could not create '$dist_dir'" >&2
        exit 1
    end

    # for each immediate subdir
    for dir in $input_dir/*/
        if not test -d $dir
            continue
        end
        set family (basename $dir)
        if test $family = dist
            continue
        end

        set out_sub $dist_dir/$family
        mkdir -p $out_sub
        or begin
            echo "Warning: cannot create '$out_sub'" >&2
            continue
        end

        # build find args: -type f \( -iname *.ttf -o -iname *.otf … \)
        set find_args -type f '('
        for ext in $font_exts
            set find_args $find_args -iname "*.$ext" -o
        end
        # drop trailing -o
        set find_args $find_args[1..-2]
        # close paren
        set find_args $find_args ')'

        # run find
        set font_files (command find $dir $find_args)
        for file in $font_files
            process_font $file $family $out_sub
        end
    end

    compress_dirs $dist_dir
    echo "Done. Fonts in '$dist_dir'."
end

function process_font -a file family out_sub
    # only real files
    if not test -f $file
        return
    end

    # split name/ext
    set bname (basename $file)
    set ext    (string lower (string split -r -m1 . $bname)[2])
    set name   (string split -r -m1 . $bname)[1]

    if not contains $ext $font_exts
        return
    end

    # detect modifiers
    set ln (string lower $name)
    set modifiers
    for idx in (seq (count $style_keys))
        set key $style_keys[$idx]
        set val $style_vals[$idx]
        if string match -q "*$key*" $ln
            set -a modifiers $val
        end
    end
    if test (count $modifiers) -eq 0
        set modifiers Regular
    end
    set mod (string join '' $modifiers)

    # build new name and target
    set base "$family-$mod"
    set new  "$base.$ext"
    set dst  "$out_sub/$new"

    # collision handling
    set i 1
    while test -e $dst
        set new "$base-$i.$ext"
        set dst "$out_sub/$new"
        set i (math $i + 1)
    end

    cp $file $dst \
        && echo "Copied: '$file' → '$dst'" \
        || echo "Error: failed to copy '$file'" >&2
end

function compress_dirs -a input
 set input_dir $input
 if test (count $argv) -ge 1
     echo "Please specificy an input"
 end

 # Make sure this happens in the right place
 cd $input_dir

 set input_dirs (find $input_dir -maxdepth 1 )

 for file in $input_dirs
  set innards (find $file -maxdepth 1)
  tar -czvf $file.tar.gzip $innards
 end
end

# entrypoint
main $argv
