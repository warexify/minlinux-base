# check whether it is WSL1 for WSL2 by using gcc version kernel built with
# check whether we have wsl.exe in path
if ( which wsl.exe >/dev/null ) && ( $(which wsl.exe) -l -v >/dev/null ) && [ $(wsl.exe -l -v 2>&1 |sed -e "s|\r||g" -e "s|\x00||g" | grep ${WSL_DISTRO_NAME} | awk '{print $3}') -eq 2 ]; then
  # enable external x display for WSL 2

  ipconfig_exec=$(wslpath "C:\\Windows\\System32\\ipconfig.exe")
  if ( which ipconfig.exe >/dev/null ); then
    ipconfig_exec=$(which ipconfig.exe)
  fi

  wsl2_d_tmp="$(eval "$ipconfig_exec" | grep -n "Default Gateway.*: [0-9]" | cut -d : -f 1)"
  wsl2_d_tmp="$(eval "$ipconfig_exec" | sed ''"$(expr $wsl2_d_tmp - 4)"','"$(expr $wsl2_d_tmp + 0)"'!d' | grep IPv4 | cut -d : -f 2 | sed -e "s|\s||g" -e "s|\r||g")"
  export DISPLAY=$wsl2_d_tmp:0.0

  unset wsl2_d_tmp
else
  # enable external x display for WSL 1
  export DISPLAY=:0
fi

# enable external libgl
export LIBGL_ALWAYS_INDIRECT=1

# speed up some GUI apps like gedit
export NO_AT_BRIDGE=1

# Fix 'clear' scrolling issues
alias clear='clear -x'

# Custom aliases
alias ll='ls -al'

# Check if we have Windows Path
if ( which cmd.exe >/dev/null ); then

  # Execute on user's shell first-run
  if [ ! -f "${HOME}/.firstrun" ]; then
    echo "Welcome to Pengwin. Type 'pengwin-setup' to run the setup tool. You will only see this message on the first run."
    touch "${HOME}/.firstrun"
  fi

  if ( ! wslpath 'C:\' > /dev/null 2>&1 ); then
    alias wslpath=legacy_wslupath
  fi

  # Create a symbolic link to the windows home
  wHomeWinPath=$(cmd-exe /c 'echo %HOMEDRIVE%%HOMEPATH%' | tr -d '\r')
  export WIN_HOME=$(wslpath -u "${wHomeWinPath}")

  win_home_lnk=${HOME}/winhome
  if [ ! -e "${win_home_lnk}" ] ; then
    ln -s -f "${WIN_HOME}" "${win_home_lnk}"
  fi

fi
