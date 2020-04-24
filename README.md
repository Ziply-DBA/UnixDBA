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

6. Make sure you have ansible installed ($ which ansible). If not, see installation instructions [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html). The easiest method, assuming you have python installed, is to use **pip**. Assuming you don't have root access, you can install it just for your own user account:

`pip install --user ansible`

If you don't have **pip**, you can get it this way:

`curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py`

`python get-pip.py --user`

7. In your home directory, create a host_inventory.txt file with the name or FQDN of each Unix/Linux host you want to be able to connect to, one host per line.

## Running the Repository Scripts
### Verifying Host Access
You may or may not have access to **git** on your control host to clone this repository. Let's assume you don't. If you clone the repository elsewhere and FTP it to your control host or just use **vi** to create new files and copy/paste from github.com, that's fine. Remember to `chmod u+x` on everything. 

You may want to test one host before going for the whole set:

`./validate_password.sh $LOGNAME mysupersecretpassword hostname.example.net`

Once that is done, you test the whole inventory as follows:

`./validate_all mysupersecretpassword`

`grep correct validate.out`

`grep incorrect validate.out`

`grep Failed validate.out`

Based on the results, you may want to adjust your inventory file before proceeding on to try pushing your public SSH key out.

### Pushing Your Key to Remote Hosts 
For some reason, **ssh-copy-id**, the program on which the following steps rely, is kind of fussy about ID file names. Without spending too much time trying to figure out why, I wrote these scripts to just look for **/home/$username/.ssh/public_key.pub**.

So, before you begin, create that file. Assuming it's the only entry in your authorized_keys file, you can copy it from there:

`cp ~/.ssh/authorized_keys ~/.ssh/public_key.pub`

Again, you may want to test one host before going for the whole set:

`./push_key.sh $LOGNAME mysupersecretpassword hostname.example.net`

And again, once that is done, you test the whole inventory as follows:

`./push_all mysupersecretpassword`

Once successful, your public key will have been added to authorized_keys on all the target machines and you will be able to connect to them from PuTTY or from your control host without being prompted for a password.
