function good-evening --description 'Switch to the Gruvbox Material Dark Medium theme'
    ln -sf ~/.config/kitty/gruvbox-material-dark-medium.conf ~/.config/kitty/current-theme.conf
    and ln -sf gruvbox-material-dark-medium.toml ~/.config/helix/themes/current.toml
    and pkill -USR1 -x kitty
    and gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    and gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
end
