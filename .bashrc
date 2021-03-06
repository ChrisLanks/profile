#
#	This is the default standard profile provided to users.
#	They are expected to edit it to meet their own needs.

# This function checks whether we have a given program on the system.
_have()
{
	command -v $1 &>/dev/null
}

# This function checks if interactive.
_interactive()
{
	[[ $- == *i* ]]
}

# Path edit function
_pathedit ()
{
	if ! echo $PATH | grep -Eq "(^|:)$1($|:)" &>/dev/null ; then
		if [ "$2" = "after" ] ; then
			PATH=$PATH:$1
		else
			PATH=$1:$PATH
		fi
	fi
}

# Set PATH so it includes user's private bin if it exists
[ -d $HOME/bin ] && _pathedit $HOME/bin after

# More paths
[ -d /usr/local/sbin ] && _pathedit /usr/local/sbin
[ -d /usr/local/bin ] && _pathedit /usr/local/bin
[ -d /usr/sbin ] && _pathedit /usr/sbin
[ -d /usr/bin ] && _pathedit /usr/bin
[ -d /sbin ] && _pathedit /sbin
[ -d /bin ] && _pathedit /bin

PATH=$PATH:/home/user/clancaster/.nvm:/Users/clancaster/bin/platform-tools

# Set colors
 if _interactive && _have tput && (tput sgr0 &>/dev/null || tput me &>/dev/null) ; then
#if _have tput && (tput sgr0 &>/dev/null || tput me &>/dev/null) ; then
	CRESET="\[$(tput sgr0 || tput me)\]"	# reset all attributes
	C00="\[$(tput setaf 0 || tput AF 0)\]"	# black
	C01="\[$(tput setaf 1 || tput AF 1)\]"	# red
	C02="\[$(tput setaf 2 || tput AF 2)\]"	# green
	C03="\[$(tput setaf 3 || tput AF 3)\]"	# yellow
	#C04="\[$(tput setaf 4 || tput AF 4)\]"	# blue
	C04="\[$(tput setaf 6 || tput AF 6)\]"  # cyan
     C05="\[$(tput setaf 5 || tput AF 5)\]"	# magenta
	C06="\[$(tput setaf 6 || tput AF 6)\]"	# cyan
	C07="\[$(tput setaf 7 || tput AF 7)\]"	# white
fi

# Miscellaneous
export PAGER='less'
export TZ='America/New_York'
export LANG='en_US.UTF-8'
export OS_TYPE=$(uname)
#export GOROOT=/usr/local/bin/go
export GOPATH=$HOME/go

# SSH completion
_ssh_hosts()
{
        local prev cur opts known_hosts
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        cur="${COMP_WORDS[COMP_CWORD]}"
        [ -r "/etc/ssh/ssh_known_hosts" ] && known_hosts="/etc/ssh/ssh_known_hosts"
        [ -r "$HOME/.ssh/known_hosts" ] && known_hosts="$HOME/.ssh/known_hosts ${known_hosts} "
        [ -n "$known_hosts" ] && opts=$(grep -Eoh -e '^\w+' -e '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' ${known_hosts})
        COMPREPLY=($(compgen -W "${opts}" "${cur}"))
}
complete -F _ssh_hosts ssh

# Console completion
_console_hosts()
{
        local prev cur opts
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        cur="${COMP_WORDS[COMP_CWORD]}"
        [ -r /etc/conserver.d ] && opts=$(awk '$1 ~ /^console/ {print $2}' /etc/conserver.d/conserver_*)
        COMPREPLY=($(compgen -W "${opts}" "${cur}"))
}

# If admin box console tab complete
if [ -d /etc/conserver.d ] ; then
        complete -F _console_hosts console
fi
#export P4CONFIG=.p4rc
#export P4PASSWD=$(<$HOME/.p4passwd)
export PS1="[\u@\h:\w]$ "
export PATH=$GOROOT/bin:/usr/local/sbin/:/sbin:/bin:/usr/bin:/usr/local/bin:$PATH

