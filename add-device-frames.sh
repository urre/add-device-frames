#!/bin/bash

# Add device frames to screenshots. By Urban Sanden
#
# 1. Install imagemagick: brew install imagemagick
# 2. Download device images ex. from Apple:
#    curl https://devimages-cdn.apple.com/design/resources/download/Bezel-iPhone-14.dmg
# 2.1 Unpack the DMG, find the PNG you want and set the path below
# 3 Make mobile screenshots, preferably in Apple iOS Simulator using bash bash add-device-frames.sh
#
# Arguments:
#   $1: file type - jpg or png
#   $2: offset width - ex 60
#   $3: offset height - ex 60
#   $4: background color - ex white
#
# Note:
#   The script will batch all screenshots in the current folder, adjust the filename glob in L33 to your needs and options L20-23.
#   This example has been tested with an iPhone device frame at the moment, more adjustments could be needed/added for it to work on more devices.

CURRENT_FOLDER=$(pwd)
FRAME="iPhone 14 - Starlight - Portrait.png"
WIDTH=2732
HEIGHT=1370

# Resize the device frame image
mogrify -resize "$WIDTH"x"$HEIGHT" "$CURRENT_FOLDER"/"$FRAME"

# Create a mask with rounded corners
convert -size "$HEIGHT"x"$WIDTH" xc:none -draw "roundrectangle 0,0,"$HEIGHT","$WIDTH",140,140" mask.png

# Add device frame to all screenshots in the current folder
count=1
for file in *simulator*; do
	if [ -f "$file" ]; then

		# Create a screenshot with the mask
		convert "$file" -matte mask.png -compose DstIn -composite "screenshot-rounded-$count".png

		# Resize the screenshot image to be the same size as the device frame
		mogrify -resize "$WIDTH"x"$HEIGHT" "screenshot-rounded-$count".png

		# Merge the device frame image with the screnshots
		convert "$FRAME" \( "screenshot-rounded-$count".png -resize 92.75% \) -gravity center -geometry +0-2 -compose dstover -composite "screenshot-temp-$count".png

		# If offset given as an argument, add white background, and the offset in pixels on the sides
		if [ "$2" != "0" ]; then
			convert "screenshot-temp-$count".png -gravity center -background $4 -extent $(identify -format "%[fx:w+$2]x%[fx:h+$3]" "screenshot-temp-$count".png) "screenshot-temp-$count".png
		else
			convert "screenshot-temp-$count".png -gravity center "screenshot-temp-$count".jpg
		fi

		# JPG or PNG?
		if [ "$1" == "jpg" ]; then
			convert "screenshot-temp-$count".png -quality 100 -resize x1600\> "screenshot-$count".jpg
		else
			mv "screenshot-temp-$count".png "screenshot-$count".png
		fi

		count=$((count+1))
	fi
	done

	# Cleanup
	rm screenshot-temp-*
	rm screenshot-rounded-*
	rm mask.png
