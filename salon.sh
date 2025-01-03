#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ My Salon ~~~\n"

#Choose a service 
SERVICES_MENU() { 
  echo -e "Welcome to my Salon. Here are the services available.\n"
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name from services ORDER BY service_id")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo -e "4) Exit\n"
  echo -e "Which service would you like: "
  read SERVICE_ID_SELECTED
  SERVICE_EXIST=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_EXIST ]]
  then
    SERVICES_MENU "That is not a valid service."
  elif [[ $SERVICE_ID_SELECTED -eq 4 ]]
  then
    exit
  else
    #get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone= '$CUSTOMER_PHONE'")
    #if customer dose not exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      #get name
      echo -e "\nEnter your name?"
      read CUSTOMER_NAME
      #create new customer
      NEW_CUSTOMER=$($PSQL "insert into customers(name,phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    #get appointment time
    echo -e "\nWhat time would you like your appointment"
    read SERVICE_TIME
    #get customer_id
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    #Set APPOINTMENT
    APPOINTMENT_CREATED=$($PSQL "insert into appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    # Confirm appointment
    CONFIRM_SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    echo -e "I have put you down for a $CONFIRM_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
  exit
}

#Exit the Program
exit() {
  echo -e "\n Thank you for visiting. BYE!\n"
}

SERVICES_MENU