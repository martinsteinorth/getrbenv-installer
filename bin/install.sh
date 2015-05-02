#!/usr/bin/env bash
######### DEFAULTS #########

DEFAULT_RBENV_REPO=https://github.com/sstephenson/rbenv.git
DEFAULT_HOME_DIR=$HOME
DEFAULT_INSTALL_DIR=$DEFAULT_HOME_DIR"/.rbenv"
RUBY_BUILD_PLUGIN="sstephenson/ruby-build"

POSSIBLE_SHELL_CONFIG_FILES=(
  ".profile"
  ".bash_profile"
  ".bashrc"
  ".zshrc"
)

SUPPORTED_RBENV_PLUGINS=(
  $RUBY_BUILD_PLUGIN
  "sstephenson/rbenv-vars"
  "sstephenson/rbenv-gem-rehash"
  "sstephenson/rbenv-default-gems"
  "tpope/rbenv-aliases"
  "tpope/rbenv-communal-gems"
  "chriseppstein/rbenv-each"
  "rkh/rbenv-update"
  "rkh/rbenv-use"
  "rkh/rbenv-whatis"
  "mislav/rbenv-user-gems"
  "jf/rbenv-gemset"
)

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

######### FUNCTIONS #########

array_contains_value()
{
  haystack=(${!1})
  needle=$2
  for value in ${haystack[@]}
  do
    if [ $value == $needle ]
    then
      return 0
      break
    fi
  done
  return 1
}

