#!/bin/bash
DBName=$1
function InsertTable {
    PS3="[ $DBName ]: "
    read -p "Enter Table Name: " name
    if ! [[ -f ./$name ]]
    then
        echo "Table Doesn't Exist!";
        insertOrExit;
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
    colNames=`awk -F : '{if(NR != 1) print $1}' .$tableName | sed -z 's/\n/, /g;s/, $/ /'`
    # -z separate lines by NUL characters
    colvalues=`awk -F : '{if(NR != 1) print "..... ,"}' .$tableName  | sed -z 's/\n/ /g;s/, $//'`
    numOfCols=`awk -F : '{if(NR != 1) print "..... ,"}' .$tableName  | wc -l`

    query="INSERT INTO $tableName ( $colNames)VALUES ( $colvalues)"
    PrintInCenter $query;
    PrintInCenter "-----------------------------"

    awk -F : '{
        if(NR != 1) {
            read -p 
        }
    }' .$tableName
    line=''
    index=1
    for typ in `awk '{if(NR != 1) print $0}' .$tableName`
    do
    echo $typ
        col_Name=`echo $typ | awk -F : '{print $1}'`
        col_type=`echo $typ | awk -F : '{print $2}'`
        col_PK=`echo $typ | awk -F : '{print $3}'`

        if [[ $col_type == "int" ]]
        then
            # Enter Integer Number
            if [[ $col_PK == "T" ]]
            then
                while : ;
                do
                    num="fake data"
                    while ! [ $num -eq $num 2>/dev/null ]
                    do
                        read -p "Enter a Valid Integer Number: " num
                    done

                    i="\$$index";
                    data=`awk -F : 'BEGIN{OFS="\n";} {if(NR != 1) print '$i'}' $tableName | grep -Fqs $num && echo $?`
                    # grep -F => Interpret PATTERN as a list of fixed strings, separated by newlines, any of which is to be matched.
                    # grep -q => Quiet; do not write anything to standard output. Exit immediately with zero status if any match is found, even if an error was detected.
                    # grep -s => --no-messages for not showing error messages.

                    if [[ $data == '0' ]]
                    then
                        echo "Data is Duplicated on a Primary Column!"
                    else
                        # append value to [line] variable
                        if [ $index -eq 1 ]
                        then
                            line="$num"
                        else
                            line="$line:$num"
                        fi
                        break;
                    fi
                done
            else
                num="fake data"
                while ! [ $num -eq $num 2>/dev/null ]
                do
                    read -p "Enter an Integer Number: " num
                done
                # append value to [line] variable
                if [ $index -eq 1 ]
                then
                    line="$num"
                else
                    line="$line:$num"
                fi
            fi
            
        else
            # Enter Integer Number
            if [[ $col_PK == "T" ]]
            then
                while : ;
                do
                    read -p "Enter a String: " str
                    i="\$$index";
                    data=`awk -F : 'BEGIN{OFS="\n";} {if(NR != 1) print '$i'}' $tableName | grep -Fqs $num && echo $?`
                    # grep -F => Interpret PATTERN as a list of fixed strings, separated by newlines, any of which is to be matched.
                    # grep -q => Quiet; do not write anything to standard output. Exit immediately with zero status if any match is found, even if an error was detected.
                    # grep -s => --no-messages for not showing error messages.

                    if [[ $data == '0' ]]
                    then
                        echo "Data is Duplicated on a Primary Column!"
                    else
                        # append value to [line] variable
                        if [ $index -eq 1 ]
                        then
                            line="$num"
                        else
                            line="$line:$num"
                        fi
                        break;
                    fi
                done

            else
                read -p "Enter a String: " str
                # append value to [line] variable
                if [ $index -eq 1 ]
                then
                    line="$str"
                else
                    line="$line:$str"
                fi
            fi
        fi
        index=$(( $index + 1 ))
    done
    echo $line >> $tableName;
    clear; 
    ../../tables.sh $DBName;
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

InsertTable $1