#!/data/data/com.termux/files/usr/bin/bash

: SUBSCRIBE PEJUANG KENTANG
: PROJEK GABUT
: OPEN SOURCE
: EDUKASI

# depencies

exec 7<>/dev/null
{
	pkg=(
			"curl" "xh" "jq" "coreutils" "ncurses-utils"
			"ossp-uuid"
		)

	for depencies in "${pkg[@]}"; do
		apt-get install "$depencies" -y
	done
} >&7
exec 7<&-

# ===============================
# Framework Bash Id
source "lib/moduler.sh";

# Include Library Std :: Sys
Namespace Std :: Sys;{
	{ Bash.import: feature/io.echo; };{ const: __Say__ =\> say; }
	{ Bash.import: Shua/Ua; };{ const: __Shua__ =\> useragent; }
	{ Bash.import: log/warnings; };{ const: __warn__ =\> log; }
	{ Bash.import: colorsh/ink; }
	{ App:Import [shell.mod]; }

	shopt -s checkwinsize;: Auto refresh display
}

# oop kuis
class __kuis__;{ req="" resp="" base=""; let score=0; let page=0; let round=1; };{
	{
		public: app =\> [Parse]
		public: app =\> [Game]
	}

	public __kuis__::Parse(){
		var req = "https://m.merdeka.com/jateng/40-tebak-tebakan-ala-cak-lontong-dan-jawabannya-menghibur-dan-bikin-mikir-keras-kln.html"
		var header = "m.merdeka.com"

		base=$(xh GET "$req" \
			--body --follow \
			header:"host: $header");# base

		soal=$(@return: [base]|grep -Po '(<p>[0-9].*)'|head -40|sed 's/<p>//g;s/<\/p>//g;s/\&[a-zA-Z]*//g;s/\;//'|cut -d "<" -f 1)
		jawaban=$(@return: [base]|grep -Eo '<p>Jawab.*'|sed 's/<p>*//g'|cut -d '<' -f 1)
	}

	public __kuis__::Game(){
		# komponen display
		# ===================================
		function Draw(){ let lebar=$(tput cols); let panjang=$(tput lines);tput smcup; }
		function rmDraw(){ tput rmcup; }
		function score(){ printf "\e[3;0HScore   : ${score}\n"; }
		function User(){ printf "\e[4;0HUser    : $(whoami)\n"; }
		function page(){ printf "\e[5;0HRound   : ${round}\tSoal   : ${total_soal}\n"; }
		function animasi(){ { var frame:1 = "X"; var frame:2 = "√"; let xframe=0; }
					for x in $(seq 0 10); do
						let xframe++
						((xframe == 1)) && { var dframe = $(@return: [frame:1]); }
						((xframe == 2)) && { var dframe = $(@return: [frame:2]); let xframe=0; }
						if test "$x" == 10; then
							var dframe = "$2"
						fi
						tput sc
						printf "[?] Mencocokan hasil [$1] -> ${dframe}"
						tput rc
						sleep 0.1
					done
		}; __kuis__::Parse && { true; }||{ __kuis__::Parse; }
		# --------------------------------------------
		local jawaban=$(
			__validate__=$(echo "$jawaban"|sed 's/Jawab:[[:space:]]//g')
			#if (@return: [::validate::]|grep -o "([a-z0-9A-Z]*)" &> /dev/null); then
			__out__=$(@return: [::validate::]|sed 's/[[:space:]](.*)//g')
			@return: [::out::]
		)
		let total_soal=$(wc -l <<< "$soal")

		let page=(total_soal)

		while true; do
			tput clear
			Draw
			var string:1 = "Author : Bayu Rizky A.M"
			var string:2 = "Cak Lontong Kuis"
			# ------------------------------------------
			tput cup 26 $(($((lebar / 2)) - $((${#string_1} / 2))))
			printf "\e[K\e[1;37;100m${string_1}\e[0m\n"
			hr "-" $(tput cols)
			tput cup 0 $(( $((lebar / 2)) - $((${#string_2} / 2))))
			printf "\e[K\e[1;30;107m${string_2}\e[0m\n"
			printf "\e[2;0H"
			hr "-" $(tput cols)
			score
			User
			page
			hr "-" $(tput cols)
			printf "\e[14;0H"
			str_pertanyaan="pertanyaan: $(@return: [soal]|tail +$round|head -1|cut -d '.' -f 2)"
			say.Echo "$str_pertanyaan"
			read -p "Jawaban: " int

			# Yntkts

			if [[ "$(@return: [int]|tr A-Z a-z)" == "$(@return: [jawaban]|tail +${round}|head -1|tr A-Z a-z)" ]]; then
				var set_opsi = "benar √"
				((score = score + 10))
			else
				var set_opsi = "Salah X"
				if ((score == 0)); then true
				else ((score = score - 10)); fi
			fi; tput clear

			tput cup $((panjang / 2)) $((lebar / 2 - 25))
			animasi "$int" "$set_opsi"
			Answer="Jawaban nya: $(@return: [jawaban]|tail +${round}|head -1)"
			tput cup $((panjang / 2 + 2)) $(($((lebar / 2)) - $((${#Answer} / 2))))
			say.Echo "$Answer"
			tput cup $((panjang / 2 + 3)) $((lebar / 2))
			read -p "[Enter]"
			let round++

			if ((round == total_soal)); then
				var string:display:1 = "Soal Telah Terselesaikan"
				var string:display:2 = "Total point: ${score}"
				var string:display:3 = "Mulai Lagi (y/n) : "
				tput clear
				tput cup $((panjang / 2)) $(($((lebar / 2)) - $((${#string_display_1} / 2))))
				@return: [string:display:1]
				tput cup $((panjang / 2 + 1)) $(($((lebar / 2)) - $((${#string_display_2} / 2))))
				@return: [string:display:2]
				tput cup $((panjang / 2 + 2)) $(($((lebar / 2)) - $((${#string_display_3} / 2))))
				io.write "$(@return: [string:display:3]) "; read choice

				if [[ "$choice" =~ (y|Y)$ ]]; then
					rmDraw
					let score=0
					let round=1
					__kuis__::Game
				else
					rmDraw
					exit $?
				fi
			fi
		done
			
	}
}


trap "tput rmcup sgr0; exit" INT SIGINT
trap "true;stty sane;shopt -s checkwinsize; let panjang=$(tput lines); let lebar=$(tput cols)" WINCH

const: __kuis__ =\> kuis

# gas
{ exec 7< <(cat <<< "kuis.Game \\(True\\)"); };{ flock -u 7; }
eval $(cat <&7)
