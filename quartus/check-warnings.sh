#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\e[1m'
NC='\033[0;0m' # No color, unmodified characters

allowed=(18236 276020 15064 169177 171167 15705 15714 13024 21074 10036 12240 35016 332043)
IFS='
'

function check_problems() {
	for x in ${@}; do
		code=`echo $x | cut -d "(" -f2 | cut -d ")" -f1`
		if [[ "${allowed[@]}" =~ "$code" ]]; then
			line="${GREEN}[ALLOWED]${NC} ${x}";
			#echo -e ${line:0:`tput cols`};
			echo -e ${line};
		else
			line="${RED}[NOT ALLOWED]${NC} ${x}";
			echo -e ${line};
		fi
	done
}

warning_count=`grep -c -e '^Warning (' $1`;
inferred_latche_count=`grep -c -e '^Info (10041)' $1`;
crit_warning_count=`grep -c -e '^Critical Warning (' $1`;
error_count=`grep -c -e '^Error (' $1`;


# Check for warnings
if ((${warning_count} > 0)); then
	echo -e "${BOLD}-------- Found ${warning_count} Warnings${NC}";
	warnings=`grep -e '^Warning (' $1`;
	check_problems ${warnings};
fi

# Check for inferred latches
if ((${inferred_latche_count} > 0)); then
	echo -e "${BOLD}-------- Found ${inferred_latche_count} Inferred Latches${NC}";
	inferred_latches=`grep -e '^Info (10041)' $1`;
	check_problems ${inferred_latches};
fi

# Check for critical warnings
if ((${crit_warning_count} > 0)); then
	echo -e "${BOLD}-------- Found ${crit_warning_count} Critical Warnings${NC}";
	crit_warnings=`grep -e '^Critical Warning (' $1`;
	check_problems ${crit_warnings};
fi

# Check for errors
if ((${error_count} > 0)); then
	echo -e "${BOLD}-------- Found ${error_count} Errors${NC}";
	errors=`grep -e '^Error (' $1`;
	check_problems ${errors};
fi

summary="${BOLD}-------- ${error_count} Errors, ${crit_warning_count} Critical Warnings, ${inferred_latche_count} Inferred Latches, ${warning_count} Warnings${NC}";
echo -e ${summary}
