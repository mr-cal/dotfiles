function good-morning --description 'Switch to the Gruvbox Material Dark Soft theme'
    ln -sf ~/.config/kitty/gruvbox-material-dark-soft.conf ~/.config/kitty/current-theme.conf
    and ln -sf gruvbox-material-dark-soft.toml ~/.config/helix/themes/current.toml
    and pkill -USR1 -x kitty
    and gsettings set org.gnome.desktop.interface color-scheme prefer-light
    and gsettings set org.gnome.desktop.interface gtk-theme Adwaita
end
