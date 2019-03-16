#!/bin/bash

ans=0;#0 to 7
path=$1
prog=$2
shift
shift

cd $path

#Compilation and file exist test
make
if [ $? -eq 2 ]; then
	ans=$(( $ans | 7 ))
else 

	# Memory leaks test
	valgrind  --leak-check=full --error-exitcode=10 --tool=memcheck --log-file="/dev/null" ./$prog $@ > /dev/null
	if [ $? -eq 10 ]; then
		ans=$(( $ans | 2 ))
	fi

	# Thread race test
	valgrind --tool=helgrind --error-exitcode=10 --log-file="/dev/null" ./$prog $@
	if [ $? -eq 10 ]; then
		ans=$(( $ans | 1 ))		
	fi

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


#exit
echo  
exit $ans
