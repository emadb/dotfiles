#!/bin/bash

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
FILES=~/dotfiles/files/*

echo "listing $FILES"

for f in $FILES; do
    echo "Copying $f  to ~ "
    #cp ~/$dir/.$file ~           
done