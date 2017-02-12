# Apache-Virtual-Hosts-Creator

A simple bash script that can automate the process of **creating a virtual host** onto your Linux distribution. Note that I have tested this only on **Debian Jessie** and I hope it will work fine on your configuration as well. You can rise an issue or contribute if you experience any trouble!

If you don't know why you want to create a virtual host, you can refer to [the official documentation of Apache](https://httpd.apache.org/docs/current/vhosts/). Basicaly, you'll need it to set up multi-domain on your server, and I think it really is a good practice.

## Manual

### Requirements

 * A debian-like system (Ubuntu is fine).
 * The [`sudo`](https://wiki.debian.org/sudo) package installed
 * I recommend that you install first the PHP and MySQL version you want.
 * An **access to a sudo user shell**.
 * If you going with the automatic installation, the `sha1sum` and `wget` packages installed (which is default on Debian Jessie).

### How does it work?

The script creates a new user for each virtual host you create. It let you the possibility to have several teams working on each website you host. The DocumentRoot is put in `/home/VH_USERNAME/www/`. A user can customize its own Apache conf file with the link in its home directory, and have access to its Apache log (access and error).

It will create two scripts in the `/root/` folder - one to create, one to delete the virtual host.


You can customize :

* The configuration files directory, *default is `/etc/apache2/sites-available/` (which is Apache default)*
* The log files directory, *default is `/var/log/web/`*
* All the variable in the begining of the bash script

### Installation

If you are OK with the default value (and if you trust me ;) ), just run the following command to download and execute the setup script from a *sudo user* (an not **root**) CLI :

```shell
wget -O- https://raw.githubusercontent.com/aduh95/Apache-Virtual-Hosts-Creator/master/download.sh | sh
```

> If you want to install it as **root user** (which is not recommended), you have to download the setup file as described bellow and execute it with the following instruction: `./setup.sh root /root/ noDirectRootExecution`<

> If you prefere a manual install, just put the setup file on your server (using *git*, *scp*, *wget* or just *copy/paste it on a text editor*), modify the lines you don't like, and then run `chmod +x setup.sh && ./setup.sh`


To be sure it has been correctly installed, you can use the following commands :

```shell
source ~/.bashrc
alias
```

You should see something like :

```text
alias ls='ls --color=auto'
alias newApacheVH='sudo /root/createVirtualHost.sh'
alias delApacheVH='sudo /root/deleteVirtualHost.sh'
```

Now, you can run those aliases (`newApacheVH` and `delApacheVH`) to create or delete a virtual host.

```shell
newApacheVH
```

It will ask you some questions, then you should be started!

### What if I want to delete it?

I don't see why you would need such a thing (since my code is obviously perfect in any situation), but here are the steps to follow :

```shell
sudo rm /root/createApacheVirtualHost.sh
sudo rm /root/deleteApacheVirtualHost.sh
nano ~/.bash_aliases
```

And then delete the lines defining the two aliases for the Apache VH creator.
