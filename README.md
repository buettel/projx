# projx

a commandline tool to navigate your projects. It also creates directories per project and customer. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine.

### Prerequisites

What things you need to install the tool and how to install it

- git
- optional Markdown Editor [MacDown](https://macdown.uranusjr.com/)
- Linux based Operating System or macOS


### Installing

clone this Repository in your home directory ( ~/ )

```
cd
git clone git@bitbucket.org:sowhat1/.projx.git
cd .projx/conf
./setup-projx.sh
```
**setup-projx.sh** follow instructions   

1. select project path, all directories will created under your selected path
2. Are you Systemadmin means, do you want root access to machines. It is only possibe when your ssh key is deployed.

after you run **setup-projx.sh**, you can modify .projx/conf/projx.conf to change these choices afterwards.

## add new project

create sh file in root of this git, name it like project.sh or run: `projx create`

1 Expl.
```
# ATLMZ

# set variables
PROJECTNAME="atlmz"  # Stagingsubdomain
CUSTOMER="antalis"
## prod
DOMAIN="www.edition-lmz.ch"
ROOTLOGIN="ubuntu"
SUPW=""
## staging
STAGINGSUBDOMAIN=$PROJECTNAME
AWS_PROFILE="antalis"
## develop
DOCKERCONTAINERNAME="atlmz"
DOCKERCONTAINERDBNAME="atlmz-db"
## special aliases (optional)
alias cdnbck="cd $PROJXPATH/$CUSTOMER/$PROJECTNAME/s3media; sh ./scripts/renewCDNheader.sh"
```

2 Expl.
```
# ATSHL

# set variables
PROJECTNAME="atshl"  # Stagingsubdomain
CUSTOMER="antalis"
## prod
DOMAIN="shell.antalis.ch"
ROOTLOGIN="ubuntu"
SUPW=""
## staging
STAGINGSUBDOMAIN=$PROJECTNAME
AWS_PROFILE="antalis"
## develop
DOCKERCONTAINERNAME="atshl"
DOCKERCONTAINERDBNAME="atshl-db"
## special aliases (optional)
alias cdnbck="cd $PROJXPATH/$CUSTOMER/$PROJECTNAME/s3media; sh ./scripts/renewCDNheader.sh"
```

3 Expl.
```
# PIM


# set variables
PROJECTNAME="pim"  # Stagingsubdomain
CUSTOMER="ani"
## prod
DOMAIN="pim.active-nutrition-international.com"
ROOTLOGIN="uniteplus"
SUPW="BBOkTUGcXCnWo"
## staging
STAGINGSUBDOMAIN=$PROJECTNAME
AWS_PROFILE="mcon"
## develop
DOCKERCONTAINERNAME="pim"
DOCKERCONTAINERDBNAME="pim-db"
## special aliases (optional)
alias cdnbck="cd $PROJXPATH/$CUSTOMER/$PROJECTNAME/s3media; sh ./scripts/renewCDNheader.sh"
```
## remove project

run: `projx delete`



## Commandline tools

automatically created aliase

- atlmz   - from Example 1), opens project ATLMZ
- atshl   - from Example 1), opens project ATSHL
- pim     - from Example 1), opens project ATSHL
.
.
.
- help    - shows list of aliase per project

### project specific aliase 
- readme  - opens project specific file 
- p      - opens production pages https://shell.antalis.ch
- s      - opens staging pagee http://atshl.staging-uniteplus.de
- d      - opens develop pages http://atshl.agentur-sowhat.test



local Docker actions
---
- dev-login  - login into docker container
- dev-theme  - build theme
- dev-cc     - clear cache
- dev-config - show config.php
- dev-logs   - show logs




## Authors

* **Wolfgang Risse** - *Initial work* 


## License

This project is licensed under the MIT License