#For SSH-Agent
# SSHAGENT=/usr/bin/ssh-agent
# SSHAGENTARGS="-s"
# if [ -z "$SSH_AUTH_SOCK" -a -x "$SSHAGENT" ]; then
#         eval `$SSHAGENT $SSHAGENTARGS`
#         trap "kill $SSH_AGENT_PID" 0
#         ssh-add
# fi
# For ssh-agent
r ()
{
      if [[ -n $TMUX ]]
       then
         NEW_SSH_AUTH_SOCK=`tmux showenv|grep '^SSH_AUTH_SOCK' |cut -d = -f 2`
             if [[ -n $NEW_SSH_AUTH_SOCK ]] && [[ -S $NEW_SSH_AUTH_SOCK ]]
               then
                SSH_AUTH_SOCK=$NEW_SSH_AUTH_SOCK
             fi
     fi
}


# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# export the site to a variable
if [ -r /etc/fds/info ] ; then
     SITE=$(sed -rn 's/site_code=([a-Z]*)/\1/p' /etc/fds/info |head -n1)
fi

# Enable bash completion
#_interactive && {
if [ -r /etc/bash_completion ] ; then
	source /etc/bash_completion
elif [ -r $HOME/bash_completion ] ; then
	source $HOME/bash_completion
fi
#}

# Set LS_COLORS
if _have dircolors ; then
	if [ -r $HOME/.dir_colors ] ; then
		eval `dircolors -b $HOME/.dir_colors`
	else
		eval `dircolors -b`
	fi
fi

# Default to vim if vim exists
if _have vim ; then
	alias vi='vim'
	export EDITOR='vim'
	export VISUAL='vim'
else
	export EDITOR='vi'
	export VISUAL='vi'
fi

# Show grep in color
alias java8='export JAVA_HOME=`/usr/libexec/java_home -v 1.8`'
alias java.='unset JAVA_HOME'
alias grep='grep --color=auto'
alias sudo='sudo '
alias view='vim -R '
alias sshn='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias scpn='scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

# Set HOST_NAME environment variable
export HOST_NAME=$(uname -n | cut -d . -f 1)

# OS specific settings
case $OS_TYPE in
	Linux)
		alias ls='ls --color=auto'
		;;
	CYGWIN*)
		alias ls='ls --color=auto'
		;;
	Darwin)
		alias ls='ls -G'
		export CLICOLOR=1
		ulimit -n 4096
		;;
	FreeBSD)
		alias ls='ls -G'
		export CLICOLOR=1
		;;
esac

# Dynamic prompt and auto reset of ssh agent if in tmux
if [[ -n $TMUX ]] ; then
	PROMPT_COMMAND='_prompt_builder; ' #reset_ssh_agent;'
else
	PROMPT_COMMAND='_prompt_builder;'
fi

# Prompt builder
_prompt_builder()
{
	local exitstatus=$?
	local userprompt continueprompt title pwdcolor exitcode
	# Change prompt if root or sudoed
	if [ $USER = 'root' ] ; then
		userprompt="${C01}#"
		continueprompt="${C01}>>"
	elif [ -z $SUDO_USER ] ; then
		userprompt="${C04}>"
		continueprompt="${C04}>>"
	else
		userprompt="${C03}$"
		continueprompt="${C03}>>"
	fi
	# Change title to include user if sudoed
	if [ -z $SUDO_USER ] ; then
		title="$HOST_NAME"
	else
		title="$USER@$HOST_NAME"
	fi
	# Change working directory color if writable
	if [ -w "$PWD" ] ; then
		pwdcolor="${C03}"
	else
		pwdcolor="${C05}"
	fi
	# Show exit status if not zero
	if [ $exitstatus -ne 0 ] ; then
		exitcode="${C01}[${exitstatus}]"
	else
		exitcode=""
	fi
        _set_color $title       

	PS1="${CRESET}${C04}\D{%Y-%m-%dT%H:%M:%S%z}\n${C07}[${prompt_color}\u${C04}@${C02}\h${C04}:${pwdcolor}\w${C07}]${exitcode}${userprompt}${CRESET} "
	PS2="${CRESET}${continueprompt}${CRESET} "
	# Change title
	_set_title $title
}

