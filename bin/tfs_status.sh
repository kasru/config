#!/bin/bash

# Get status recursively for given directory (or the current one)
# considering it is mapped somehow.
# Usage:
#   tfs_status.sh [Directory]
# Attention!
#   Run inside or for TFS mapped folder!

tf status -r ${1:-.} | \
sed "1,2d;s/^[^ ]*[ ]*\([ !][ ][^ ]\)/\1/g;s!$PWD/!!g" | \
grep -Ev '^(\$|\s*$)'

# End of file
