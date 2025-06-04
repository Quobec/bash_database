# Simple bash database

Structure:
  - database.sh - Main exec script
  - folder "tables" - Here all tables (currently only one) are defined. Each table is defnied by two files "{table_name}.txt" and "{table_name}_data.txt".
     "{table_name}.txt" holds all the records of a table
     "{table_name}_data.txt" holds the structure of the table. Here id_index is defined to make sure id is unique and all validation rules are assigned to the fields
  - folder "validation_rules" - Here all validation rules are define. Each validation rule accepts 4 arguments which are:
    - table_name - name of the table
    - argument - some rule require additional argument eg. min:3 checks if value has at least 3 characters. Number of minimum characters is passed as #argument
    - column - column that is being checked
    - value - value that has to pass validation

  Each rule outputs an error variable. If validation has passed the error value is "None", otherwise error value is whatever the error is.
  
  Validation example:
   ./validation_rules/min.sh "users" "3" "name" "jj" -> "Field 'name' must have at least 3 characters."
   ./validation_rules/min.sh "users" "3" "name" "Jacob" -> "None"

   Example of validation defined in "{table_name}_data.txt":
   validate::pesel:unique,digits:11

Upon opening user is presented with 5 options:
 - exit
 - create
 - read
 - delete
 - sh
User can select any of these by typing its name or shortcut. Choosing an action fires the coresponsing function.

exit
  Exits the programme with code 0.

create
  Begins "insert" process. First user is asked to input all fields. Next field values are shown and user is asked to confirm creation. If refused user is sent back to inputing field values. 
  If accepted validation begins. "{table_name}_data.txt" is read line after line and checked for lines starting in "validate::". When found line is cut into nessesary data to run the validation rule.
  Example:
  validate::phone_number:digits:9,unique
  is cut into
  phone_number digits:9,unique
  phone_number is assigned to $field and the rest is cut into rule_names and rule_arguments by ",". In a for loop, each rule is triggerd. So here triggered are:
  ./validation_rules/unique.sh "users" "" "phone_number" "{{value of variable called phone_number}}"
  ./validation_rules/digits.sh "users" "9" "phone_number" "{{value of variable called phone_number}}"

  Rules output is read into $error and if $error is not "None", validation stops checking futher. This is 1. for optimalization and 2. as to not otherwrite an error. 
  In our example is phone_number wasn't unique, but it has 9 digits, without breaking digits rule would overwrite error to "None" and validation would pass despite not phone_number not being unique.

  After validation if $error is "None", id_index is read, and incremented in "{table_name}_data.txt". Next new record is inserted into "{table_name}.txt".

read
  User is prompted to input by what field they want to search the table and what value that field must be equal to.
  Next $search_by is checked to see if it is a valid field. If so "{table_name}.txt" is search for a line with string "|${search_by}:${search_value}|".
  If line is found it is displayed, if not "No record found with $search_by:$search_value" is displayed. If $search_value is an empty string the entire "{table_name}.txt" is read out.

delete
  User is prompted to input id of the record they want to delete. If the record is found is it displayed and user is prompted to confirm deletion.
  
  
  
  

  
  
