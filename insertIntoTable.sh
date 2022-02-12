#!/bin/bash
DBName=$1
function InsertTable {
    PS3="[ $DBName ]: "
    read -p "Enter Table Name: " name
    if ! [[ -f ./$name ]]
    then
        echo "Table Doesn't Exist!";
        InsertTable;
    else
        PS3="[ $DBName > $name ]: "
        insertIntoTable $name;
    fi
}
function insertOrExit {
    PS3="Please Enter a Choice: "
    select choice in "Try Again" "Exit"
    do
        case $REPLY in
        1) InsertTable;;
        2) clear; ../../tables.sh $DBName;;
        *) insertOrExit;;
        esac
    done
}

function insertIntoTable {
    tableName=$1
    desc=`awk`
}



InsertTable $1

function UpdateTable {
    PS3="[ $DBName ]: "
    read -p "Enter Table Name: " name
    if ! [[ -f ./$name ]]
    then
        echo "Table Doesn't Exist!";
        UpdateTable;
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
        1) UpdateTable;;
        2) clear; ../../tables.sh $DBName;;
        *) updateOrExit;;
        esac
    done
}

function validateQuery {
    PS3="[ $DBName ]: "
    tableName=$1
    clear
    colNames=`awk -F : '{if(NR != 1) print $1}' .$tableName `

    clear
    PrintInCenter "==> Update $tableName Set ...... = ..... Where ..... = ..... <<=="
    echo $colNames|tr '\n' '\t'
    PrintInCenter "-----------------------------"

    read -p "Enter the column name of what you want to update: " colName
    read -p "Enter the column value of what you want to update: " colValue
    read -p "Enter the based column name of what you want to update: " basedColName
    read -p "Enter the based column value of what you want to update: " basedColValue
    if ![ $colName in colNames]
    then
        echo "Column Name Doesn't Exist!";
        enterQueryOrExit $tableName
    elif ![ $basedColName in colNames]
        echo "Based Column Name Doesn't Exist!";
        enterQueryOrExit $tableName
    else
        colType=`awk -F : '{if($1=="$colName" && NR != 1) print $2}' .$tableName`    # serach in the describtion file for the type column($2) 
        basedColType=`awk -F : '{if($1=="$basedColName" && NR != 1) print $2}' .$tableName`    # serach in the describtion file for the type column($2) 

        if [[ $colType == "int" ] && ! [ $colValue -eq $colValue 2>/dev/null ]]     # Check it's a number
        then 
            echo "Enter an Integer Number, Please!"
            enterQueryOrExit $tableName
        fi

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
# ////////////////
function updateTheTable {
    tableName=$1
    clear
    colNames=`awk -F : '{if(NR != 1) print $1}' .$tableName `

    PrintInCenter "==> Update $name Set ...... = ..... Where ..... = ..... <<=="
    echo $colNames|tr '\n' '\t'
    PrintInCenter "-----------------------------"

    read -p "Enter the column name of what you want to update: " colName
    if ![ $colName in colNames]
    then 
        echo "Column Name Doesn't Exist!";
        updateTheTable;
    else
        clear
        PrintInCenter "==> Update $tableName Set $colName = ..... Where ..... = ..... <<=="
        echo $colNames|tr '\n' '\t'
        PrintInCenter "-----------------------------"
        read -p "Enter the based column name: " basedColName
        if ![ $basedColName in colNames]
        then 
            echo "Column Name Doesn't Exist!";
            updateTheTable;
        else
            clear
            PrintInCenter "==> Update $tableName Set $colName = ..... Where $basedColName = ..... <<=="
            PrintInCenter "-----------------------------"
            getValuesOfUpdate $tableName $colName $basedColName
        fi    
    fi    
}

function getValuesOfUpdate {
    tableName=$1
    colName=$2
    colType=`awk -F : '{if($1=="$colName" && NR != 1) print $2}' .$tableName`    # serach in the describtion file for the type column($2) 
    basedColName=$3
    basedColType=`awk -F : '{if($1=="$basedColName" && NR != 1) print $2}' .$tableName`    # serach in the describtion file for the type column($2) 
    read -p "Enter the based value: " basedValue

    if [$basedColType == "int"]
    then
        if ! [ $basedValue -eq $basedValue 2>/dev/null ]
        then echo "Enter an Integer Number, Please!"
             getValuesOfUpdate $tableName $colName $basedColName
        else 
            executeUpdate $tableName $colName $basedColName $value
        fi
    else
        executeUpdate $tableName $colName $basedColName $value
    fi
}
function executeUpdate {
    tableName=$1 
    colName=$2 
    basedColName=$3 
    value=$4
    awk -F : '{sub(/2019/,2020); print . "$tableName" }' > $tableName
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