#!/bin/bash

if [ $# -eq 0 ]
then
SERVER="localhost"
elif [$# -eq 1 ]
then
SERVER=$1
fi

echo $0

IP=`ip address | grep inet | grep enp0s3 | cut -d " " -f 6 | cut -d "/" -f 1`
echo $IP
TIMEOUT="1"
PORT="3333"
echo "cliente EFTP"

echo "(1) Send"
echo "EFTP 1.0" | nc $SERVER 3333
echo "(2) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`
echo $DATA

echo "(5) Test & Send"

if [ "$DATA" != "OK_HEADER" ]
then
	echo "ERROR 1: BAD HEADER"
	exit 1
fi

echo "BOOOM"
sleep 1
echo "BOOOM" | nc $SERVER 3333

echo "(6) Listen"

DATA=`nc -l -p 3333 -w $TIMEOUT`


echo $DATA


echo "(9) Test"

if [ "$DATA" != "OK_HANDSHAKE" ]
then
	echo "ERROR 2:BAD HANDSHAKE"
	exit 2
fi


echo "(10) Send"
sleep 1
FILE_NAME="fary1.txt"
FILE_MD5=`echo $FILE_NAME | md5sum | cut -d " " -f 1`
echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc $SERVER $PORT

echo "(11) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`

echo "(14) Send"

if [ "$DATA" != "OK_FILE_NAME" ]
then
	echo "ERROR 3: BAD FILE NAME PREFIX"
	exit 3
fi
sleep 1
cat imgs/fary1.txt | nc $SERVER 3333

echo "(15) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`

if [ "$DATA" != "OK_DATA" ]
then
	echo "ERROR 4: BAD DATA"
	exit 4
fi


echo "(18) Send"

FILE_MD5=`cat imgs/$FILE_NAME | md5sum | cut -d " " -f 1`
echo "FILE_MD5 $FILE_MD5" | nc $SERVER 3333


echo "(19) Listen"
DATA=`nc -l -p 3333 -w $TIMEOUT`


echo "(21) Test"

if [ "$DATA" != "OK_FILE_MD5" ]
then
	echo "ERROR 5: FILE MD5"
	exit 5
fi

echo "FIN"
exit 0

echo "FIN"
exit 0
