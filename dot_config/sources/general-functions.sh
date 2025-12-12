replace-all() {
  FROM=$1
  TO=$2
  PWD=$(pwd)

  echo "Replacing all instances of <${FROM}> with <${TO}> in ${PWD}..."
  find ./ -type f -exec sed -i -e "s/$FROM/$TO/g" {} \;
}

awssh() {
  if [[ -z $1 ]]; then
    echo "Please provide a profile."
  else
    aws-vault exec $1 -- zsh
  fi
}

####################################################
# Quickly find files in default locations
####################################################
ff() {
	local search_root=${1%/}
	local maxdepth=""
	shift

	if [[ $# -gt 0 && $1 == --maxdepth=* ]]; then
		maxdepth=${1#--maxdepth=}
		shift
	fi

	local filter_args=("$@")
	local find_cmd=(find "$search_root" -mindepth 1)
	if [[ -n $maxdepth ]]; then
		find_cmd+=(-maxdepth "$maxdepth")
	fi
	find_cmd+=(-type d)

	local sed_prefix="$search_root/"
	local selected
	selected=$(
		"${find_cmd[@]}" 2>/dev/null | \
			sed "s|^${sed_prefix}||" | \
			{ if [[ ${#filter_args[@]} -gt 0 ]]; then
				fzf --filter "$(printf "%s " "${filter_args[@]}")" | head -1
			  else
				fzf --tmux
			  fi
			}
	)

	if [[ -n $selected ]]; then
		selected="$search_root/$selected"
		cd "$selected"
	fi
}

fw() {
	ff "$HOME/git/work" "$@"
}

fp() {
	ff "$HOME/git/personal" "$@"
}

fh() {
	ff "$HOME" --maxdepth=5 "$@"
}

h() {
	fh "$@"
}

f() {
	fw "$@"
}
