#!/bin/bash
DBName=$1
function dropTable {
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
function dropOrExit {
    PS3="Please Enter a Choice: "
    select choice in "Try Again" "Exit"
    do
        case $REPLY in
        1) dropTable;;
        2) clear; ../../tables.sh $DBName;;
        *) dropOrExit;;
        esac
    done
}

function validateQuery {
    PS3="[ $DBName > $1 ]: "
    tableName=$1

    echo "Are you sure? "
    select choice in "Yes" "No"
    do
        case $REPLY in
        1) rm .$tableName; 
           rm $tableName;
           clear; ../../tables.sh $DBName;;
        2) clear; ../../tables.sh $DBName;;
        *) validateQuery $tableName;;
        esac
    done
}

dropTable $1