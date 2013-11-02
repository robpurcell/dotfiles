function dpatch() {
  curl $1 | git apply
}

export MARKPATH=$HOME/.marks
function jump { 
    cd -P $MARKPATH/$1 2>/dev/null || echo "No such mark: $1"
}
function mark { 
    mkdir -p $MARKPATH; ln -s $(pwd) $MARKPATH/$1
}
function unmark { 
    rm -i $MARKPATH/$1 
}
function marks {
    ls -l $MARKPATH | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}


drupal-hooks() {
  find . -name \*.php | xargs grep -l '^function hook_' | xargs ~/parse_drupal_api.pl > ~/Library/Preferences/WebIde60/templates/user.xml
}

cleankernels() {
    dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get purge
}

deploy(){

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

ALL_BRANCES=$(git branch)

STAGED_CHANGES=$(git diff --exit-code)
UNTRACKED_FILES=$(git ls-files --other --exclude-standard --directory)

# Ensure we have a branch name as an argument.
if [ -z "$1" ]
  then
    echo "Please provide a branch name to deploy."
    return
fi

if [ ! -z "$STAGED_CHANGES" ]
then
  echo 'Commit changes in working state before deployment.'
  return
fi

if [ ! -z "$UNTRACKED_FILES" ]
then
  echo 'You have untracked files. Please resolve before deployment.'
  echo "$UNTRACKED_FILES"
  return
fi

SITE_ALIAS=$(drush site-alias @$1)


if [ -z "$SITE_ALIAS" ]
then
  echo "No site alias was found for '$1'"
  return
fi

REMOTE_HASH=$(git ls-remote origin -h refs/heads/$1 | cut -f1)
LOCAL_HASH=$(git rev-parse $1)

if [ ! "$REMOTE_HASH" = "$LOCAL_HASH" ]
then
  echo -e "Your local branch is not up to date with the remote.\nPlease merge the remote changes into your local branch to deploy."
  return
fi


# We have a branch to switch to and everything is great.
echo ""
git checkout $1
echo ""

# Send our local working state to the live site
drush rsync --progress default @"$1"

echo -e "\nDeployment from 'local' to '$1' complete.\n"

$(git checkout -q $CURRENT_BRANCH)

read -p "Do you want to clear the cache on $1? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    drush @"$1" cc all
fi
}

alias gitsearch='git rev-list --all | xargs git grep -F'

alias ll='ls -lAhGp'

function undozip(){
  unzip -l "$1" |  awk 'BEGIN { OFS="" ; ORS="" } ; { for ( i=4; i<NF; i++ ) print $i " "; print $NF "\n" }' | xargs -I{} rm -r {}
}

# Count lines of code
alias htmllines='wc -l `find . -iname "*.html"` | sort -n'
alias phplines='wc -l `find . -iname "*.php"` | sort -n'
alias jslines='wc -l `find . -iname "*.js"` | sort -n'
alias sasslines='wc -l `find . -iname "*.scss"` | sort -n'

alias drupal-htaccess="wget -q --no-check-certificate -t 3 https://raw.github.com/drupal/drupal/7.x/.htaccess"

alias wotgobblemem='ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A | sort -n -k 6 | tail -15'

alias drupal-updates="drush up -n | grep -ir 'available'"

mans ()
{
    man $1 | grep -iC2 --color=always $2 | less
}


alias myip='curl ip.appspot.com'

alias wget='wget --content-disposition'

csscount() {
    cnt=0
    depth=0
    while read -n 1 char; do
            case $char in
                    "{")
                            ((depth++))
                            ;;
                    "}")
                            ((depth--))
                            if [ "$depth" -eq "0" ]; then
                                    ((cnt++))
                            fi
                            ;;
                    ",")
                            ((cnt++))
                            ;;
            esac
    done

    echo $cnt
}

# go back x directories
b() {
    str=""
    count=0
    while [ "$count" -lt "$1" ];
    do
        str=$str"../"
        let count=count+1
    done
    cd $str
}


alias aa="git add -A ."

alias gc="git commit -m "

alias cc="drush cc all"
alias ccc="drush cc all; clear;"

# Create a file of xMbs
cf() {
    upload_file="upload_file.txt"
    mbs=1048576
    
    if [ -n "$2" ]; then
        upload_file="$2"
    fi  

    let size=`expr $mbs*$1`;
    dd if=/dev/zero of="$upload_file" bs=$size count=1
}


alias co="git checkout "

alias gp="git pull origin "
alias gpm="gp master"

alias pm="git push origin master"

alias gb="git branch"

 alias gs="git status"

alias servethis="python -c 'import SimpleHTTPServer; SimpleHTTPServer.test()'"

extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}


alias sc="screen -S"
alias sl="screen -ls"
alias sr="screen -r"

alias freq='cut -f1 -d" " ~/.bash_history | sort | uniq -c | sort -nr | head -n 30'

alias c='clear'

alias p="git push origin "

ft() {

find . -name "$2" -exec grep -il "$1" {} \;
}

alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

dm(){

drush dl $1; 

drush en -y $1;
}

alias mcc="rm -rf var/cache/* var/full_page_cache/*"