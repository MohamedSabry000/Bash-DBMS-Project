#!/bin/bash
DBName=$1
function deleteFromTable {
    PS3="[ $DBName ]: "
    read -p "Enter Table Name: " name
    if ! [[ -f ./$name ]]
    then
        echo "Table Doesn't Exist!";
        deleteOrExit;
    else
        PS3="[ $DBName > $name ]: "
        validateQuery $name;
    fi
}
function deleteOrExit {
    PS3="Please Enter a Choice: "
    select choice in "Try Again" "Exit"
    do
        case $REPLY in
        1) deleteFromTable;;
        2) clear; ../../tables.sh $DBName;;
        *) deleteOrExit;;
        esac
    done
}

function validateQuery {
    PS3="[ $DBName > $1 ]: "
    tableName=$1
    colNames=`awk -F : '{if(NR != 1) print $1}' .$tableName `

    clear
    PrintInCenter "==> DELETE From $tableName Where ..... = ..... <<=="
    echo $colNames|tr '\n' '\t'
    PrintInCenter "-----------------------------"

    read -p "Enter the column name of what you want to delete: " colName
    read -p "Enter the column value of what you want to delete: " colValue
    
    clear
    PrintInCenter "==> DELETE From $tableName Where $colName = $colValue <<=="
    echo $colNames|tr '\n' '\t'
    PrintInCenter "-----------------------------"

    # ($colNames) => for converting from data string into array 
    colNamesArray=($colNames)

    
    if ! [[ ${colNamesArray[*]} =~ $colName ]]
    then
        echo "Column Name Doesn't Exist!";
        enterQueryOrExit $tableName
    else

        # Get the index of the column from description file
        targetColIndex=`awk -F : '{if( NR != 1 && $1 == "'$colName'" ) print (( NR - 1 ))}' .$tableName`

        # Check the index of the column name is exists and there is actual integer index
        if [[ $targetColIndex == "" ]]
        then
            echo "Column Name Doesn't Exist!";
            enterQueryOrExit $tableName
        fi

        index="\$$targetColIndex";
        data=`awk -F : 'BEGIN{OFS="\n";} {if(NR != 1) print '$index'}' $tableName | grep -Fqs $colValue && echo $?`
        # grep -F => Interpret PATTERN as a list of fixed strings, separated by newlines, any of which is to be matched.
        # grep -q => Quiet; do not write anything to standard output. Exit immediately with zero status if any match is found, even if an error was detected.
        # grep -s => --no-messages for not showing error messages.

        if ! [[ $data == '0' ]]
        then
            echo "There is no Value called [ $colValue ] in Column [ $colName ] !";
            enterQueryOrExit $tableName
        fi
        
        # Update usin substitute => awk -> file called 'updated-$tableName', then remove table; rename table name from 'updated-$table name' to 'table name'
        awk -F : '{
            if('$index' != "'$colValue'") print $0;
        }' $tableName > "updated-$tableName";
        rm $tableName;
        mv "updated-$tableName" $tableName;

        clear; 
        ../../tables.sh $DBName;
    fi
}
function enterQueryOrExit {
    PS3="Please Enter a Choice: "
    select choice in "Try Again" "Exit"
    do
        case $REPLY in
        1) validateQuery $1;;
        2) clear; ../../tables.sh $DBName;;
        *) enterQueryOrExit;;
        esac
    done
}

#       General Functions
function PrintInCenter {
    # tput uses the terminfo database to make the values of terminal-dependent capabilities and information  available  to  the  shell
    COLUMNS=$(tput cols) # tput cols => Print the number of columns for the current terminal.
    text="$*" 
    # printf is used for format and print data.
    # (*) used to pass the width specifier/precision to printf rather than hard coding it into the format string
    printf "\n%*s\n" $(((${#text}+$COLUMNS)/2)) "$text"
}

deleteFromTable $1