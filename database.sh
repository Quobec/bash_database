#!/bin/bash

create(){
	id_index=$(grep '^id_index=' "$table_data_file" | cut -d'=' -f2 | tr -d '[:space:]')
	accepted='n'
	while [ $accepted != 'y' ]; do
	
	echo 'Input parameters.'
	
	read -p "Name: " name
	read -p "Surname: " surname
	read -p "Address: " address
	read -p "Phone number: " phone_number
	read -p "PESEL: " pesel

	clear

	echo "Confirm creation.(y/n)"

	# There was a big problem here with conversion of id_index to integer, because I left a newline in users_data.txt
	# Update: I need to rememmber to put id_index at the bottom
	id=$(expr $id_index + 1)
	echo "ID: ${id}"
	echo "Name: ${name}" 
	echo "Surname: ${surname}" 
	echo "Address: ${address}" 
	echo "Phone number: ${phone_number}" 
	echo "PESEL: ${pesel}"

	read accepted
	clear

	done

	echo "Confirmed. Creating record..."
	id=$(expr $id_index + 1)
	echo "ID: ${id}"
	echo "Name: ${name}" 
	echo "Surname: ${surname}" 
	echo "Address: ${address}" 
	echo "Phone number: ${phone_number}" 
	echo "PESEL: ${pesel}" 
	sleep 1

	# Validate
	while IFS= read -r line; do
		if [[ "$line" =~ ^validate:: ]]; then
			field=$(echo "$line" | cut -d':' -f3)
			rules=$(echo "$line" | cut -d':' -f4-)
			IFS=',' read -r -a rules_array <<< "$rules"

			for rule in "${rules_array[@]}"; do
				rule_name="${rule%%:*}"
				rule_argument="${rule#*:}"

				if [[ "$rule" == "$rule_name" ]]; then
					rule_argument="None"
				fi

				
				error=$(bash ./validation_rules/${rule_name}.sh "${table_name}" "$rule_argument" "$field" "${!field}")
				if [[ "$error" != "None" ]]; then
					break 2
				fi
			done
		fi
	done < "$table_data_file"

	# Problem with comparing to an empty string, so i pur "None" instead
	# Check if error is "None"
	if [[ "$error" == "None" ]]; then
		# Update id_index
		id_index_line=$(grep '^id_index=' "$table_data_file")
		id_index=$(echo "$id_index_line" | cut -d'=' -f2)
		new_value=$((id_index + 1))
		sed -i "s/^id_index=[0-9]*/id_index=$new_value/" "$table_data_file"

		# Create new record
		echo "|id:${id}|name:${name}|surname:${surname}|adress:${adress}|phone_number:${phone_number}|pesel:${pesel}|" >> "$table_records_file"
	else
		echo "$error"
		sleep 5
	fi

	# clear
}

table_name="users"
table_data_file="./tables/${table_name}_data.txt"
table_records_file="./tables/${table_name}.txt"
id_index=$(grep '^id_index=' "$table_data_file" | cut -d'=' -f2)

choosen_action='sh'
actions=('exit' 'create' 'read' 'delete' 'sh')
actions_descs=('Exit the database.' 'Create a new record.'  'Find and read a record by id.' 'Delete a record by id.' 'Says hello')

while [ $choosen_action != 'exit' ]; do
	echo 'Choose an action'

	actions_count=${#actions[@]}
	for ((i = 0; i < actions_count; i++)); do
		echo "$((i + 1)): ${actions[i]} - ${actions_descs[i]}"
	done

	read choosen_action
	
	clear

	case "$choosen_action" in
		create)
			create
			;;
		sh)
			echo 'Hello there!'
			;;
		exit)
			echo 'Exiting...'
			exit 0
			;;
		*)
			echo 'Incorrect action choosen. Please choose one of the following.'
			;;
	esac

done

