#!/bin/bash
PS3="[ $1 ]: "
databaseName=$1
function showList {
    PS3="[ $1 ]: "
    echo  +-----------------------Enter Your Action-----------------------+
    select i in "Show All Tables"   \
                "Create New Table"  \
                "Insert Into Table" \
                "Select From Table" \
                "Update Table"      \
                "Delete From Table" \
                "Drop Table"        \
                "Exit"              \
                "Back To Main Menu"
    do 
        case $REPLY in
        1) ShowTables $1;   showList $1;;
        2) CreateTable $1; ShowTables $1;;
        3) ../../insertIntoTable.sh $1;;
        4) ../../selectFromTable.sh $1;;
        5) ../../updateTable.sh $1;;
        6) ../../deleteFromTable.sh $1;;
        7) ../../dropTable.sh $1;;
        8) exit;;
        9) clear; cd ../../; ./DBMS.sh; break;;
        *) echo -e "=========> Wrong Choice <==========";;
        esac
    done
}

function ShowTables {
    clear
    tablescount=$(find . -maxdepth 1 -type f -not -path './.*' | wc -l)
    if [ $tablescount -gt 0 ]
    then 
        echo "Available Tables are:"
        find . -maxdepth 1 -type f -not -path './.*' | cut -f2 -d '/' | tr '\n' '\t'      # tr used to make the output horizontally with replacing \n with \t, ignoring hidden files
        PrintInCenter "============================"
    else PrintInCenter "==>> There is no Tables yet! <<=="; 
    fi
}

function CreateTable {
    read -p "Enter Table Name: " name
    if [[ -f ./$name ]]
    then
        echo "Table Already Exists!";
        createOrExit $1;
    elif ! [[ $name =~ ^[a-zA-Z]*$ ]]
    then
        echo "Table must start with Alphabitic!"
        createOrExit $1
    else
        verifiedTableName $name;
    fi
}
function createOrExit {
    PS3="Please Enter a Choice: "
    select choice in "Try Again" "Exit"
    do
        case $REPLY in
        1) CreateTable $1;;
        2) clear; ShowTables $1;;
        *) createOrExit $1;;
        esac
    done
}
function verifiedTableName {
    #------------ metadata temp file --------
    # create Temp file for saving metadata, if anything wrong happened, i didn't create the actual table file yet!
    if [[ -f .tmp ]]; then echo "$1" > .tmp; ## make file empty then Add the Table Name 
    else touch .tmp; echo "$1" > .tmp;
    fi
    tableName=$1
    #----------- Actual temp file -----------
    # create Temp file for saving the Actual Data, if anything wrong happened, i didn't create the actual table file yet!
    if [[ -f .tmp2 ]]; then echo "" > .tmp2; ## make file empty
    else touch .tmp2;
    fi

    read -p "Enter Column Number: " cols
    # it checks for an integer, if it doesn't find an int it returns both an error which you can toss to /dev/null and a value of false.
    if [[ $cols ]] && [ $cols -eq $cols 2>/dev/null ]
    then
        columnSeparator=":"
        rowSeparator="\n"
        pkFlag=0
        lineOfCols=''
        for (( index=1; index<=$cols; index++))
        do
            type=""
            pk="F"  # default of all columns are not primary key
            read -p "Enter the $index Column Name starts with Alphabit: " colName;
            # verify the name starts with a char
            if [ "$colName" == "" ] || ! [[ "${colName?}" =~ ^[a-zA-Z]*$ ]]
            then
                echo -e "Please Enter a Name starts with Alphabit Character. Try Again.\n"
                ((index -= 1));
                continue;
            fi
            PS3="[ $databaseName > $colName ]: "
            ## Determine Type
            echo "Type is: "
            select ty in "int" "string"
            do
                case $REPLY in
                1) type="int"; break;;
                2) type="str"; break;;
                *);;
                esac
            done
            ## Dtermine Primary Key if Exists
            if [ $pkFlag -eq 0 ]
            then
                echo "Is this the Prymary key? "
                select key in "yes" "No"
                do
                    case $REPLY in
                    1) pk="T"; pkFlag=1; break;;
                    2) break;;
                    *);;
                    esac
                done
            fi
            # Append to metadata temp file [name:str:F] [id:int:T]
            echo -e "$colName$columnSeparator$type$columnSeparator$pk" >> .tmp
            # Append to Actual data temp file [name:id]
            if [ "$index" -eq 1 ]; then lineOfCols="$colName";
            else lineOfCols="$lineOfCols:$colName";
            fi
        done
        # past columns in .tmp2
        echo -e "$lineOfCols$rowSeparator" > .tmp2;
        # Change the Name of the table to the actual table name
        echo "Save or Back without Saving?"
        select choice in "Save" "Back without Saving"
        do
            case $REPLY in
            1) mv .tmp .$tableName; mv .tmp2 $tableName; break;;
            2) rm .tmp .tmp2; ShowTables $databaseName; break;;
            *);;
            esac
        done
        PS3="[ $databaseName ]: "
        showList $databaseName
    else
        continueColStepOrExit $tableName
    fi
    
}
function continueColStepOrExit {
    PS3="Please Enter a Choice: "
    select choice in "Try Again" "Exit"
    do
        case $REPLY in
        1) verifiedTableName $1;;
        2) clear; ShowTables $1;;
        *) continueColStepOrExit $1;;
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

showList $1