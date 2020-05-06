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

7. In your home directory, create a host_inventory.txt file with the name or FQDN of each Unix/Linux host you want to be able to connect to. This is not your ansible inventory file, which we will discuss below; it's just a simple test file with one host per line.

### Running the Repository Expect Scripts
Expect is a scripting tool that comes in very handy when you will be prompted for a password. We will use expect to lay the groundwork for what follows by verifying access to the hosts and pushing out our SSH keys so that we won't need to enter our password any more. Once that is done, we can use Ansible to do almost anything.

#### Verifying Host Access
You may or may not have access to **git** on your control host to clone this repository. Let's assume you don't. If you clone the repository elsewhere and FTP it to your control host or just use **vi** to create new files and copy/paste from github.com, that's fine. Remember to `chmod u+x` on everything. 

You may want to test one host before going for the whole set:

`./validate_password.sh $LOGNAME mysupersecretpassword hostname.example.net`

Once that is done, you test the whole inventory as follows:

`./validate_all mysupersecretpassword`

`grep correct validate.out`

`grep incorrect validate.out`

`grep Failed validate.out`

Based on the results, you may want to adjust your inventory file before proceeding on to try pushing your public SSH key out.

NOTE: If, for some reason, you already have SSH keys set up between your control and a remote host, you will get the "Failed to get password prompt" error for that host, because the host will not be prompting for a password.


#### Pushing Your Key to Remote Hosts 
For some reason, **ssh-copy-id**, the program on which the following steps rely, is kind of fussy about ID file names. Without spending too much time trying to figure out why, I wrote these scripts to just look for **/home/$username/.ssh/public_key.pub**.

So, before you begin, create that file. Assuming it's the only entry in your authorized_keys file, you can copy it from there:

`cp ~/.ssh/authorized_keys ~/.ssh/public_key.pub`

Again, you may want to test one host before going for the whole set:

`./push_key.sh $LOGNAME mysupersecretpassword hostname.example.net`

And again, once that is done, you test the whole inventory as follows:

`./push_all mysupersecretpassword`

Once successful, your public key will have been added to authorized_keys on all the target machines and you will be able to connect to them from PuTTY or from your control host without being prompted for a password.

#### Testing sudo access

Verify you have sudo access to (for instance) the *oracle* user:

1. create the file ~/oracle_inventory.txt and populate it with the names of hosts to target.

2. `/test_all.sh oracle mysudopassword`

3. `cat test_oracle.out`

### Running the Repository Ansible Scripts
Now that we have password-less access to all our hosts, we can use Ansible to start configuring them to our liking and polling them for information. Consult the online documentation for ansible for guidance on how to create your ansible inventory file (inventoryfile.txt in the example below). If you have machines hosting Oracle databases, put them in a group called "oracle".

#### Set your environment variables on all remote hosts at once
1. On your control host, create a profile script with your username ($LOGNAME.profile) and store it in your home (/home/$LOGNAME). Fill the file with all the little things you want the shell to know about you, such as the aliases you use for common commands. Optionally, create oracle.profile in your home (see example in this repository) to be executed on whatever machines host an oracle database. Add a line to your $LOGNAME.profile to source oracle.profile if it exists ( `[[ -f ~/oracle.profile ]] && . ~/oracle.profile` ) 

2. Use push_profile.yaml to push your profile script(s) to your inventory of hosts and to add a line in .bash_profile on each remote host to source these new scripts:

`ansible-playbook -i inventoryfile.txt push_profile.yaml`
