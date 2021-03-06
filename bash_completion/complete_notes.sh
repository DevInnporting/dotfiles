function _notes {
  configFile="$HOME/.notes.cfg"
  source $configFile # relies on the config file being already in place for the completion
                     #  script to work properly. Ensure correct placement in the dotfiles
                     #  configuration script
  local cur prev opts notes
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  opts="search list show create open edit delete report"
  notes=$(ls $notesDir | sed -e 's/\..*$//')

  case "${prev}" in
    open|edit|delete|show)
      COMPREPLY=( $(compgen -W "${notes}" -- ${cur}) )
      return 0
      ;;
    search|list|create|report)
      return 0
      ;;
    *)
      ;;
  esac

  COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  # completes the options
  return 0
}
complete -F _notes notes
