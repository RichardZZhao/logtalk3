#!/usr/bin/env bash

#############################################################################
## 
##   This script creates a SWI-Prolog logtalk.qlf file
##   with the Logtalk compiler and runtime
## 
##   Last updated on April 2, 2018
## 
##   This file is part of Logtalk <https://logtalk.org/>  
##   Copyright 1998-2018 Paulo Moura <pmoura@logtalk.org>
##   
##   Licensed under the Apache License, Version 2.0 (the "License");
##   you may not use this file except in compliance with the License.
##   You may obtain a copy of the License at
##   
##       http://www.apache.org/licenses/LICENSE-2.0
##   
##   Unless required by applicable law or agreed to in writing, software
##   distributed under the License is distributed on an "AS IS" BASIS,
##   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##   See the License for the specific language governing permissions and
##   limitations under the License.
## 
#############################################################################


directory="$HOME/collect"

if ! [ "$LOGTALKHOME" ]; then
	echo "The environment variable LOGTALKHOME should be defined first, pointing"
	echo "to your Logtalk installation directory!"
	echo "Trying the default locations for the Logtalk installation..."
	if [ -d "/usr/local/share/logtalk" ]; then
		LOGTALKHOME=/usr/local/share/logtalk
		echo "... using Logtalk installation found at /usr/local/share/logtalk"
	elif [ -d "/usr/share/logtalk" ]; then
		LOGTALKHOME=/usr/share/logtalk
		echo "... using Logtalk installation found at /usr/share/logtalk"
	elif [ -d "/opt/local/share/logtalk" ]; then
		LOGTALKHOME=/opt/local/share/logtalk
		echo "... using Logtalk installation found at /opt/local/share/logtalk"
	elif [ -d "/opt/share/logtalk" ]; then
		LOGTALKHOME=/opt/share/logtalk
		echo "... using Logtalk installation found at /opt/share/logtalk"
	elif [ -d "$HOME/share/logtalk" ]; then
		LOGTALKHOME="$HOME/share/logtalk"
		echo "... using Logtalk installation found at $HOME/share/logtalk"
	elif [ -f "$( cd "$( dirname "$0" )" && pwd )/../core/core.pl" ]; then
		LOGTALKHOME="$( cd "$( dirname "$0" )" && pwd )/.."
		echo "... using Logtalk installation found at $( cd "$( dirname "$0" )" && pwd )/.."
	else
		echo "... unable to locate Logtalk installation directory!"
		echo
		exit 1
	fi
	echo
	export LOGTALKHOME=$LOGTALKHOME
elif ! [ -d "$LOGTALKHOME" ]; then
	echo "The environment variable LOGTALKHOME points to a non-existing directory!"
	echo "Its current value is: $LOGTALKHOME"
	echo "The variable must be set to your Logtalk installation directory!"
	echo
	exit 1
fi

print_version() {
	echo "$(basename "$0") 0.2"
	exit 0
}

usage_help()
{
	echo 
	echo "This script creates a SWI-Prolog logtalk.qlf file with the Logtalk compiler and runtime"
	echo
	echo "Usage:"
	echo "  $(basename "$0") [-d directory]"
	echo "  $(basename "$0") -v"
	echo "  $(basename "$0") -h"
	echo
	echo "Optional arguments:"
	echo "  -v print version of $(basename "$0")"
	echo "  -d directory to use for intermediate and final results (default is $HOME/collect)"
	echo "  -h help"
	echo
	exit 0
}

while getopts "vd:h" option
do
	case $option in
		v) print_version;;
		d) d_arg="$OPTARG";;
		h) usage_help;;
		*) usage_help;;
	esac
done

if [ "$d_arg" != "" ] ; then
	directory="$d_arg"
fi

mkdir -p "$directory"
cd "$directory"

operating_system=$(uname -s)

if [ "${operating_system:0:10}" == "MINGW32_NT" ] || [ "${operating_system:0:10}" == "MINGW64_NT" ] ; then
	# assume that we're running on Windows using the Git for Windows bash shell
	extension='.sh'
elif [ "$LOGTALKHOME" != "" ] && [ "$LOGTALKUSER" != "" ] && [ "$LOGTALKHOME" == "$LOGTALKUSER" ] ; then
	# assume that we're running Logtalk without using the installer scripts
	extension='.sh'
else
	extension=''
fi

swilgt$extension -g "logtalk_compile([core(expanding),core(monitoring),core(forwarding),core(user),core(logtalk),core(core_messages)],[optimize(on),scratch_directory('$directory')])" -t "halt"

cp "$LOGTALKHOME/adapters/swi.pl" .
cp "$LOGTALKHOME/paths/paths_core.pl" .
cp "$LOGTALKHOME/core/core.pl" .

echo ":- discontiguous('\$lgt_current_protocol_'/5)." > logtalk.pl
echo ":- discontiguous('\$lgt_current_category_'/6)." >> logtalk.pl
echo ":- discontiguous('\$lgt_current_object_'/11)." >> logtalk.pl
echo ":- discontiguous('\$lgt_entity_property_'/2)." >> logtalk.pl
echo ":- discontiguous('\$lgt_predicate_property_'/3)." >> logtalk.pl
echo ":- discontiguous('\$lgt_implements_protocol_'/3)." >> logtalk.pl
echo ":- discontiguous('\$lgt_imports_category_'/3)." >> logtalk.pl
echo ":- discontiguous('\$lgt_instantiates_class_'/3)." >> logtalk.pl
echo ":- discontiguous('\$lgt_specializes_class_'/3)." >> logtalk.pl
echo ":- discontiguous('\$lgt_extends_category_'/3)." >> logtalk.pl
echo ":- discontiguous('\$lgt_extends_object_'/3)." >> logtalk.pl
echo ":- discontiguous('\$lgt_extends_protocol_'/3)." >> logtalk.pl
echo ":- discontiguous('\$lgt_loaded_file_'/7)." >> logtalk.pl
echo ":- discontiguous('\$lgt_included_file_'/4)." >> logtalk.pl

cat \
    swi.pl \
    paths_core.pl \
    expanding*_lgt.pl \
    monitoring*_lgt.pl \
    forwarding*_lgt.pl \
    user*_lgt.pl \
    logtalk*_lgt.pl \
    core_messages*_lgt.pl \
    core.pl \
    >> logtalk.pl

swipl -g "qcompile(logtalk)" -t "halt"

rm *.pl
