function gco() {
	BRANCH=$(gb)
	FUNCTION=$1
	COMMENT="${@:2}"
	git commit -m "$FUNCTION: $BRANCH: $COMMENT"
}

function nb {
    local BRANCH=$1;
    git stash;
    git checkout master;
    git pull;
    git checkout -b $BRANCH;
    git stash apply;
    git status
}

function gar {
  CURRENTDIR=$(pwd)
  for i in $(az repos list --org https://youlend.visualstudio.com -p youlend-infrastructure | jq '.[].name' -r); do
    gcl $i
    cd $CURRENTDIR/$i
    pre-commit install
    cd $CURRENTDIR
  done
}

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/:(\1)/'
}


alias gaa="git add -u"
alias gat="git ls-files --modified | xargs git add"
alias gb="git branch | grep \"*\" | cut -d ' ' -f2"
alias gc="git checkout $1"
alias gca="git commit --amend --no-edit"
alias gcl="git clone $1"
alias gdm="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit master.."
alias gfo="git fetch origin"
alias gg='git grep -n '
alias gicl="git clone youlend@vs-ssh.visualstudio.com:v3/youlend/Youlend-Infrastructure/$1"
alias gitown="git log | grep "Author" | sort | uniq -c"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gmm="git merge master"
alias gpob="git pull origin $1"
alias gpom="git pull origin master"
alias gprf="git config pull.rebase false"
alias gprt="git config pull.rebase true"
alias gr="cd $(git rev-parse --show-toplevel)"
alias grm="git rebase master"
alias gs="git status"
