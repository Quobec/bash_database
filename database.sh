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

		#had to add cross compatibility
		if [[ "$OSTYPE" == "darwin"* ]]; then
			sed -i '' "s/^id_index=[0-9]*/id_index=$new_value/" "$table_data_file"
		else
			sed -i "s/^id_index=[0-9]*/id_index=$new_value/" "$table_data_file"
		fi

		# Create new record
		echo "|id:${id}|name:${name}|surname:${surname}|adress:${adress}|phone_number:${phone_number}|pesel:${pesel}|" >> "$table_records_file"
	else
		echo "$error"
		sleep 5
	fi

	# clear
}

# When I named function read, it looped
find(){
    echo "Search by: (id/name/surname/adress/phone_number/pesel)"
    read search_by
    echo "equal to:"
    read search_value

	fields=("id" "name" "surname" "adress" "phone_number" "pesel")
	valid_field=false
	for field in "${fields[@]}"; do
		if [[ "$field" == "$search_by" ]]; then
			valid_field=true
			break
		fi
	done

	if $valid_field; then
		if [ -n "$search_value" ]; then
			record=$(grep "|${search_by}:${search_value}|" "$table_records_file")
			if [ -n "$record" ]; then
				clear
				id=$(echo "$record" | sed -n 's/.*|id:\([^|]*\).*/\1/p')
				name=$(echo "$record" | sed -n 's/.*|name:\([^|]*\).*/\1/p')
				surname=$(echo "$record" | sed -n 's/.*|surname:\([^|]*\).*/\1/p')
				adress=$(echo "$record" | sed -n 's/.*|adress:\([^|]*\).*/\1/p')
				phone_number=$(echo "$record" | sed -n 's/.*|phone_number:\([^|]*\).*/\1/p')
				pesel=$(echo "$record" | sed -n 's/.*|pesel:\([^|]*\).*/\1/p')

				echo "ID: ${id}"
				echo "Name: ${name}" 
				echo "Surname: ${surname}" 
				echo "Address: ${address}" 
				echo "Phone number: ${phone_number}" 
				echo "PESEL: ${pesel}" 
			else
				clear
				echo "No record found with $search_by:$search_value"
			fi
		else
			cat $table_records_file
		fi
	else
		echo "Invalid field"
	fi

	echo "--------------------"
}

delete() {
    echo "Input ID to search and remove:"
    read search
    if [ -z "$search" ]; then
        echo "ID cannot be empty."
        return
    fi

    line=$(grep "|id:$search|" "$table_records_file")
    if [ -n "$line" ]; then
        echo "Are you sure you want to delete the following record? (y/n)"
        echo "$line"
        read accept
        
        if [ "$accept" = "y" ]; then 
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "/|id:$search|/d" "$table_records_file"
            else
                sed -i "/|id:$search|/d" "$table_records_file"
            fi
            echo "Record with id:$search has been removed."
        else
            echo "Action canceled."
        fi
    else
        echo "No record found with id:$search."
    fi
}

table_name="users"
table_data_file="./tables/${table_name}_data.txt"
table_records_file="./tables/${table_name}.txt"
id_index=$(grep '^id_index=' "$table_data_file" | cut -d'=' -f2)

choosen_action='sh'
actions=('exit' 'create' 'read' 'delete' 'sh')
actions_shortcuts=('e' 'c' 'r' 'd' 's')
actions_descs=('Exit the database.' 'Create a new record.'  'Find and read a record by id.' 'Delete a record by id.' 'Says hello')

while [ $choosen_action != 'exit' ]; do
	echo 'Choose an action'

	actions_count=${#actions[@]}
	for ((i = 0; i < actions_count; i++)); do
		echo "$((i + 1)): ${actions[i]} - ${actions_shortcuts[i]} - ${actions_descs[i]}"
	done

	read choosen_action
	
	clear

	case "$choosen_action" in
		create)
			create
			;;
		c)
			create
			;;
		read)
			find
			;;
		r)
			find
			;;
		delete)
			delete
			;;
		d)
			delete
			;;
		sh)
			echo 'Hello there!'
			;;
		s)
			echo 'Hello there!'
			;;
		exit)
			echo 'Exiting...'
			exit 0
			;;
		e)
			echo 'Exiting...'
			exit 0
			;;
		*)
			echo 'Incorrect action choosen. Please choose one of the following.'
			;;
	esac

done

