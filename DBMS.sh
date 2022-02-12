#!/bin/bash
const_root="Databases"

# Create Database Folder, -p(parent) no error if existing, make parent directories as needed
mkdir -p ./$const_root;

#main function
function mainMenu {
    # PS stands for prompt statement
    PS3="Enter a Choice : "
    echo  +-----------------------Enter Your Choice-----------------------+
    select element in "Create Database" "List Databas" "Drop Database" "Connect to Database" "Exit"
    do 
        case $REPLY in 
            "") echo "hello"; break;;
            1) createDB; mainMenu;;       # Create new database
            2) listDBs;  mainMenu;;	    # List databases
            3) dropDB;   mainMenu;;         # Drop Table
            4) connectDB; break;;           # Connect Table
            5) exit;;
            *) PS3="Please Select from the menu: ";;
        esac
        if [ -z $REPLY ]
        then echo "hello";
        else echo "noo"
        fi
        echo $REPLY;
    done
}

function createDB {
    read -p "Enter a Name of the New Database: " DBName
    clear

    if [ -d ./$const_root/$DBName ] 
	then PrintInCenter "[ $DBName ] Database is already exists!"
    else
        mkdir ./$const_root/$DBName        
        PrintInCenter "==>> Database created successfully! <<=="
    fi
}

function listDBs {
    if [ -d ./$const_root ]
    then 
        clear
        subdircount=$(find ./$const_root -maxdepth 1 -type d | wc -l)

        if [ $subdircount -gt 1 ]; 
        then
            echo "Available Databases are:"
            ls -d ./$const_root/*/ | cut -f3 -d '/' | tr '\n' '\t'      # tr used to make the output horizontally with replacing \n with \t
            echo -e "\n"
            PrintInCenter "============================"
        else PrintInCenter "==>> There is no Databases yet! <<=="
        fi
    fi
}

### Dropping an existing Database Function
function dropDB {
    read -p "Enter the Database Name: " DBName

    if [ -d ./$const_root/$DBName ]
    then 
        select verify in "yes" "No"
        do
            case $REPLY in
            1) rm -r ./$const_root/$DBName
               clear
               PrintInCenter "===>> [ $DBName ] deleted Successfully! <<===" ;;
            2) clear;;
            esac
        done
    else 
        PrintInCenter " ===>> Database $DBName wasn't found <<==="
        dropOrExit
    fi
}

function dropOrExit {
    PS3="Please Enter a Choice: "
    select choice in "Try Again" "Exit"
    do
        case $REPLY in
        1) dropDB;;
        2) clear; mainMenu;;
        *) dropOrExit;;
        esac
    done
}

### Connect to Database
function connectDB
{
    read -p "Enter Database Name: " DBName

    if [ -d ./$const_root/$DBName ]
    then 
        cd ./$const_root/$DBName
        clear
        PrintInCenter "Connected to $DBName Successfully"
        # Execute Tables Setting
	    ./../../tables.sh $DBName
    else 
	    PrintInCenter "===>> Database $name wasn't found <<==="
	    connectOrExit
    fi
}
function connectOrExit {
    PS3="Please Enter a Choice: "
    select choice in "Try Again" "Exit"
    do
        case $REPLY in
        1) connectDB;;
        2) clear; mainMenu;;
        *) connectOrExit;;
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
mainMenu
