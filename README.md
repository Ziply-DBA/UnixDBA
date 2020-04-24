# UnixDBA
Tools for DBAs working with Unix or Linux accounts on multiple hosts.

## Overview
The DBA working in a large enterprise often faces the challenge of managing accounts on multiple host machines. Private-public key pairs reduce the need for entering passwords. Aliases for common commands can speed up workflow. When provisioned with a new account, automatic detection of database client binaries and modification of the user's PATH is helpful. 

Programs like **expect** and **ansible** make it possible to quickly and consistently set up these conveniences on multiple hosts. This repository contains scripts for that purpose.

## Assumptions
These scripts assume that the user has multiple Unix or Linux accounts on the same network having the same user ID and password, and is working from one of these accounts on a host (your "control" host) with **/usr/bin/expect** available and using **/bin/bash** as the shell. The user is presumed to be connecting via PuTTY (or KiTTY).

## Instructions
### SSH Key and Control Host Setup
1. Set up and save a private-public key pair with no passphrase using **puttygen** (for instructions click [here](https://docs.oracle.com/en/cloud/paas/event-hub-cloud/admin-guide/generate-ssh-key-pair-using-puttygen.html)). For example, save the files as "userID.pub" and "userID.ppk". On the Conversions menu, choose Export OpenSSH key to also save your private key in OpenSSH format ("userID.rsa").

2. In your default PuTTY settings, enter your user ID as your "Auto-login username" under "Connection -> Data" and set the "Private key file for authentication" under "Connection -> SSH -> Auth" to the private key you created. 

3. Log on to your control host and create a ".ssh" directory in your home if there is none, then create an id_rsa and an authorized_keys file. All of these must not be writeable by others:

`mkdir -p ~/.ssh`

`touch ~/.ssh/authorized_keys`

`touch ~/.ssh/id_rsa`

`chmod 700 ~/.ssh`

`chmod 600 ~/.ssh/authorized_keys`

`chmod 600 ~/.ssh/id_rsa`

4. Copy the contents of the public key created by puttygen into the **~/.ssh/authorized_keys** file on your control host. At this point, if you disconnect and reconnect using PuTTY, you should no longer be prompted for a password.

5. Copy the contents of the OpenSSH-formatted private key converted by puttygen ("userID.rsa" in the above example) into the **~/.ssh/id_rsa** file on your control host. At this point, if you use ssh to connect from this host to an account on another host having the matching key in its authorized_keys file, you will not need to enter a password. We will set up other hosts to have the necessary key in a subsequent step.


