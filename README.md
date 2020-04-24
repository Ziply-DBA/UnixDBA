# UnixDBA
Tools for DBAs working with Unix or Linux accounts on multiple hosts.

## Overview
The DBA working in a large enterprise often faces the challenge of managing accounts on multiple host machines. Private-public key pairs reduce the need for entering passwords. Aliases for common commands can speed up workflow. When provisioned with a new account, automatic detection of database client binaries and modification of the user's PATH is helpful. 

Programs like **expect** and **ansible** make it possible to quickly and consistently set up these conveniences on multiple hosts. This repository contains scripts for that purpose.
