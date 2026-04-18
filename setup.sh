#! /bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

PATH=$PATH:$HOME/.local/bin

packages=(
  "app|curl -sL https://hkdb.github.io/app/getapp.sh | bash"
  "neovim|"
  "npm|"
  "tree-sitter-cli|npm install -g tree-sitter-cli"
)



import_configs(){
	local path="$XDG_CONFIG_HOME"

	if [ -z $path ]; then
		mkdir -p ~/.config
		path=$HOME/.config
	fi
	
	for dir in configs/*/; do
		cp -r $dir $path
	done
}	

install() {
  local name="$1"
  local cmd="$2"

  if [ -z "$cmd" ]; then
    yes | app install "$name" > /dev/null
  else
    eval "$cmd"
  fi

  if [ $? -ne 0 ]; then
    echo "Failed to install package \"$name\"" >&2
  else
    echo "Installed \"$1\""
  fi

	
}

check_and_install() {
  local name="$1"
  local cmd="$2"

  echo -n "Package $name "

  if command -v "$name" >/dev/null 2>&1; then
    echo "already installed"
    return
  fi

  echo "not installed, installing..."
  install "$name" "$cmd"
}

for entry in "${packages[@]}"; do
  IFS="|" read -r name install_cmd <<< "$entry"
  check_and_install "$name" "$install_cmd"
done

import_configs
