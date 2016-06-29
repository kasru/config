#GdbInit file, installed from ccdebug gdb frontend (see sourceforge) .

#---------------------------------------------------------------
#From Ira L. Ruben, gdbinit-MacsBug-without-plugin
# @param arg0: 1st string
# @param arg1: 2nd string
#---------------------------------------------------------------
define __strcmp
	set $__s1 = (unsigned char*)($arg0)
	set $__s2 = (unsigned char*)($arg1)
	set $match = 1
	set $__c1 = *((unsigned char*)$__s1)++
	while ($match && $__c1)
		set $__c2 = *((unsigned char*)$__s2)++
		if ($__c1 == $__c2)
			set $__c1 = *((unsigned char*)$__s1)++
		else
			set $match = 0
		end
	end
	set $match &= (*(unsigned char*)$__s2 == 0)
end

#-----------------------------------------------------------------------
# Prints Qt3 QString text.
# @param arg0: QString
#-----------------------------------------------------------------------
define pqs3
	printf ">"
	set $i=0
	set $d = (QStringData*)$arg0
	while $i < $d->len
		printf "%c", (char)($d->unicode[$i++].ucs & 0xff)
	end
	printf "< %d|\n", $d->len
end

#-----------------------------------------------------------------------
# Prints Qt4 QString text.
# @param arg0: QString
#-----------------------------------------------------------------------
define pqs4
	printf ">"
	set $i=0
	set $nl=0
	set $val=0
	set $d = $arg0.d
	while $i < $d->size && $nl < 50 && $i < 2000
		set $val=$d->data[$i++] & 0xff
		printf "%c", $val
		if ($val == 10)
			set $nl++
		end
	end
	if ($nl >= 50 && $i < $d->size || $i >= 2000)
		printf "__truncated__"
	end
	printf "< %d|\n", $d->size
end

#-----------------------------------------------------------------------
# Prints Qt3 or Qt4 QString text.
# @param arg0: QString
#-----------------------------------------------------------------------
define pqs
#	ToDo: For Qt3, remove '#' before pqs3, add '#' to pqs4 !
#	pqs3 $arg0
	pqs4 $arg0
end

#-----------------------------------------------------------------------
# Sets Qt4 QString text.
# @param arg0: QString
# @param arg1: Text
#-----------------------------------------------------------------------
define sqs4
	set $len = strlen($arg1) + 1
	call $arg0.resize($len)
	set $d = $arg0.d
	set $value = $arg1
	set $i = 0
	while $i < $len
		set $d->data[$i] = (char) ($value[$i] & 0xff)
		set $i++
	end
	set $d->data[$i] = 0
end

#-----------------------------------------------------------------------
# Called from ccdebug. You may add code in this function to display data
#    of given type in a user defined way in the ccdebug tooltip window.
# @param arg0: The typename of the expression.
# @param arg1: The expression to evaluate.
#-----------------------------------------------------------------------
define printUsrDefType
	__strcmp $arg0 "QString"
	if $match
		pqs $arg1
	end
	__strcmp $arg0 "string"
	if $match
		printf ">%s< %d|", $arg1.c_str(), $arg1.size()
	end
	__strcmp $arg0 "basic_string"
	if $match
		printf ">%s< %d||||||", $arg1.c_str(), $arg1.size()
	end
	# "wstring": Cannot be done with printf
	__strcmp $arg0 "wstring"
	if $match
		set $i = 0
		set $l = $arg1.size()
		set $d = $arg1.c_str()
		printf "%c", 62
		while $i < $l
			printf "%c", (char)($d[$i++] & 0xff)
		end
		printf "< %d|\n", $l
	end
	#======= ToDo: Add code to print your data types here =======
	# Add __strcmp statements and corresponding if-end blocks doing the printf()
	__strcmp $arg0 "CMyType1"
	if $match
		printf "printUsrDefType(CMyType1) says: %d\n", $arg1.myIntVal
	end
	__strcmp $arg0 "CMyType2"
	if $match
		printf "printUsrDefType(CMyType2) says: %d\n", $arg1.myIntVal
		printf "	%f\n", $arg1.myDblVal
	end
end
document printUsrDefType
	Checks the data type name (passed as arg0) and prints the expression (passed as arg1) in a specific way.
	ToDo: Add __strcmp statements and corresponding if-end blocks doing the printf() for your data types.
end

