#!/bin/bash
ans=0;#0 to 7

cd $1
make
makeVal=$?

#Compilation and file exist test
if [ $makeVal -eq 2 ]; then
	# not have make file or compilation fail
	ans=$(( $ans | 4 ))
fi 

# Memory leaks test
valgrind  --leak-check=full --error-exitcode=10 --tool=memcheck --log-file="devnull" $2 $3 $4 $5 $6 $7 $8 $9 > devnull
if [ $? -eq 10 ]; then
	ans=$(( $ans | 2 ))
fi

# Thread race test
valgrind --tool=helgrind --error-exitcode=10 --log-file="devnull" $2 $3 $4 $5 $6 $7 $8 $9
if [ $? -eq 10 ]; then
	ans=$(( $ans | 1 ))		
fi

#print and exit
echo  
echo BasicCheck.sh $1 $2
echo Compilation	Memory_leaks	thread race
#Compilation
if [ $(( $ans & 4)) -eq 4 ]; then
	echo -n FAIL
else 
	echo -n PASS
fi
#Memory_leaks
if [ $(( $ans & 2)) -eq 2 ]; then
	echo -n "	FAIL"
else 
	echo -n "	PASS"
fi
#thread race
if [ $(( $ans & 1)) -eq 1 ]; then
	echo -n	"	FAIL"
else 
	echo -n	"	PASS"
fi

echo  
exit $ans