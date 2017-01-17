#!/bin/bash


checkrss() {

last=""
link=$1
imgdir=$2
fname=`basename $link`
ffullname=${imgdir}/$fname
#echo -n "Blah "
#echo -n $imgdir
#echo "Blah end"

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
	echo "dummy" #find a better way
    sleep 1m
done

}

download_and_set()
{
	imagedir=$1
	imageurl=$2
	imagename=`basename $imageurl | awk '{split($1,a,"?"); print a[1]}'`
	if [[ ${imagedir}/$imagename ]]
	then
		rm -rf ${imagedir}/$imagename
	fi
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

URLFILE="./url.txt"
RSSFILE="$HOME/.sd/url.txt"
IMGDIR="$HOME/.sd/"
fds=( )

setup () {
	rm -rf $IMGDIR
	mkdir -p $IMGDIR
	cp $URLFILE $IMGDIR
}


init () {
mkdir -p $IMGDIR

for line in `cat $RSSFILE`
do
	exec {fd}< <(checkrss $line $IMGDIR)
	fds+=( $fd )
done

}

clean () {
	rm -rf $IMGDIR
}

while getopts ":sc" opt ; 
do
	case "$opt" in
		s)
			setup
			exit
		;;
		c)
			clean
			exit
		;;
		*)
			;;
	esac
done


init
manage



