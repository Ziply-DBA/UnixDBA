#!/usr/bin/expect
# https://www.pantz.org/software/expect/expect_examples_and_tips.html
set timeout 5
set username [lindex $argv 0]
set su_name [lindex $argv 1]
set password [lindex $argv 2]
set hostname [lindex $argv 3]
log_user 0

if {[llength $argv] == 0} {
  send_user "Usage: scriptname $LOGNAME su_name \'password\' hostname\n"
  exit 1
}

spawn ssh -q -o StrictHostKeyChecking=no $username@$hostname


expect {
  timeout { send_user "\nLogin for hostname $hostname failed. \n"; exit 1}
  eof { send_user "\nSSH failure for $hostname\n"; exit 1 }
  "*\$ "
}

send "sudo su - $su_name\r"
#Assuming that we will be prompted for a password.
# If not, we would probably be scripting this in ansible

expect {
  timeout { send_user "\nFailed to get password prompt for $hostname\n"; exit 1 }
  "*assword"
}

send "$password\r"

#We don't know what to expect for a prompt on success,
# so we wait for failure (another password prompt)
# and if that times out, we will assume success.
expect {
  timeout { send_user "\nsudo to $su_name on hostname $hostname succeded. \n"; exit 1}
  "*assword: "
}


send_user "\nsudo to $su_name on hostname $hostname failed.\n"
send "exit\r"
close
