#!/usr/bin/expect
set timeout 9
set username [lindex $argv 0]
set password [lindex $argv 1]
set hostname [lindex $argv 2]

if {[llength $argv] == 0} {
  send_user "Usage: scriptname username \'password\' hostname\n"
  exit 1
}

spawn ssh-copy-id -f -i /home/$username/.ssh/public_key.pub $username@$hostname

expect {
  timeout { send_user "\nFailed to get password prompt\n"; exit 1 }
  eof { send_user "\nSSH failure for $hostname\n"; exit 1 }
  "*re you sure you want to continue connecting" {
        send "yes\r"
        exp_continue
    }
  "*assword" {
     send "$password\r"
     send_user "\nPassword for hostname $hostname is correct\n"
   }

}

expect {
  timeout { send_user "\nLogin for hostname $hostname failed. Password incorrect.\n"; exit 1}
  "*\$ "
}
