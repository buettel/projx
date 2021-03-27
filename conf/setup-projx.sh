#!/bin/bash

# set -Eeuo pipefail
# trap "echo ERR trap fired!" ERR

# Remove Project
remove_project () {
      # delete project  
      echo "This script will delete the complete project with all its subdirectories"
      echo 
      if [ $# -lt 1 ]; then
          echo please enter Projectname:
          read PROJECT
      else
          PROJECT=$1
      fi
      cd ~/.projx/conf
      [ ! -e ../$PROJECT.sh ] && echo "The project $PROJECT does not exist" && exit 1
      . ../$PROJECT.sh
      . projx.conf

      [ "$CUSTOMER" = "" ] && DELETEPATH=$PROJXPATH/$PROJECTNAME || DELETEPATH=$PROJXPATH/$CUSTOMER/$PROJECTNAME
      [ ! -d ~/.projx/conf/trash ] && mkdir ~/.projx/conf/trash

      #echo Please follow steps:
      echo 1.  mv $DELETEPATH ~/.projx/conf/trash
      mv $DELETEPATH ~/.projx/conf/trash

      echo 2.  rm ../$PROJECT.sh
      rm ../$PROJECT.sh

      echo 3.  remove alias $PROJECT from projx-aliase file
      echo "" > projx-aliase

      echo 4. remove hosts entry
      grep -v "#projx" /etc/hosts > /tmp/hosts.bck && cp /tmp/hosts.bck /etc/hosts

      echo 
      cd ..
      var=0
      for i in $(ls -1 *.sh | sort |uniq) 
        do
          . $i > /dev/null
          ## create alias
          [ ! -e projx-aliase ] && touch conf/projx-aliase
          source $i
          [ "$(grep "alias $PROJECTNAME=" conf/projx-aliase)" = "" ] && {
          #  echo create alias  - $PROJECTNAME
            echo "alias $PROJECTNAME='. ~/.projx/$i && . ~/.projx/conf/projx.sh'" >> conf/projx-aliase
          }
          ## create hosts entry
          [ -w /etc/hosts ] && {
            [ "$(grep "$STAGINGSUBDOMAIN.agentur-sowhat.test" /etc/hosts)" = "" ] && {
              # create host entry
              echo "127.0.0.1 $STAGINGSUBDOMAIN.agentur-sowhat.test #projx"  >> /etc/hosts
            }
          }
  done
exit 0
}
 
create_project () {
         if [ $# -lt 1 ]; then
          echo please enter new 
          echo Projectname:
          read PROJECT
          [ "$PROJECT" == "" ] && PROJECT=PROJECT
          echo Customernames: 
          read CUSTOMER
          [ "$CUSTOMER" == "" ] && CUSTOMER=CUSTOMER
         fi
         
## test $PROJECT exists
command -v $PROJECT >/dev/null 2>&1 && { echo >&2 "Your Projectname is a program.  Aborting."; exit 1; }
shopt -s expand_aliases
source ~/.projx/conf/projx-aliase 
alias $PROJECT >/dev/null 2>&1 && { echo >&2 "Your Projectname exists.  Aborting."; exit 1; }
[ "$PROJECT" == "projx" ] && { echo >&2 "Your Projectname exists.  Aborting."; exit 1; }

 cat <<EOF >~/.projx/$PROJECT.sh
#
### Please configure this projectfile 
### and run the command 'projx' in commandline.
### empty variables make parts not appear.
# 

# $PROJECT

# creates alias=$PROJECT ... in next terminal. Creates base directory
PROJECTNAME="$PROJECT"

# Project from the same customer will be collected in one directory called like the customer
CUSTOMER="$CUSTOMER"

# prod System
DOMAIN=""
SSLTEST="NO|YES"

# Set origin IP for ssh login, if system is behind a proxy
IP=""
ROOTLOGIN="ubuntu"

# Set SUPW only if ssh key is set with password
SUPW=""

# staging System
STAGINGSUBDOMAIN="$PROJECT"
DOCKERSUBDOMAIN=""

# AWS vault profile name
AWS_PROFILE="AWS Profile"

# develop System 
DEVELOPSUBDOMAIN="$PROJECT"

#creates little helper
DOCKERCONTAINERNAME="$PROJECT"
DOCKERCONTAINERDBNAME="$PROJECT-db"

## special aliases (optional)
# alias cdnbck="cd $PROJXPATH/$CUSTOMER/$PROJECTNAME/s3media; sh ./scripts/renewCDNheader.sh"

EOF
  [ "$(uname -s)" == "Darwin" ] && open ~/.projx/$PROJECT.sh || vi ~/.projx/$PROJECT.sh
  ~/.projx/conf/setup-projx.sh
  alias $PROJECT='. ~/.projx/$PROJECT.sh && . ~/.projx/conf/projx.sh'
  exit
}

list_project () {
  cd  ~/.projx/
  echo
  res="      \r\t\t\t"
  echo -e PROJECTNAME "$res |" CUSTOMER 
  echo --------------------------------------
  for i in $(ls -a *.sh | sort | cut -f1 -d'.'); do
    . ${i}.sh
    echo -e $PROJECTNAME "$res |" $CUSTOMER 
    DIRARRAY+=("$i")
  done
  cd - 2>/dev/null 1>&2
}

modify_project () {
  echo Projectname:
  read PROJECT
  [ "$PROJECT" == "" ] && help_project && exit
   [ "$(uname -s)" == "Darwin" ] && open ~/.projx/$PROJECT.sh || vi ~/.projx/$PROJECT.sh
}

upgrade_project () {
  echo process with 'q'
  sleep 1
  cd ~/.projx
  git log --oneline -n 5
  git pull 
  cd -  2>/dev/null 1>&2
  sleep 2
  clear
  help_project
}


# commandline options
for i in "$@"
do
case $i in
    -c|--create)
    create_project
    shift # past argument=value
    ;;
    -d|--delete)
    remove_project
    shift # past argument=value
    ;;
    -m|--modify)
    modify_project
    shift # past argument=value
    ;;
    -l|--list)
    list_project
    shift # past argument=value
    ;;
    -u|--upgrade)
    upgrade_project
    shift # past argument=value
    ;;
    -h|--help)    
    . ~/.projx/conf/plugins/plugin-help.sh
    echo $PLUGINPATH
    shift # past argument with no value
    ;;
    *)
         echo ??? # unknown option
    ;;
