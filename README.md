How to config
===========================================================
1.config /your/home/.ssh/config file as following
----------------------------------------------------------
```ssh
Host sydeny-jump
 HostName 5.6.7.8
 User usera
 #cmd_login nsu
 #word usera_password_without_empty_space
 #word cmd_nsu_password_without_empty_space

Host sydeny-jump2
 HostName 5.6.7.9
 User usr2
 IdentityFile /home/user/ssh_rsa
 #cmd sudo su -
 #word sudo_su_passwor_without_empty_space

```
2.make a dir which named sydeny
----------------------------------------------------------
```bash
mkdir sydeny
```


How to use:
===========================================================
1.connect to the terminal without password
  * if you on the sydeny folder, the connnection string will transform to sydney-jump, so 1 & 2 are same
```bash
  lazycon.sh jump
```
  1. test1
..1 test2
..2.if you not in sydeny folder.
```bash
lazycon.sh sydney-jump
```

3.open a ssh tunnel without password
```bash
lazycon.sh jump  -p 1433:sql-hostname:1433
```
4.upload file to /var/tmp
```bash
lazycon.sh jump  -f file_to_upload
```

5.download file to local dir
```bash
lazycon.sh jump  -d full_file_path_to_download
```
