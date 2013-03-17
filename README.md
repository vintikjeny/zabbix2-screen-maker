# Description #
If you want to make a Zabbix screen for many hosts  or graph, this script may siplify your life. It creates Zabbix 2 import file for grid screen, where hosts act as columns and existing graphs act as strings (and vice versa). 
## Input ##
Scrit require two input files - list of hosts (host names in your Zabbix) and list of graps (actual graph's names). Each element's name must starts with new line.
## Output ##
Result  - is the .xml file, whitch you can import in Zabbix.
Default output screen orientation:
*	hosts - columns
*	graps - strings
## Options ##
*	**-h <PATH_TO_HOSTS_FILE>** - set path to file with list of hosts
*	**-g <PATH_TO_GRAPHS_FILE>** - set path to file with list of graps
*	**-n <SCREEN_NAME>** - set name of new screen
*	**-v** - set vertical screen orientation (hosts - strings, graphs - columns) 