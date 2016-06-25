===========================================================
How to config
===========================================================
config /your/home/.ssh/config file as following
----------------------------------------------------------
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




===========================================================
How to use:
===========================================================
1.if you on the sydeny folder, the connnection string will transform to sydney-jump, so 1 & 2 are same
  lazycon.sh jump

2.use it as shortcut
  lazycon.sh sydney-jump
  then it will connection sydney-jump automaticlly

And you can using other ssh function without input password
3.lazycon.sh jump  -p 1433:sql-hostname:1433
  #make a local proxy 

4.lazycon.sh jump  -f file_to_upload
  #upload file to /var/tmp

5.lazycon.sh jump  -d full_file_path_to_download
  #download file to local dir
