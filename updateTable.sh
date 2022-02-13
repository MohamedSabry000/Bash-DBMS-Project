#!/bin/bash
DBName=$1
function updateTable {
    PS3="[ $DBName ]: "
    read -p "Enter Table Name: " name
    if ! [[ -f ./$name ]]
    then
        echo "Table Doesn't Exist!";
        updateOrExit;
    else
        PS3="[ $DBName > $name ]: "
        validateQuery $name;
    fi
}
function updateOrExit {
    PS3="Please Enter a Choice: "
    select choice in "Try Again" "Exit"
    do
        case $REPLY in
        1) updateTable;;
        2) clear; ../../tables.sh $DBName;;
        *) updateOrExit;;
        esac
    done
}

function validateQuery {
    PS3="[ $DBName > $1 ]: "
    tableName=$1

    column -t -s ":" $tableName;

    colNames=`awk -F : '{if(NR != 1) print $1}' .$tableName `

    clear
    PrintInCenter "==> Update $tableName Set ...... = ..... Where ..... = ..... <<=="
    echo $colNames|tr '\n' '\t'
    PrintInCenter "-----------------------------"

    read -p "Enter the column name of what you want to update: " colName
    read -p "Enter the column value of what you want to update: " colValue
    read -p "Enter the based column name of what you want to update: " basedColName
    read -p "Enter the based column value of what you want to update: " basedColValue

    clear
    PrintInCenter "==> Update $tableName Set $colName = $colValue Where $basedColName = $basedColValue <<=="
    echo $colNames|tr '\n' '\t'
    PrintInCenter "-----------------------------"

    # ($colNames) => for converting from data string into array 
    colNamesArray=($colNames)

    
    if ! [[ ${colNamesArray[*]} =~ $colName ]]
    then
        echo "Column Name Doesn't Exist!";
        enterQueryOrExit $tableName
    elif ! [[ ${colNamesArray[*]} =~ $basedColName ]]
    then
        echo "Based Column Name Doesn't Exist!";
        enterQueryOrExit $tableName
    else
        
        # Get the index of the based column from description file
        basedColIndex=`awk -F : '{if( NR != 1 && $1 == "'$basedColName'" ) print (( NR - 1 ))}' .$tableName`
        i="\$$basedColIndex";
        data=`awk -F : '{if(NR != 1) print '$i'}' $tableName | grep -Fqs $basedColValue && echo $?`
        # grep -F => Interpret PATTERN as a list of fixed strings, separated by newlines, any of which is to be matched.
        # grep -q => Quiet; do not write anything to standard output. Exit immediately with zero status if any match is found, even if an error was detected.
        # grep -s => --no-messages for not showing error messages.

        # Check Existance of the value of the Based Table
        if [[ $data != '0' ]]   # data is not exist => 0 means true, 1 means false
        then
            echo "There is no rows in [$basedColName] with value of [ $basedColValue ]!";
            enterQueryOrExit $tableName
        fi

        # Get the target column data from description file
        targetColDesc=`awk -F : '{if( NR != 1 && $1 == "'$colName'" ) print $0}' .$tableName`
    
        col_type=`echo $targetColDesc | awk -F : '{print $2}'`
        col_PK=`echo $targetColDesc | awk -F : '{print $3}'`

        # Check Target Col Type
        if [[ $col_type == "int" ]]
        then
            if ! [ $colValue -eq $colValue 2>/dev/null ]
            then 
                echo "Please Enter an Integer Value!";
                enterQueryOrExit $tableName
            fi                
        fi

        # Check Targe Col Primary Key

        # Get the index of the column from description file
        targetColIndex=`awk -F : '{if( NR != 1 && $1 == "'$colName'" ) print (( NR - 1 ))}' .$tableName`

        if [[ $col_PK == "T" ]]
        then
            
            i="\$$targetColIndex";
            data=`awk -F : 'BEGIN{OFS="\n";} {if(NR != 1) print '$i'}' $tableName | grep -Fqs $colValue && echo $?`
            # grep -F => Interpret PATTERN as a list of fixed strings, separated by newlines, any of which is to be matched.
            # grep -q => Quiet; do not write anything to standard output. Exit immediately with zero status if any match is found, even if an error was detected.
            # grep -s => --no-messages for not showing error messages.

            if [[ $data == '0' ]]
            then
                echo "The Target Column is a Primary key, and your new value is exists before!";
                enterQueryOrExit $tableName
            fi
        fi

        usedBasedColIndex="\$$basedColIndex";
        usedTargetColIndex="\$$targetColIndex";

        # Update usin substitute => awk -> file called 'updated-$tableName', then remove table; rename table name from 'updated-$table name' to 'table name'
        awk -F : -v OFS=":" '{
            if(NR != 1 && '$usedBasedColIndex' == "'$basedColValue'") {'$usedTargetColIndex'="'$colValue'";}
            print;
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

updateTable $1