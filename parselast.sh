#!/bin/bash
#
# Collect all the login name/domain data
# from columns of the "last" command.
# Uses domain NAMES, but that's fine
# because you cache DNS, right?
#
# Blame: phil@slug.org
#

## Right way to init associative array.
declare -gA aryLast

while read -r -- col1 col2 col3 col4
  do
    ## The GOOD stuff
    user="$col1"
    host="$col3"
    ## UNUSED COLUMNS
    # shellcheck disable=2034
    tty="$col2"
    # shellcheck disable=2034
    timestamp="$col4"

    ## Possible empty string!
    if [[ ${#user} -gt 1 ]]; then
      ## Uniquify using assoc array key.
      aryLast[${user}${host}]="$user;$host"
    fi
  ## This is an ugly bashism that ksh fixed.
  done < <(last -d)
echo "${aryLast[*]}"
