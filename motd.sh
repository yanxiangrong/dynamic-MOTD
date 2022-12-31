#!/bin/bash

#########################################
#
#		VARIABLES
#
#########################################

distro=$(cat /etc/*release | grep "PRETTY_NAME" | cut -d "=" -f 2- | sed 's/"//g')
# Kernel information
kernel=$(uname -sr)

# Uptime
uptime=$(uptime -p | sed 's/up //;s/,//g')

# Numbers of packages installed
packages=$(pacman -Q | wc -l)

date=$(date +"%x %T %Z(%:::z)")
# head="System information as of: $date"

#Cpu load
load=($(cat /proc/loadavg | awk '{print $1,$2,$3}'))

hostname=$(cat /etc/hostname)

#Processes
PROCESS=`ps -eo user=|sort|uniq -c | awk '{ print $2 " " $1 }'`
processes=`echo "$PROCESS"| awk {'print $2'} | awk '{ SUM += $1} END { print SUM }'`

cpu=`cat /proc/cpuinfo | grep "name" | uniq | cut -d ":" -f2 | sed 's/ //;s/(TM)//g;s/(R)//g;s/CPU//;s/  / /'`

## Colors
bold="\033[1;1m"
black="\033[0;30m"
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"
magenta="\033[0;35m"
cyan="\033[0;36m"
white="\033[0;37m"
hblack="\033[1;30m"
hred="\033[1;31m"
hgreen="\033[1;32m"
hyellow="\033[1;33m"
hblue="\033[1;34m"
hmagenta="\033[1;35m"
hcyan="\033[1;36m"
hwhite="\033[1;37m"
reset="\033[0m"


c0="${bold}${cyan}"		# logo + text 1 color
c1="${bold}${white}"		# text 2 color
ce="${reset}"

## Filesystem
# Number of '-' to be displayed on the filesystem occupation
number=40

#########################################
#
#		FUNCTIONS
#
#########################################

# Displays a progression bar of the FS depending on the available space and the total space
# $PARAM1 = percentage used
bar () {
	temp1="${1%?}"			# Remove last character
	temp2="$((${temp1}*${number}/100))"	# Number of #

	str="${hwhite}["				# Initiate

	# Add a color to the output
	if ((${temp1} > 75)); then
		str+="${red}"
	elif ((${temp1} > 50)); then
		str+="${yellow}"
    else
		str+="${green}"
	fi

	# Fill with '#'
	for i in $(seq 1 ${temp2})
	do
		str+="="
	done

    str+="${hblack}"

	# Fill with '-'
	for i in $(seq ${temp2} ${number})
	do
		str+="-"
	done

    # reset the color
	str+="${hwhite}"
	str+="]"
    str+="${reset}"
	printf "${str}"
}





## Memory

while IFS=":" read -r a b; do
	case "${a}" in
    	"MemTotal") ((mem_used+=${b/kB})); mem_total=${b/kB} ;;
		"MemFree" | "Buffers" | "Cached" | "SReclaimable")
			((mem_used-=${b/kB}))
		;;
        "SwapTotal") swap_total=${b/kB};;
        "SwapFree") swap_used=${swap_total}-${b/kB};;
	esac
done < /proc/meminfo


mem_used="$((mem_used / 1024))"
mem_total="$((mem_total / 1024))"

mem_perc="$((mem_used * 100 / mem_total))"

mem_used=$(awk '{printf "%.2f", $1 / $2}' <<< "${mem_used} 1024")
mem_total=$(awk '{printf "%.2f", $1 / $2}' <<< "${mem_total} 1024")
mem_label=GiB

memory="${hcyan}${mem_used}${mem_label} ${hwhite}/ ${blue}${mem_total}${mem_label} ${hwhite}(${mem_perc}%%)"
memory_bar="$(bar "${mem_perc}%")"

swap_used="$((swap_used / 1024))"
swap_total="$((swap_total / 1024))"

swap_perc="$((swap_used * 100 / swap_total))"

swap_used=$(awk '{printf "%.2f", $1 / $2}' <<< "${swap_used} 1024")
swap_total=$(awk '{printf "%.2f", $1 / $2}' <<< "${swap_total} 1024")
swap_label=GiB

swap="${hcyan}${swap_used}${swap_label} ${hwhite}/ ${blue}${swap_total}${swap_label} ${hwhite}(${swap_perc}%%)"
swap_bar="$(bar "${swap_perc}%")"

echo -e "Welcome to $distro."
echo -e "          \033[1;36m. "
echo -e "         \033[1;36m/#\       \033[1;37m                  _     \033[1;36m _ _"
echo -e "        \033[1;36m/###\      \033[1;37m                 | |    \033[1;36m| (_)"
echo -e "       \033[1;36m/p^###\     \033[1;37m _____  ____ ____| |__  \033[1;36m| |_ _ __  _   ___  __"
echo -e "      \033[1;36m/##P^q##\    \033[1;37m(____ |/ ___) ___)  _ \ \033[1;36m| | | '_ \| | | \ \/ /"
echo -e "     \033[1;36m/##(   )##\   \033[1;37m/ ___ | |  ( (___| | | |\033[1;36m| | | | | | |_| |>  < "
echo -e "    \033[1;36m/###P   q#,^\  \033[1;37m\_____|_|   \____)_| |_|\033[1;36m|_|_|_| |_|\__,_/_/\_\\"
echo -e "   \033[1;36m/P^         ^q\ "

printf $reset
printf "系统信息:\n"
printf "${c0}发行版  :${ce} ${hwhite}%-29s ${c0}内核版本:${ce} ${hwhite}${kernel}\n" "${distro}"
printf ""
printf "${c0}主机名  :${ce} ${hwhite}%-29s ${c0}处理器  :${ce} ${hwhite}${cpu}\n" "${hostname}"
printf "${c0}进程    :${ce} ${hcyan}%-29s ${c0}软件包  :${ce} ${hcyan}${packages}\n" "${processes}"
printf "${c0}开机时间:${ce} ${hcyan}%-29s ${c0}系统时间:${ce} ${hwhite}${date}\n" "${uptime}"
printf "${c0}平均负载:${ce} ${hwhite}${load[0]} ${hcyan}${load[1]} ${cyan}${load[2]}\n"
printf "${c0}内存    :${ce} ${memory} \t${memory_bar}\n"
printf "${c0}交换    :${ce} ${swap} \t${swap_bar}\n"

disk_label=iB
printf "磁盘使用:\n"
while read -r a b c d; do
    disk_bar="$(bar "${d}")"
	printf "${c0}%-16s${ce} ${hcyan}%s${disk_label} ${hwhite}/ ${blue}%s${disk_label} ${hwhite}(%s) \t$disk_bar\n" $a $c $b $d
done <<< "$(df -h | awk '/^\/dev/{print $6,$2,$3,$5}')"

printf "网络设备:\n"
ip -br -c addr show scope global

printf $reset
