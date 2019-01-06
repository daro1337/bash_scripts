#! /usr/bin/env bash 
#naprawiacz do krzaków pobranych z Qnapi

if [ $# -ne 1 ] ; then
	echo "podaj ścieżkę do napisów!"
	exit 1
fi

fpath="$@"
fout=$(echo "$fpath" | sed s/txt/srt/g)
# ź ż ń ó ś ę ą ł ć
sed ' s!Ĺş!ź!g ; s!ĹĽ!ź!g ; s!Ĺ„!ń!g ; s!Ăł!ó!g ; s!Ĺ›!ś!g ;s!Ä™!ę!g ; s!Ä…!ą!g  ; s!Ĺ‚!ł!g ; s!Ä‡!ć!g' "$fpath" > "$fout"