# Change screen/tmux window and xterm/rxvt title names
_set_color()
{
        if [ -n "$1" ] ; then
                case $TERM in
                        screen*)
                               prompt_color="${C02}"
                                ;;
                        xterm*|rxvt*)
                               prompt_color="${C01}"
                               ;;
                esac
        fi
}

# Change screen/tmux window and xterm/rxvt title names
_set_title()
{
	if [ -n "$1" ] ; then
		case $TERM in
			screen*)
				echo -ne "\ek$1\e\\"
				;;
	#		xterm*|rxvt*)
	#			echo -ne "\e]0;$1\a"
	#			;;
		esac
	fi
}

# Start SSH agent
#start_ssh_agent()
#{
#	if [ -z $SSH_AUTH_SOCK ] || [ ! -S $SSH_AUTH_SOCK ] ; then
#		eval `ssh-agent -s`
#		trap "kill $SSH_AGENT_PID" 0
#		ssh-add
#	fi
#}

# Reset SSH agent after detaching and reattaching tmux
#reset_ssh_agent()
#{
#	if [[ -n $TMUX ]] && [[ ! -S $SSH_AUTH_SOCK ]] ; then
#		local new_ssh_auth_sock=$(tmux showenv | grep '^SSH_AUTH_SOCK' | cut -d = -f 2)
#		if [[ -n $new_ssh_auth_sock ]] && [[ -S $new_ssh_auth_sock ]] ; then
#			SSH_AUTH_SOCK=$new_ssh_auth_sock
#		fi
#	fi
#}

# Function for extracting files
extract() {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)	tar xvjf $1	;;
			*.tar.gz)	tar xvzf $1	;;
			*.bz2)		bunzip2 $1	;;
			*.rar)		unrar x $1	;;
			*.gz)		gunzip $1	;;
			*.tar)		tar xvf $1	;;
			*.tbz2)		tar xvjf $1	;;
			*.tgz)		tar xvzf $1	;;
			*.zip)		unzip $1	;;
			*.Z)		uncompress $1	;;
			*.7z)		7z x $1		;;
			*)	echo "Uknown Archive Type for '$1'"; return 2 ;;
		esac
	else
		echo "File Not Found '$1'"
		return 1
	fi
}
complete -f -X '!*.@(tar.bz2|tar.gz|bz2|rar|gz|tar|tbz2|tgz|zip|Z|7z)' extract

# Shim for sudo to change TITLE and TERM
#_have sudo && {
# Set sudo path env variable
#[ -z $SUDO_PATH ] && readonly SUDO_PATH=$(command -v sudo)
#sudo_shim()
#{
#	local params suser oldterm title exitstatus
#	params=$@
	#suser=$(echo $params | grep -Eo '\-u [a-z0-9_-]+' | cut -d ' ' -f 2 | head -n 1)
#	oldterm=$TERM
	# Change title to include user if sudoed
	#if [ -z $suser ] ; then
#		title="root@$HOST_NAME"
	#else
	#	title="$suser@$HOST_NAME"
	#fi
	# Change title
#	_set_title $title
	# Set TERM to xterm
#	TERM='xterm'
	# Execute sudo
	#if [[ -n $SUDO_PATH ]] && [[ -x $SUDO_PATH ]] ; then
#		$SUDO_PATH $params
#		exitstatus=$?
	#fi
	# Reset TERM to old TERM
#	TERM=$oldterm
#	return $exitstatus
#}
#alias sudo='sudo_shim'
#}

# Include .bashrc-env if it exists for environment specific settings
#[ -r $HOME/.bashrc-env ] && source $HOME/.bashrc-env

unset -f _have
unset -f _interactive
unset -f _pathedit

export SSH_AUTH_SOCK=$HOME/.ssh/auth_socks/ssh_auth_sock.`uname -n`

#export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

export NVM_DIR="/home/user/clancaster/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
