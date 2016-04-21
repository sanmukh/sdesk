#!/bin/bash


checkrss() {

last=""
link=$1
imgdir=$2
fname=`basename $link`
ffullname=${imgdir}/$fname

while [[ 0 -eq 0 ]]
do
	# get the rss
	rm -rf $ffullname
	wget -P $imgdir $link 2> /dev/null
	now="$(cat $ffullname | grep pubDate | head -1)"

	if [[ "$last" != "$now" ]]
	then
		last="$(cat $ffullname | grep pubDate | head -1)"
		enclosurename=`cat $ffullname | grep enclosure | head -1`
		imageurl=`echo $enclosurename | awk -F\" '{print $2}'`
		echo $imageurl
	fi
	echo "dummy"
    sleep 1m
done

}

download_and_set()
{
	imagedir=$1
	imageurl=$2
	imagename=`basename $imageurl | awk '{split($1,a,"?"); print a[1]}'`
	imageurl=`echo $imageurl | awk '{split($1,a,"?"); print a[1]}'`
	wget -P $imagedir $imageurl 2> /dev/null
	echo $imageurl
	echo $imagename
	gsettings set org.gnome.desktop.background draw-background false && gsettings set org.gnome.desktop.background picture-uri file://$imagedir/$imagename

}

manage() {
	while [[ 0 -eq 0 ]]
	do
		for fd in ${fds[@]}
		do
		#	echo $fd
			read -u $fd -r filename 
			echo $filename
			if [[ $filename != "dummy" ]]
			then
				download_and_set $IMGDIR $filename
			fi
		done
		sleep 1m
	done

}

RSSFILE="/home/sanmukh/bin/sd/url.txt"
IMGDIR="/home/sanmukh/bin/sd/img/"
fds=( )

mkdir -p $IMGDIR

for line in `cat $RSSFILE`
do
	exec {fd}< <(checkrss $line $IMGDIR)
	fds+=( $fd )
done

manage


