
# start fix commands
#
# HEREIAM=$(pwd)
#
#
#
#
#
PLUGINPATH=~/.projx/conf/plugins

# Create readme, help

export PROJX=$PROJECTNAME
export CUSTOMER=$CUSTOMER
export DOMAIN=$DOMAIN
export DOCKERCONTAINERNAME=$DOCKERCONTAINERNAME

# Build output
## Directory Listing
[ "$CUSTOMER" = "" ] && cd $PROJXPATH/$PROJECTNAME || cd $PROJXPATH/$CUSTOMER/$PROJECTNAME
HEREIAM=$(pwd)
alias readme='open $HEREIAM/documents/readme.md'
ls -laFhG 
## prod

echo
echo -e "\033[31m## $PROJECTNAME\033[0m"
#echo 
[ "$DOMAIN" != "" ] && {

[ "$SSLTEST" = "YES" ] && {
 . $PLUGINPATH/plugin-ssl-test.sh
}

  LOGINTO=$DOMAIN
  [ "$IP" != "" ] && {
    LOGINTO=$IP
  }
  echo -e "\033[0;33mproduction:$LOGINTO\033[0m"

    if [ "$SUPW" != "" ]
      then
        echo 1 - ssh $ROOTLOGIN@$DOMAIN
        alias 1="echo $SUPW|pbcopy && ssh $ROOTLOGIN@$LOGINTO"
        echo "\033[32m$SUPW\033[0m"
    else
        echo 1 - ssh $ROOTLOGIN@$DOMAIN
        alias 1='ssh $ROOTLOGIN@$LOGINTO'
    fi

echo 2 - ssh admin@$DOMAIN
alias 2='ssh admin@$LOGINTO'
}

## staging
if [ "$DOCKERSUBDOMAIN" != "" ]
  then
    echo -e "\033[33mstaging:\033[0m"
    echo 3 - swt info --search $DOCKERSUBDOMAIN
    alias 3="swt info --search $DOCKERSUBDOMAIN"
  elif [ "$STAGINGSUBDOMAIN" != "" ]
  then
    echo -e "\033[33mstaging:\033[0m"
    echo 3 - swt info --search $STAGINGSUBDOMAIN
    alias 3="swt info --search $STAGINGSUBDOMAIN"
fi


## AWS
if  [ "$AWS_PROFILE" != "" ]
  then 
    echo -e "\033[33mAWS:\033[0m"
    echo 4 - aws-vault login $AWS_PROFILE
    alias 4="aws-vault login $AWS_PROFILE"
    export AWS_PROFILE=$AWS_PROFILE
fi

## dev
## substitue with MAKEFILE
[ "$DOCKERCONTAINERNAME" != "" ] && {
  #echo $DOCKERCONTAINERNAME
  [ -f "./Makefile" ] || {
#     dd of=Makefile << \EOF   
# .PHONY: help login theme clear config logs id 
# .DEFAULT_GOAL := help

# id: 
#   CONTAINERID=$(docker ps | grep -i ${DOCKERCONTAINERNAME}$ | cut -d' ' -f1)
 


# help:
#   @grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# # ----------------------------------------------------------------------------------------------------------------

# login: ## login to Container

#   echo  --- $(CONTAINERID) ----
#   # docker exec -itw /var/www/shopware ${CONTAINERID}  bash

# # theme: ## regenerate Theme

# # 	docker exec -itw /var/www/shopware $DOCKERCONTAINERNAME bash -c "php bin/console sw:theme:cache:generate; chown -R www-data:www-data . ; php bin/console sw:theme:dump:configuration; chown -R www-data:www-data ."

# # clear: ## Clear Cache of Dockercontainer

# # 	docker exec -itw /var/www/shopware $DOCKERCONTAINERNAME bash -c "php bin/console sw:cache:clear; chown -R www-data:www-data ."

# # logs: ## show logs of Container

# # 	docker  logs -f $DOCKERCONTAINERNAME

# # config: ## show config file of Container

# # 	docker exec -itw /var/www/shopware $DOCKERCONTAINERNAME bash -c "cat config.php"

# EOF
{
  echo .PHONY: help login theme clear config logs id 
  echo .DEFAULT_GOAL := help
  echo help:
  echo -e \t@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
  echo # ----------------------------------------------------------------------------------------------------------------
  echo login: ## login to Container
  echo -e \t--- $(CONTAINERID) ----
} > ./Makefile

echo test >> Makefile
  } 
}

#   then 
#     echo -e "\033[33mdevelop:\033[0m"
#     echo dev-login, dev-login-db, dev-theme, dev-cc, dev-config, dev-logs
#     alias dev-login='docker exec -itw /var/www/shopware $DOCKERCONTAINERNAME bash'
#     alias dev-theme='docker exec -itw /var/www/shopware $DOCKERCONTAINERNAME bash -c "php bin/console sw:theme:cache:generate; chown -R www-data:www-data . ; php bin/console sw:theme:dump:configuration; chown -R www-data:www-data ."'
#     alias dev-cc='docker exec -itw /var/www/shopware $DOCKERCONTAINERNAME bash -c "php bin/console sw:cache:clear; chown -R www-data:www-data ."'
#     alias dev-config='docker exec -itw /var/www/shopware $DOCKERCONTAINERNAME bash -c "cat config.php"'
#     alias dev-logs='docker  logs -f $DOCKERCONTAINERNAME'
# fi
if [ "$DOCKERCONTAINERDBNAME" != "" ] 
  then
    alias dev-login-db='docker exec -itw / $DOCKERCONTAINERDBNAME bash'
fi
echo

