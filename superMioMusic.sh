#!/bin/bash

MUSIC_DIR=$HOME/Music
IMAGE_DIR=$HOME/Rice/musicMio
COVER=/tmp/cover.jpg

export MPD_HOST=~/.config/mpd/socket 
	
function reset_background
{

	if [ "$(mpc --format %album% current)" == '' ]; then
		echo 'resetting background'
		feh --bg-fill  $IMAGE_DIR/wallpaper.png
		rm $IMAGE_DIR/album
		touch $IMAGE_DIR/album
		return
	fi
	echo 'running cover' 
	
    album="$(mpc --format %album% current)"
    oldAlbum="$(< $IMAGE_DIR/album)"
    file="$(mpc --format %file% current)"
    album_dir="${file%/*}"
    [[ -z "$album_dir" ]] && exit 1
    album_dir="$MUSIC_DIR/$album_dir"
	if [[ $oldAlbum != *"$album"* ]]; then
    covers="$(find "$album_dir" -type d -exec find {} -maxdepth 1 -type f -iregex ".*/.*\(${album}\|cover\|folder\|artwork\|front\).*[.]\(jpe?g\|png\|gif\|bmp\)" \; )"
    src="$(echo -n "$covers" | head -n1)"
    rm -f "$COVER" 
    if [[ -n "$src" ]] ; then
        convert "$src" -resize 500x  "$COVER"
        convert "$COVER" "$COVER".png
        if [[ -f "$COVER" ]] ; then
          
			width=$(convert /tmp/cover.jpg.png -ping -format "%[fx:w-1]" info:)
			height=$(convert /tmp/cover.jpg.png -ping -format "%[fx:h-1]" info:)
			p1=0,0
			p2=$width,0
			p3=$width,$height 
			p4=0,$height 


			w1=1045,365
			w2=1450,290
			w3=1440,890
			w4=1050,828

			points="$p1 $w1 $p2 $w2 $p3 $w3 $p4 $w4"
			echo $points

			#nice -n 19 convert -transparent black /tmp/cover.jpg.png /tmp/cover.jpg.png 

			nice -n 19 convert $IMAGE_DIR/wallpaper.png  \( /tmp/cover.jpg.png -matte -virtual-pixel transparent +distort Perspective "$points" \) -compose over -layers merge $IMAGE_DIR/album_merged.png 

			nice -n 19 composite $IMAGE_DIR/3.png $IMAGE_DIR/album_merged.png  -alpha Set $IMAGE_DIR/output.png 
		#	nice -n 19 composite $IMAGE_DIR/3.png $IMAGE_DIR/wallpaper.png -alpha Set $IMAGE_DIR/output.png

           feh --bg-fill $IMAGE_DIR/output.png

		fi
	fi
   
   fi
    rm $IMAGE_DIR/album
	touch $IMAGE_DIR/album
    echo "$album" >> $IMAGE_DIR/album
} 
while true ; do
	if ! mpc status >/dev/null; then
		sleep 5
	else
		reset_background
		mpc idle

	fi
done &