esac
done


### Progam - logic ###

cd ~/.projx/conf/
# create config file projx.conf
[ ! -e projx.conf ] && {
    ## include .projx sources  
    [ -e ~/.profile ] &&  STARTSHELL=".profile"
    [ -e ~/.bash_profile ] && STARTSHELL=".bash_profile" 
    [ -e ~/.bashrc ] &&  STARTSHELL=".bashrc"
    [ -e ~/.zshrc ] && STARTSHELL=".zshrc" 
    
    [ "$(grep "projx.conf" ~/$STARTSHELL)" = "" ] && {
      echo implement projx in ~/$STARTSHELL
      echo "" >> ~/$STARTSHELL
      echo "#projx" >> ~/$STARTSHELL
      echo "source ~/.projx/conf/projx.conf" >> ~/$STARTSHELL
     }
  
    ## create project path 
    echo "This script will create the project path with all subdirectories"
    echo 
    if [ $# -lt 1 ]; then
      echo enter project path [$(echo ~/Documents/Projx)]:
      read PROJXPATH
    else
      PROJXPATH=$1
    fi
    [ "$PROJXPATH" = "" ] && PROJXPATH=$(echo ~/Documents/Projx)
    ## check project path
    read -r -p "The path ${PROJXPATH} is perfect: [y/N] " response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        echo start script again, and change project path.
        exit
    fi
} || source ~/.projx/conf/projx.conf
# create directories and alias
cd ..
var=0
for i in $(ls -1 *.sh | sort |uniq) 
  do
    . $i > /dev/null

    ## create directories
    [ "$CUSTOMER" = "" ] && CREATEPATH=$PROJXPATH/$PROJECTNAME || CREATEPATH=$PROJXPATH/$CUSTOMER/$PROJECTNAME
    [ ! -d $CREATEPATH/documents ] && {
      ((var+=1))
      echo ... create $var. $CREATEPATH/documents
      mkdir -p $CREATEPATH/documents  
      echo "# $PROJECTNAME" > $CREATEPATH/documents/readme.md
      echo "**[$PROJECTNAME]($PROJECTNAME.sh.conf)**   " >> $CREATEPATH/documents/readme.md
      }

    ## create softlink to conf.sh
    [ -L "$CREATEPATH/documents/$i.conf" ] && [ -e "$CREATEPATH/documents/$i.conf" ] || ln -s ~/.projx/$i $CREATEPATH/documents/$i.conf

    ## create alias
    [ ! -e projx-aliase ] && touch conf/projx-aliase
    source $i
    [ "$(grep "alias $PROJECTNAME=" conf/projx-aliase)" = "" ] && {
      echo create alias  - $PROJECTNAME
      echo "alias $PROJECTNAME='. ~/.projx/$i && . ~/.projx/conf/projx.sh'" >> conf/projx-aliase
    }

    ## create hosts entry
    [ -w /etc/hosts ] && {
      [ "$DEVELOPSUBDOMAIN" != "" ]&&{
        [ "$(grep "$DEVELOPSUBDOMAIN.agentur-sowhat.test" /etc/hosts)" = "" ] && {
          echo create hosts entry for $DEVELOPSUBDOMAIN.agentur-sowhat.test
          echo "127.0.0.1 $DEVELOPSUBDOMAIN.agentur-sowhat.test #projx"  >> /etc/hosts
        }
      } 
    } 

  done
  [ -w /etc/hosts ] || echo "use 'sudo chmod 666 /etc/hosts' and run this script again, to make the script modify /etc/hosts"
cd - > /dev/null 2>&1

# create projx.conf file
[ ! -e projx.conf ] && {
echo create projx.conf 
cat <<EOF >projx.conf
#!/bin/bash
# projx configuration file
#
# Set File Path from root /
export PROJXPATH="$PROJXPATH"
# set projy aliase
[ -e ~/.projx/conf/projx-aliase ] && source ~/.projx/conf/projx-aliase
# set start alias and script
alias projx='~/.projx/conf/setup-projx.sh'
EOF
}
 
sh ~/.projx/conf/projx.conf
exit 0
