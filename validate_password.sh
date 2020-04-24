#!/usr/bin/expect
# This script is adapted from:
# https://www.pantz.org/software/expect/expect_examples_and_tips.html
set timeout 9
set username [lindex $argv 0]
set password [lindex $argv 1]
set hostname [lindex $argv 2]
log_user 0

if {[llength $argv] == 0} {
  send_user "Usage: scriptname username \'password\' hostname\n"
  exit 1
}

spawn ssh -q -o StrictHostKeyChecking=no $username@$hostname

expect {
  timeout { send_user "\nFailed to get password prompt\n"; exit 1 }
  eof { send_user "\nSSH failure for $hostname\n"; exit 1 }
  "*assword"
}

send "$password\r"

expect {
  timeout { send_user "\nLogin for hostname $hostname failed. Password incorrect.\n"; exit 1}
  "*\$ "
}

send_user "\nPassword for hostname $hostname is correct\n"
send "exit\r"
close
