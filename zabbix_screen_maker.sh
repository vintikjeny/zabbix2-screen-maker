#! /bin/bash

# Author: Vintik Jeny

# Description
# If you want to make a Zabbix screen for many hosts  or graph, this script may siplify your life. It creates Zabbix 2 import file for grid screen, where hosts act as columns and existing graphs act as strings (and vice versa). 

# Input 
# Scrit require two input files - list of hosts (host names in your Zabbix) and list of graps (actual graph's names). Each element's name must starts with new line.

# Output
# Result  - is the .xml file, whitch you can import in Zabbix.
# Default output screen orientation:
# *	hosts - columns
# *	graps - strings


# Options
# *	-h <PATH_TO_HOSTS_FILE> - set path to file with list of hosts
# *	-g <PATH_TO_GRAPHS_FILE> - set path to file with list of graps
# *	-n <SCREEN_NAME> - set name of new screen
# *	-v - set vertical screen orientation (hosts - strings, graphs - columns) 

HOSTS_FILE=
GRAPHS_FILE=
SCREEN_NAME=
ORIENTATION="horizontal"	# default orientation

HOSTS_NUMBER=0
GRAPHS_NUMBER=0
IFS=$'\n'	#custom fields separator
# main script starts here

find_hosts_number() {
	HOSTS_NUMBER=0
	for i in $(cat $HOSTS_FILE); do
		let HOSTS_NUMBER++
	done
}

find_graphs_number() {
	GRAPHS_NUMBER=0
	for i in $(cat $GRAPHS_FILE); do
		let GRAPHS_NUMBER++
	done
}

while getopts :h:g:n:v arg
do
	case $arg in
		h)	HOSTS_FILE=$OPTARG;;
		g)	GRAPHS_FILE=$OPTARG;;
		n)	SCREEN_NAME=$OPTARG;;
		v)	ORIENTATION="vertical";;
		:)	echo "$0: Key -$OPTARG need to be resolved with argument." >&2
			exit 1;;
		\?)	echo "Invalid key -$OPTARG";;
	esac
done

if [ -z $HOSTS_FILE ]
then
	echo "Please, set path to file with hosts names: "
	read HOSTS_FILE
	find_hosts_number;
	echo "Found $HOSTS_NUMBER hosts"
fi

if [[ -z $GRAPHS_FILE ]]; then
	echo "Please, set path to file with graphs names: "
	read GRAPHS_FILE
	find_graphs_number;
	echo "Found $GRAPHS_NUMBER graphs"
fi

if [[ -z $SCREEN_NAME ]]; then

	echo "Please, set name for new screen: "
	read SCREEN_NAME
fi

RESULT_FILE=${SCREEN_NAME// /_}.xml		#replace spaces

find_hosts_number;
find_graphs_number;

case $ORIENTATION in
	horizontal )
		echo "Columns: $HOSTS_NUMBER hosts"
		echo "Strings: $GRAPHS_NUMBER graphs"
		COLUMNS=$HOSTS_NUMBER
		STRINGS=$GRAPHS_NUMBER
		COLUMNS_FILE=$HOSTS_FILE
		STRINGS_FILE=$GRAPHS_FILE
		;;
	vertical )
		echo "Columns: $GRAPHS_NUMBER graphs"
		echo "Strings: $HOSTS_NUMBER hosts"
		COLUMNS=$GRAPHS_NUMBER
		STRINGS=$HOSTS_NUMBER
		COLUMNS_FILE=$GRAPHS_FILE
		STRINGS_FILE=$HOSTS_FILE
		;;
esac

# user's confirmation
echo "Continue? (y/[a]): "
read -n 1 AMSURE
[ "$AMSURE" = "y" ] || exit 1

# making file

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<zabbix_export>
    <version>2.0</version>
    <date>$(date +"%Y-%m-%dT%TZ")</date>
    <screens>
        <screen>
            <name>$SCREEN_NAME</name>
            <hsize>$COLUMNS</hsize>
            <vsize>$STRINGS</vsize>
            <screen_items>" >> "./$RESULT_FILE"


y=0

for STRING_NAME in $(cat $STRINGS_FILE); do

	x=0
	for COLUMN_NAME in $(cat $COLUMNS_FILE); do
		case $ORIENTATION in
		horizontal )
			HOST=$COLUMN_NAME
			GRAPH=$STRING_NAME
			;;
		vertical )
			HOST=$STRING_NAME
			GRAPH=$COLUMN_NAME
			;;
		esac

		echo "                <screen_item>
                    <resourcetype>0</resourcetype>
                    <width>500</width>
                    <height>100</height>
                    <x>$x</x>
                    <y>$y</y>
                    <colspan>1</colspan>
                    <rowspan>1</rowspan>
                    <elements>0</elements>
                    <valign>0</valign>
                    <halign>0</halign>
                    <style>0</style>
                    <url/>
                    <dynamic>0</dynamic>
                    <sort_triggers>0</sort_triggers>
                    <resource>
                        <name>$GRAPH</name>
                        <host>$HOST</host>
                    </resource>
                </screen_item>" >> "./$RESULT_FILE" 
        let x++
	done

	let y++
done

# end of file

echo "            </screen_items>
        </screen>
    </screens>
</zabbix_export>" >> "./$RESULT_FILE"

echo "Screen saved in $RESULT_FILE file!"