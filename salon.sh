#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU(){
    if [[ $1 ]]
    then
      echo -e "\n$1"
    fi

    SERVICES=$($PSQL "SELECT service_id, name FROM services")
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      SEARCHED_SERVICE=$($PSQL "SELECT service_id FROM services where service_id=$SERVICE_ID_SELECTED")
      
      if [[ -z $SEARCHED_SERVICE ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        echo -e "What's your phone number?"
        read CUSTOMER_PHONE
        
       # while [[ ! $CUSTOMER_PHONE =~ ^[0-9-]*$ ]]
       # do
       #   echo -e "Invalid input.Please enter your phone number."
       #   read CUSTOMER_PHONE
       # done
        
        SEARCHED_CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
        
        if [[ -z $SEARCHED_CUSTOMER_ID ]]
        then
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME
            ADD_CUSTOMER=$($PSQL "insert into customers (phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
            SEARCHED_CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
        fi

        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers where customer_id=$SEARCHED_CUSTOMER_ID")
        
        echo -e "\nWhat time would you like your cut, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
        read SERVICE_TIME
        
        CREATE_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($SEARCHED_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        
        
        SERVICE_NAME=$($PSQL "SELECT name FROM services where service_id=$SERVICE_ID_SELECTED")
        
        echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
      fi
    fi
}
MAIN_MENU
