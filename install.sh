#!/usr/bin/env bash

! command -v ffmpeg >/dev/null 2>&1 && {
	echo "Installing ffmpeg..."
	sudo apt-get install -y ffmpeg 2>/dev/null ||
		sudo dnf install -y ffmpeg 2>/dev/null ||
		sudo pacman -S --noconfirm ffmpeg 2>/dev/null ||
		sudo zypper install -y ffmpeg 2>/dev/null ||
		sudo apk add ffmpeg 2>/dev/null ||
		{
			curl -L https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz | sudo tar -xJ -C /tmp &&
				sudo cp /tmp/ffmpeg-*-amd64-static/ffmpeg /usr/bin/ &&
				sudo chmod +x /usr/bin/ffmpeg &&
				rm -rf /tmp/ffmpeg-*-amd64-static
		}
}

sudo tee /usr/bin/mdit >/dev/null <<'EOF'
#!/usr/bin/env bash

shopt -s nullglob

all=false
ind=1
acc=false
each=false
inplace=false

get_tags() {
	local tags
	mapfile -t tags < <(ffprobe -v quiet \
		-show_entries format_tags=title,artist,album \
		-of default=noprint_wrappers=1:nokey=1 "$1")

	title="${tags[0]:-Unknown Title}"
	artist="${tags[1]:-Unknown Artist}"
	album="${tags[2]:-Unknown Album}"
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	-i)
		inplace=true
		shift
		;;
	-s)
		echo "============================="
		for i in *.mp3; do
			get_tags "$i"
			echo "$title by $artist from $album"
			echo "============"
			echo "Title: $title"
			echo "Album: $album"
			echo "Artist: $artist"
			echo "============================="
		done
		exit 0
		;;
	-e)
		each=true
		shift
		;;
	-a)
		all=true
		shift
		;;
	-h)
		echo "Go read the manual from github :/"
    echo "https://github.com/psdkjoon/mdit"
		exit 0
		;;
	-*)
		echo "Invalid argument $1" >&2
		exit 1
		;;
	*)
		args+=("$1")
		shift
		;;
	esac
done

clear

if [[ $all == "false" ]]; then
	for i in *.mp3; do
		get_tags "$i"
		echo "$title by $artist from $album"
		read -p "change? [Y/n/f] " -r -n 1 ans
		read -t 0.1 -s
		if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
			change+=("$i")
			echo
			echo " => Marked.."
		elif [[ -z "$ans" ]]; then
			change+=("$i")
			echo " => Marked.."
		elif [[ "$ans" == "n" || "$ans" == "N" ]]; then
			echo
			echo " => Skipped.."
		elif [[ "$ans" == "f" || "$ans" == "F" ]]; then
			echo
			echo " => Finishing the Selection.."
			sleep 0.5
			break
		else
			echo
			echo " => Invalid key ('$ans'). Skipped.."
		fi
	done
else
	change+=(*.mp3)
fi

clear

if [[ ${#change[@]} -eq 0 ]]; then
	echo "No music is selected" >&2
	exit 1
fi

mkdir mdit_output

if [[ "$each" == "true" ]]; then
	for i in "${change[@]}"; do
		get_tags "$i"
		echo "$title by $artist from $album"
		echo "t for Titles"
		echo "a for Albums"
		echo "r for artists"
		read -p "What to change? [T/a/r] " -r -n 1 ans
		read -t 0.1 -s
		if [[ "$ans" == "t" || "$ans" == "T" ]]; then
			echo
			ind=1
			read -e -p "New Title: " -i "$title" new
		elif [[ -z "$ans" ]]; then
			ind=1
			read -e -p "New Title: " -i "$title" new
		elif [[ "$ans" == "a" || "$ans" == "A" ]]; then
			echo
			ind=2
			read -e -p "New Album: " -i "$album" new
		elif [[ "$ans" == "r" || "$ans" == "R" ]]; then
			echo
			ind=3
			read -e -p "New Artist: " -i "$artist" new
		else
			echo
			echo " => Invalid key ('$ans'). Skipping.."
			continue
		fi
		read -p "You entered: $new, Do you Accept? [Y/n]" -r -n 1 ans
		read -t 0.1 -s
		if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
			echo
			acc=true
		elif [[ -z "$ans" ]]; then
			acc=true
		elif [[ "$ans" == "n" || "$ans" == "N" ]]; then
			echo
			echo " => Skipping.."
			acc=false
		else
			echo
			echo " => Invalid key ('$ans'). Skipped.."
			acc=false
		fi
		if [[ $acc == "true" ]]; then
			safe_title="${title//"\/"/"-"}"
			case $ind in
			1)
				safe_title="${new//"\/"/"-"}"
				ffmpeg -i "$i" -metadata title="$new" -codec copy "mdit_output/${safe_title}.mp3" -loglevel error
				;;
			2)
				ffmpeg -i "$i" -metadata album="$new" -codec copy "mdit_output/${safe_title}.mp3" -loglevel error
				;;
			3)
				ffmpeg -i "$i" -metadata artist="$new" -codec copy "mdit_output/${safe_title}.mp3" -loglevel error
				;;
			esac
		fi
		if [[ $? -ne 0 ]]; then
			echo "Error: ffmpeg failed to process '$i'. " >&2
			rm -f "mdit_output/${safe_title}.mp3"
			continue
		fi
		clear
	done
else
	echo "t for Titles"
	echo "a for Albums"
	echo "r for artists"
	read -p "What to change? [T/a/r] " -r -n 1 ans
	read -t 0.1 -s
	if [[ "$ans" == "t" || "$ans" == "T" ]]; then
		echo
		ind=1
	elif [[ -z "$ans" ]]; then
		ind=1
	elif [[ "$ans" == "a" || "$ans" == "A" ]]; then
		echo
		ind=2
	elif [[ "$ans" == "r" || "$ans" == "R" ]]; then
		echo
		ind=3
	else
		echo
		echo " => Invalid key ('$ans'). Skipping.." >&2
		exit 1
	fi
	read -p "Enter a search term: (Can use RegEx) " -r term
	read -p "Enter a replacement term: " -r replace
	for i in "${change[@]}"; do
		get_tags "$i"
		safe_title="${title//"\/"/"-"}"
		case $ind in
		1)
			new=${title//$term/$replace}
			safe_title="${new//"\/"/"-"}"
			ffmpeg -i "$i" -metadata title="$new" -codec copy "mdit_output/${safe_title}.mp3" -loglevel error
			;;
		2)
			new=${album//$term/$replace}
			ffmpeg -i "$i" -metadata album="$new" -codec copy "mdit_output/${safe_title}.mp3" -loglevel error
			;;
		3)
			new=${artist//$term/$replace}
			ffmpeg -i "$i" -metadata artist="$new" -codec copy "mdit_output/${safe_title}.mp3" -loglevel error
			;;
		esac
		if [[ $? -ne 0 ]]; then
			echo "Error: ffmpeg failed to process '$i'. " >&2
			rm -f "mdit_output/${safe_title}.mp3"
			continue
		fi
		clear
	done
fi

if [[ "$inplace" == "true" ]]; then
	for i in "${change[@]}"; do
		rm "$i"
	done
	mv -f ./mdit_output/* ./
	rm -rf ./mdit_output
fi
EOF

sudo chmod +x /usr/bin/mdit
sudo rm -rf *.md
