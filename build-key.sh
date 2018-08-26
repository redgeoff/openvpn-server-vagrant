#!/usr/bin/expect

# Usage: build-key.sh name

# The following command doesn't work so we need to use expect
# yes "" | ./build-key ${name}

set name [lindex $argv 0];

# Get the password for the VPN account
stty -echo
send_user -- "VPN User Password: "
expect_user -re "(.*)\n"
send_user "\n"
stty echo
set pass $expect_out(1,string)

# Confirm the password for the VPN account
stty -echo
send_user -- "Confirm VPN User Password: "
expect_user -re "(.*)\n"
send_user "\n"
stty echo
set confirm_pass $expect_out(1,string)

spawn ./build-key-pass $name
send -- "$pass\r"
send -- "$confirm_pass\r"
expect "Country Name"
send "\n"
expect "State or Province Name"
send "\n"
expect "Locality Name"
send "\n"
expect "Organization Name"
send "\n"
expect "Organizational Unit Name"
send "\n"
expect "Common Name"
send "\n"
expect "Name"
send "\n"
expect "Email Address"
send "\n"
expect "A challenge password"
send "\n"
expect "An optional company name"
send "\n"
expect "Sign the certificate"
send "y\n"
expect "1 out of 1 certificate"
send "y\n"
expect "$ "
