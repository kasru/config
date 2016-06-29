# for TFS
alias tfchng='LC_ALL=C TF_DIFF_COMMAND='\''diff -u --label "%6 / %7" "%1" "%2"'\'' tf difference -r . | grep "(server)" | sed '\''s/Binary//'\'' | awk '\''{print $2}'\''  | sed '\''s/;.*//'\'''
