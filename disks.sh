#!/bin/bash
set -e

declare -A disks_infos

function get_info() {
	local IFS=':'
	data=$(cat b)
	rm b
	for line in $data; do
		local IFS=' \\t'
		read typ siz <<< "$line"
		if [[ ! -z "${typ// }"  ]]; then
			if [[ $typ == "ATA" ]]; then
				echo "SATA $siz" >> disks.txt
			else
				echo "$typ $siz" >> disks.txt

			fi
		fi

	done
}

function gen_file() {
	local IFS=$'\n'  # IFS : only new line (instead of \n \t and ' ')
	
	data=$(lshw -class disk -class storage)
	for line in $data; do
		if [[ "$line" == *"description:"* ]]; then
			if [[ "$line" != *"SATA"* ]]; then
				echo $line | awk '{print $2}' >> a
			fi
		elif [[ "$line" == *"size:"* ]];then
			echo $line | awk '{print $2}' >> a
			echo ' : ' >> a
		fi
	done
	cat a | tr '\n' ' ' > b
	rm a
}

gen_file
get_info
