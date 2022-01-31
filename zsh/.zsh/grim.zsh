export GRIM_DEFAULT_DIR="$HOME/screenshots"

if [ ! -d $GRIM_DEFAULT_DIR ]; then
	mkdir -p $GRIM_DEFAULT_DIR
fi

alias sshot='grim -g "$(slurp)"'
