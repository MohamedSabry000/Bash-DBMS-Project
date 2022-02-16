#!/bin/bash
DBName=$1
function selectFromTable {
    PS3="[ $DBName ]: "
    read -p "Enter Table Name: " name
    if ! [[ -f ./$name ]]
    then
        echo "Table Doesn't Exist!";
        selectOrExit;
    else
        PS3="[ $DBName > $name ]: "
        validateQuery $name;
    fi
}
function selectOrExit {
    PS3="Please Enter a Choice: "
    select choice in "Try Again" "Exit"
    do
        case $REPLY in
        1) selectFromTable;;
        2) clear; ../../tables.sh $DBName;;
        *) selectOrExit;;
        esac
    done
}

function validateQuery {
    PS3="[ $DBName > $1 ]: "
    tableName=$1
    colNames=`awk -F : '{if(NR != 1) print $1}' .$tableName `

    clear
    PrintInCenter "==> Select ..... From $tableName Where ..... = ..... <<=="
    echo $colNames|tr '\n' '\t'
    PrintInCenter "-----------------------------"

    read -p "Enter the column name of what you want to select: " targetColName
    read -p "Enter the column name of what you want to select: " colName
    read -p "Enter the column value of what you want to select: " colValue

    clear
    PrintInCenter "==> Select $targetColName From $tableName Where $colName = $colValue <<=="
    echo $colNames|tr '\n' '\t'
    PrintInCenter "-----------------------------"

    # ($colNames) => for converting from data string into array 
    colNamesArray=($colNames)

    
    if ! [[ ${colNamesArray[*]} =~ $targetColName ]] && [[ $targetColName != "*" ]]
    then
        echo "Column Name Doesn't Exist!";
        enterQueryOrExit $tableName
    elif ! [[ ${colNamesArray[*]} =~ $colName ]]
    then
        echo "Based Column Name Doesn't Exist!";
        enterQueryOrExit $tableName
    else
        
        # Get the index of the based column from description file
        basedColIndex=`awk -F : '{if( NR != 1 && $1 == "'$colName'" ) print (( NR - 1 ))}' .$tableName`

        # Check the index of the column name is exists and there is actual integer index
        if [[ $basedColIndex == "" ]]
        then
            echo "Based Column Name Doesn't Exist!!";
            enterQueryOrExit $tableName
        fi

        awkBasedColIndex="\$$basedColIndex";
        data=`awk -F : '{if(NR != 1) print '$awkBasedColIndex'}' $tableName | grep -Fqs $colValue && echo $?`
        # grep -F => Interpret PATTERN as a list of fixed strings, separated by newlines, any of which is to be matched.
        # grep -q => Quiet; do not write anything to standard output. Exit immediately with zero status if any match is found, even if an error was detected.
        # grep -s => --no-messages for not showing error messages.

        # Check Existance of the value of the Based Table
        if [[ $data != '0' ]]   # data is not exist => 0 means true, 1 means false
        then
            echo "There is no rows in [$colName] with value of [ $colValue ]!";
            enterQueryOrExit $tableName
        fi

        # Get the index of the based column from description file
        targetColIndex=`awk -F : '{if( NR != 1 && $1 == "'$targetColName'" ) print (( NR - 1 ))}' .$tableName`

        # Check the index of the column name is exists and there is actual integer index
        # if [[ $targetColIndex == "" ]]
        # then
        #     echo "Based Column Name Doesn't Exist!!!";
        #     enterQueryOrExit $tableName
        # fi

        awkTargetColIndex="\$$targetColIndex";
        # data=`awk -F : '{if(NR != 1) print '$awkTargetColIndex'}' $tableName | grep -Fqs $colValue && echo $?`
        

        # Get the target column data from description file
        # targetColDesc=`awk -F : '{if( NR != 1 && $1 == "'$targetColName'" ) print $0}' .$tableName`
    
        # col_type=`echo $targetColDesc | awk -F : '{print $2}'`
        # col_PK=`echo $targetColDesc | awk -F : '{print $3}'`

        # usedBasedColIndex="\$$basedColIndex";
        # usedTargetColIndex="\$$targetColIndex";

        # Update usin substitute => awk -> file called 'updated-$tableName', then remove table; rename table name from 'updated-$table name' to 'table name'
        if [[ $targetColName != "*" ]]
        then
            awk -F : '{
                if(NR != 1 && '$awkBasedColIndex' == "'$colValue'") print '$awkTargetColIndex'
            }' $tableName | column -t -s ":" ;
        else
            awk -F : '{
                if(NR != 1 && '$awkBasedColIndex' == "'$colValue'") print $0
            }' $tableName | column -t -s ":" ;
        fi

        # clear; 
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

selectFromTable $1