set_user_flags()
{
  print_info "Checking your options"
  install_dir=$DEFAULT_INSTALL_DIR
  rubies=()
  global_ruby=""
  shell_ruby=""
  local_ruby_combinations=()
  plugins=()

  while
  (( $# > 0 ))
  do
    option="$1"
    shift
    value="$1"
    user_flag_error=0

    case "$option" in
      (--install-dir)
        if [[ -n "${value:-}" ]] && ! [ "${value:0:1}" == "-" ]
        then
          install_dir=${value%/}
          shift
        else
          print_err "--install-dir must be followed by a path."
          user_flag_error=1
        fi
        ;;
      (--rubies)
        if [[ -n "${value:-}" ]] && ! [ "${value:0:1}" == "-" ]
        then
          IFS=, read -r -a rubies <<< "$value"
          shift
        else
          print_err "--rubies must be followed by a valid ruby version. Visit https://github.com/sstephenson/ruby-build/tree/master/share/ruby-build for a comprehensive list of all available rubies."
          user_flag_error=1
        fi
        ;;
      (--global-ruby)
        if [[ -n "${value:-}" ]] && ! [ "${value:0:1}" == "-" ]
        then
          global_ruby="$value"
          shift
        else
          print_err "--global-ruby must be followed by a valid ruby version that is installed on your system and managed by rbenv. Therefore you might want to specify a Ruby Version to be installed. You can do that by using the --rubies option. Visit https://github.com/sstephenson/ruby-build/tree/master/share/ruby-build for a comprehensive list of all available rubies."
          user_flag_error=1
        fi
        ;;
      (--local-rubies)
        if [[ -n "${value:-}" ]] && ! [ "${value:0:1}" == "-" ]
        then
          user_local_ruby_combinations=()
          IFS=, read -r -a user_local_ruby_combinations <<< "$value"
          shift
        else
          print_err "--local-rubies must be followed by a valid ruby version and accessible directory in the form <version>@<directory>. If you want to specify more than one local ruby you can concatenate using a comma (,)"
          user_flag_error=1
        fi
        ;;
    (--plugins)
      if [[ -n "${value:-}" ]] && ! [ "${value:0:1}" == "-" ]
      then
        IFS=, read -r -a user_plugins <<< "$value"

        for user_plugin in ${user_plugins[@]}
        do
          if array_contains_value SUPPORTED_RBENV_PLUGINS[@] $user_plugin
          then
            if ! array_contains_value plugins[@] $user_plugin
            then
              plugins+=($user_plugin)
            fi
          else
            print_err "Plugin ${user_plugin} is not supported."
            user_flag_error=1
          fi
        done

        if ! array_contains_value plugins[@] $RUBY_BUILD_PLUGIN
        then
          plugins+=($RUBY_BUILD_PLUGIN)
        fi

        shift
      else
        print_err "--plugins must be followed by a valid rbenv plugin name. You can provide more than one plugin by separating the names with a comma (,)."
        user_flag_error=1
      fi
      ;;
      (*)
        print_err "Unknown option: $option"
        user_flag_error=1
        ;;
    esac
  done

  if [[ $user_flag_error -eq 1 ]]
  then
    usage
    print_err "Aborted."
    exit 1
  fi
}

is_git_installed()
{
  if hash git 2>/dev/null
  then
    return 0
  else
    return 1
  fi
}

check_git()
{
  print_info "Checking for git"
  if ! is_git_installed
  then
    print_err "Cannot find git. Be sure that git is installed and properly accessible. Aborting."
    exit 1
  fi
}

clone_rbenv()
{
  print_info "Cloning rbenv to $install_dir"
  git clone -q $DEFAULT_RBENV_REPO $install_dir 2>/dev/null
}

init_rbenv()
{
  eval "$(rbenv init -)"
}

install_rubies()
{
  if [ ${#rubies[@]} -gt 0 ]
  then
    for ruby_version in ${rubies[@]}
    do
      print_info "Installing ${ruby_version}. This can take a while, so be patient."
      rbenv install ${ruby_version}
    done
  fi
}

install_plugins(){
  for plugin in ${plugins[@]}
  do
    plugin_name=${plugin#*/}
    plugin_directory="${install_dir}/plugins/${plugin_name}"

    if [ ! -d $plugin_directory ]
    then
      print_info "Cloning ${plugin} to ${plugin_directory}"
      git clone -q https://github.com/${plugin} ${plugin_directory} 2>/dev/null
    else
      print_err "${plugin_directory} already exists"
    fi
  done
}

set_global_ruby()
{
  if test -n "$global_ruby"
  then
    print_info "Setting global ruby to ${global_ruby}"
    rbenv global ${global_ruby}
  fi
}

set_local_rubies()
{
  for user_local_ruby_combination in ${user_local_ruby_combinations[@]}
  do
    IFS=@ read -r -a user_local_ruby_combination_splitted <<< "$user_local_ruby_combination"
    version=${user_local_ruby_combination_splitted[0]}
    directory=${user_local_ruby_combination_splitted[1]%/}

    if [[ -n $version ]] && [[ -n $directory ]] && [[ -w $directory ]]
    then
      print_info "Setting local ruby at ${directory} to ${version}"
      cd $directory
      rbenv local $version
    else
      print_err "Unable to set a local ruby to ${user_local_ruby_combination}"
    fi
  done
}

write_exports_to_shell_config_files()
{
  print_info "Writing rbenv configuration to shell config files"
  for file in ${available_shell_config_files[@]}
  do
    echo "export RBENV_ROOT=${install_dir}" >> $DEFAULT_HOME_DIR/$file
    echo "export PATH=${install_dir}/bin:$PATH" >> $DEFAULT_HOME_DIR/$file
    echo 'eval "$(rbenv init -)"' >> $DEFAULT_HOME_DIR/$file

    export RBENV_ROOT=${install_dir}
    export PATH=${install_dir}/bin:$PATH
    eval "$(rbenv init -)"
  done
}

detect_shell_config_files()
{
  available_shell_config_files=()

  for file in ${POSSIBLE_SHELL_CONFIG_FILES[@]}
  do
    if [ -f $DEFAULT_HOME_DIR/$file ]
    then
      available_shell_config_files+=($file)
    fi
  done
}

print_info()
{
  echo -e "* ${COL_CYAN}${1}${COL_RESET}"
}

print_err()
{
  echo -e "* ${COL_RED}${1}${COL_RESET}"
}

print_success()
{
  echo -e "* ${COL_GREEN}${1}${COL_RESET}"
}

usage()
{
  echo "Usage instructions tbd"
}

run()
{
  set_user_flags "$@"
  detect_shell_config_files
  check_git
  clone_rbenv
  write_exports_to_shell_config_files
  install_plugins
  install_rubies
  set_global_ruby
  set_local_rubies
  print_success "All done! Restart your shell for all changes to take effect. Enjoy!"
}

run "$@"
