#!/bin/bash
trap "kill 0" SIGINT SIGKILL
if [[ $1 == "-d" || $1 == "--debug" ]] ; then
  EXP_DEBUG_BEGIN=""
  EXP_DEBUG_END='
  '
  set -x 
  shift
else
  EXP_DEBUG_BEGIN="log_user 0
  stty -echo"
  EXP_DEBUG_END='log_user 1
  stty echo
  sleep 1
  '
fi

if [[ $1 == "-h" || $1 == "--help" ]] ; then
  cat README.md
fi

if [[ $1 == "-q" ]] ; then
  NOECHO="-noecho"
  shift
fi
if [[ $# == 0 || $1 =~ ^/.* ]] ; then
  echo no Hostname
  exit 1
fi
#IP_ADD=`ifconfig  | grep 192.168.0 | grep -i ipv4 | sed -e 's/^.*://g' -e 's/(.*$//g' | tr -d ' '`
orignal_1=$1
shopt -s nocasematch
if grep '^Host *'$1'$' ~/.ssh/config > /dev/null
then
	grep_string=$1
elif grep '^Host '`basename $PWD`-$1'$' ~/.ssh/config > /dev/null
then
	grep_string="`basename $PWD`-$1"
else
	echo cannot find hostname
	exit 1
fi
shift

if [[ $NOECHO != "" ]]
then 
	echo lazylogin Host ${grep_string}
fi
oldIFS="$IFS"
IFS=$'\n'
word_array=( `
cat ~/.ssh/config | sed -n -e "/Host ${grep_string}/,/Host /p"  | sed -n -e '1d;$d;' -r -e '/#word|#cmd/p' | sed -re 's/^[[:space:]]*#//g' 
 `)
# todo improve some password comword
for x in ${word_array[*]}
do
  if [[ $x =~ ^cmd ]]
  then
    expect_words="${expect_words}
    expect \"\\r\" {
      sleep 1
      send \"${x#cmd* }\\r\"
      sleep 1
    }
    "
    if [[ $x =~ ^cmd_login ]]
    then
      cmd_login=${x#cmd_login }
    else
      expect_login_words="${expect_login_words}
      expect \"\\r\" {
        sleep 1
        send \"${x#cmd* }\\r\"
        sleep 1
      }
      "
    fi
  elif [[ $x =~ ^word ]]
  then
    expect_words="${expect_words}
    expect \"assword\" {
      sleep 1
      send \"${x#word }\\r\"
      sleep 1
    }
    "
    expect_login_words="${expect_login_words}
    expect \"assword\" {
      sleep 1
      send \"${x#word }\\r\"
      sleep 1
    }
    "
    expect_passwds="${expect_passwds}
    expect \"assword\" {
      sleep 1
      send \"${x#word }\\r\"
      sleep 1
    }
    "
  fi
done
if [[ $NOECHO != "" ]]
then 
  echo "$expect_words"
fi

IFS="$oldIFS"
connect_string=${grep_string}
#############################
FUNC=login
if [[ $1 =~ -[cxufdp] ]] ; then 
  operation=$1
  shift
  if [[ ${operation} == "-c" ]] ; then
    FUNC=cmd
	expect -c '
     '"${EXP_DEBUG_BEGIN}"' 
		spawn -noecho ssh -o StrictHostKeyChecking=no -t '${connect_string}' '${cmd_login}'
      '"${expect_login_words}"'
			expect "\r" {
				sleep 3
				send "'"$*"'\r"
				sleep 1
			}
      '"${EXP_DEBUG_END}"'
      expect eof
		' 
#	expect -c '
#     '"${EXP_DEBUG_BEGIN}"' 
#		spawn -noecho ssh -t '${connect_string}'  nsu 
#			expect "*assword" {
#				send "'${erm_word}'\r"
#				sleep 1
#			}
#			expect "*assword" {
#				send "'${nsu_word}'\r"
#				sleep 1
#			}
#			expect "\n*root*" {
#				send "'"$@"'\r"
#				sleep 1
#			}
#      '"${EXP_DEBUG_END}"'
#			expect eof 
#		'
  fi
  if [[ ${operation} == "-x" ]] ; then
    FUNC=exec
    $0 $orignal_1 -c "rm -f /var/tmp/`basename $1 `;  chmod 777 /var/tmp/`basename $1 ` ; "
    $0 $orignal_1 -u $1
    $0 $orignal_1 -c " /var/tmp/`basename $1 ` $2 ; /bin/rm -v /var/tmp/`basename $1 `;"
  fi
  if [[ ${operation} == "-f" ||  ${operation} == "-u" ]] ; then
    FUNC=trans
	expect -c '
     '"${EXP_DEBUG_BEGIN}"' 
		spawn -noecho scp -r '"$1"' '${connect_string}':/var/tmp
      '"${expect_passwds}"'
      '"${EXP_DEBUG_END}"'
      interact
		' 2>/dev/null
#    expect -c '
#       '"${EXP_DEBUG_BEGIN}"' 
#      spawn -noecho scp -r -q '"$1"' '${connect_string}':/var/tmp
#        expect "assword" {
#        sleep 1
#        '"  ${expect_words}  "'
#        }
#        '"${EXP_DEBUG_END}"'
#			  expect eof 
#      ' 2>/dev/null
  fi
  if [[ ${operation} == "-d" ]] ; then
    FUNC=trans
    filename=`basename $1`
    $0 $orignal_1 -c "/bin/cp -R ${1/~/\~} /var/tmp/${filename}"
    expect -c '
     '"${EXP_DEBUG_BEGIN}"' 
      spawn -noecho scp -q -r '${connect_string}:"/var/tmp/${filename}"' .
        expect "*assword" {
          send "'${erm_word}'\r"
          sleep 1
        }
      '"${EXP_DEBUG_END}"'
      expect eof
      '
      $0 $orignal_1 -c "/bin/rm -r /var/tmp/$filename "
  fi
  if [[ ${operation} == "-fd" ]] ; then
    FUNC=trans
    expect -c '
     '"${EXP_DEBUG_BEGIN}"' 
      spawn -noecho scp -q -r '${connect_string}:${1/~/\~}' .
      '"${expect_words}"'
      '"${EXP_DEBUG_END}"'
      '
  fi
  if [[ ${operation} == "-p" ]] ; then
    FUNC=proxy
      expect -c '
         '"${EXP_DEBUG_BEGIN}"' 
        spawn -noecho ssh -N -L '"$1"' '${connect_string}'
          '"${expect_login_words}"'
          '"${EXP_DEBUG_END}"'
          interact
        ' 2>/dev/null
  fi
fi

if [[ $FUNC == login ]] ; then
	expect -c '
     '"${EXP_DEBUG_BEGIN}"' 
		spawn -noecho ssh -o StrictHostKeyChecking=no -t '${connect_string}' '${cmd_login}'
      '"${expect_login_words}"'
      '"${EXP_DEBUG_END}"'
      interact
		' 2>/dev/null
fi

#############################
