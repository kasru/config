#!/bin/bash

# Get list of conflicts recursively for given directory (or the current one)
# considering it is mapped somehow.
# Usage:
#   tfs_conflicts.sh [Directory]
# Attention!
#   Run inside or for TFS mapped folder!

tf resolve -preview -r "${1:-.}" 2>&1 | cut -d : -f 1,2 --output-delimiter='\' | awk -F '\' '
/ The item has been deleted in the source branch$/       {printf "deleted_in_source  %s\n", $1}
/ The item has been deleted in the target branch$/       {printf "deleted_in_target  %s\n", $1}
/ The source and target both have changes$/              {printf "both_have_changes  %s\n", $1}
/ The item content has changed$/                  {printf "item_has_changed   %s\n", $1}
/ is writable$/                     {printf "is_writable        %s\n", $1}
/ Another item with the same name exists on the server$/ {printf "same_name_exists   %s\n", $1}'

# End of file
