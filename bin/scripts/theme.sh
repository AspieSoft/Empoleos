#!/bin/bash

source ./bin/common.sh

#todo: change github repo and folders for theme
#todo: use new "addPkg" and "rmPkg" methods

# setup theme
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git
sudo sed -r -i 's/(\s*)dnf\s*install(\s*)/\1dnf -y install\2/m' "Fluent-gtk-theme/install.sh"
sudo bash Fluent-gtk-theme/install.sh --theme all --dest /usr/share/themes --size standard --icon zorin --tweaks round noborder
rm -rf Fluent-gtk-theme

git clone https://github.com/ZorinOS/zorin-icon-themes.git
for filename in zorin-icon-themes/Zorin*; do
  sudo cp zorin-icon-themes/LICENSE "$filename"
done
sudo cp -r zorin-icon-themes/Zorin* /usr/share/icons
rm -rf zorin-icon-themes

sudo tar -xvzf ./assets/sounds/sounds.tar.gz -C /usr/share/sounds
sudo mkdir -p /usr/share/backgrounds/aspiesoft
sudo tar -xvzf ./assets/backgrounds/aspiesoft.tar.gz -C /usr/share/backgrounds/aspiesoft
sudo cp ./assets/backgrounds/aspiesoft.xml /usr/share/gnome-background-properties

gsettings set org.gnome.desktop.interface gtk-theme "Fluent-round-Dark"
gsettings set org.gnome.desktop.interface icon-theme "ZorinBlue-Dark"
gsettings set org.gnome.desktop.sound theme-name "zorin-pokemon"
gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/aspiesoft/blue.webp"
gsettings set org.gnome.desktop.background picture-uri-dark "file:///usr/share/backgrounds/aspiesoft/black.webp"

gsettings set org.gnome.mutter center-new-windows "true"
gsettings set org.gnome.mutter attach-modal-dialogs "false"
gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"

sudo pip3 install --upgrade git+https://github.com/essembeh/gnome-extensions-cli

gext disable background-logo@fedorahosted.org

gext -F install arcmenu@arcmenu.com
gext -F install dash-to-panel@jderose9.github.com
gext -F install vertical-workspaces@G-dH.github.com
gext -F install user-theme@gnome-shell-extensions.gcampax.github.com
gext -F install gnome-ui-tune@itstime.tech

#todo: determine which of these is compatable per pc and desktop
gext -F install ding@rastersoft.com
gext -F install gtk4-ding@smedius.gitlab.com

gext -F install drive-menu@gnome-shell-extensions.gcampax.github.com
gext -F install date-menu-formatter@marcinjakubowski.github.com
gext -F install batterytime@typeof.pw
#gext -F install ControlBlurEffectOnLockScreen@pratap.fastmail.fm
gext -F install screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com
gext -F install gestureimprovements@gestures
gext -F install just-perfection-desktop@just-perfection

gext -F install sane-airplane-mode@kippi

gext -F install printers@linux-man.org
gext -F install clipboard-indicator@tudmotu.com

gext -F install burn-my-windows@schneegans.github.com
gext -F install compiz-alike-magic-lamp-effect@hermes83.github.com

gext -F install Vitals@CoreCoding.com
gext disable Vitals@CoreCoding.com

gext -F install allowlockedremotedesktop@kamens.us
gext disable allowlockedremotedesktop@kamens.us

gext -F install espresso@coadmunkee.github.com
gext disable espresso@coadmunkee.github.com

gext enable appindicatorsupport@rgcjonas.gmail.com

# fix keyboard shortcuts
dconf reset /org/gnome/desktop/wm/keybindings/switch-to-workspace-up
dconf reset /org/gnome/desktop/wm/keybindings/switch-to-workspace-down
dconf reset /org/gnome/desktop/wm/keybindings/switch-to-workspace-left
dconf reset /org/gnome/desktop/wm/keybindings/switch-to-workspace-right

dconf reset /org/gnome/desktop/wm/keybindings/move-to-workspace-up
dconf reset /org/gnome/desktop/wm/keybindings/move-to-workspace-down
dconf reset /org/gnome/desktop/wm/keybindings/move-to-workspace-left
dconf reset /org/gnome/desktop/wm/keybindings/move-to-workspace-right

dconf reset /org/gnome/desktop/wm/keybindings/move-to-monitor-up
dconf reset /org/gnome/desktop/wm/keybindings/move-to-monitor-down
dconf reset /org/gnome/desktop/wm/keybindings/move-to-monitor-left
dconf reset /org/gnome/desktop/wm/keybindings/move-to-monitor-right

dconf reset /org/gnome/desktop/wm/keybindings/maximize
dconf reset /org/gnome/desktop/wm/keybindings/unmaximize
dconf reset /org/gnome/desktop/wm/keybindings/toggle-tiled-left
dconf reset /org/gnome/desktop/wm/keybindings/toggle-tiled-left

dconf write /org/gnome/desktop/wm/keybindings/move-to-monitor-up "['']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-monitor-down "['']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-monitor-left "['']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-monitor-right "['']"

dconf write /org/gnome/desktop/wm/keybindings/maximize "['']"
dconf write /org/gnome/desktop/wm/keybindings/unmaximize "['']"
dconf write /org/gnome/desktop/wm/keybindings/toggle-tiled-left "['']"
dconf write /org/gnome/desktop/wm/keybindings/toggle-tiled-left "['']"

dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-up "['<Super>Up']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-down "['<Super>Down']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-left "['<Super>Left']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-right "['<Super>Right']"

dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-up "['<Shift><Super>Up']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-down "['<Shift><Super>Down']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-left "['<Shift><Super>Left']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-right "['<Shift><Super>Right']"

# setup arcmenu
gsettings --schemadir ~/.local/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas/ set org.gnome.shell.extensions.arcmenu arcmenu-extra-categories-links "[(0, false), (1, true), (2, false), (3, false), (4, true)]"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas/ set org.gnome.shell.extensions.arcmenu custom-menu-button-icon-size "24.0"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas/ set org.gnome.shell.extensions.arcmenu directory-shortcuts-list "[['Computer', 'drive-harddisk-symbolic', 'ArcMenu_Computer'], ['Home', 'user-home-symbolic', 'ArcMenu_Home'], ['Documents', '. GThemedIcon folder-documents-symbolic folder-symbolic folder-documents folder', 'ArcMenu_Documents'], ['Downloads', '. GThemedIcon folder-download-symbolic folder-symbolic folder-download folder', 'ArcMenu_Downloads'], ['Pictures', '. GThemedIcon folder-pictures-symbolic folder-symbolic folder-pictures folder', 'ArcMenu_Pictures'], ['Videos', '. GThemedIcon folder-videos-symbolic folder-symbolic folder-videos folder', 'ArcMenu_Videos'], ['Music', '. GThemedIcon folder-music-symbolic folder-symbolic folder-music folder', 'ArcMenu_Music']]"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas/ set org.gnome.shell.extensions.arcmenu extra-categories "[(0, false), (1, false), (3, true), (4, false), (2, true)]"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas/ set org.gnome.shell.extensions.arcmenu hide-overview-on-startup "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas/ set org.gnome.shell.extensions.arcmenu enable-menu-hotkey "false"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas/ set org.gnome.shell.extensions.arcmenu application-shortcuts-list "[['Software', 'org.gnome.Software', 'ArcMenu_Software'], ['Settings', 'org.gnome.Settings', 'org.gnome.Settings.desktop'], ['Terminal', 'org.gnome.Terminal', 'org.gnome.Terminal.desktop'], ['System Monitor', 'org.gnome.SystemMonitor', 'gnome-system-monitor.desktop']]"

# setup dash to panel
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/ set org.gnome.shell.extensions.dash-to-panel hide-overview-on-startup "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/ set org.gnome.shell.extensions.dash-to-panel intellihide "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/ set org.gnome.shell.extensions.dash-to-panel intellihide-behaviour "ALL_WINDOWS"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/ set org.gnome.shell.extensions.dash-to-panel intellihide-hide-from-windows "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/ set org.gnome.shell.extensions.dash-to-panel intellihide-only-secondary "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/ set org.gnome.shell.extensions.dash-to-panel isolate-monitors "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/ set org.gnome.shell.extensions.dash-to-panel isolate-workspaces "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/ set org.gnome.shell.extensions.dash-to-panel panel-element-positions '{"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],"1":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/ set org.gnome.shell.extensions.dash-to-panel dot-style-unfocused "DOTS"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/ set org.gnome.shell.extensions.dash-to-panel panel-sizes '{"0":42,"1":42}'

# setup vertical workspaces
gsettings --schemadir ~/.local/share/gnome-shell/extensions/vertical-workspaces@G-dH.github.com/schemas/ set org.gnome.shell.extensions.vertical-workspaces fix-ubuntu-dock "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/vertical-workspaces@G-dH.github.com/schemas/ set org.gnome.shell.extensions.vertical-workspaces hot-corner-action "0"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/vertical-workspaces@G-dH.github.com/schemas/ set org.gnome.shell.extensions.vertical-workspaces overview-bg-blur-sigma "10"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/vertical-workspaces@G-dH.github.com/schemas/ set org.gnome.shell.extensions.vertical-workspaces search-fuzzy "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/vertical-workspaces@G-dH.github.com/schemas/ set org.gnome.shell.extensions.vertical-workspaces blur-transitions "true"

# setup desktop icons
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ding@rastersoft.com/schemas/ set org.gnome.shell.extensions.ding show-drop-place "false"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ding@rastersoft.com/schemas/ set org.gnome.shell.extensions.ding show-home "false"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ding@rastersoft.com/schemas/ set org.gnome.shell.extensions.ding show-volumes "false"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/ding@rastersoft.com/schemas/ set org.gnome.shell.extensions.ding use-nemo "true"
# gtk4
gsettings --schemadir ~/.local/share/gnome-shell/extensions/gtk4-ding@smedius.gitlab.com/schemas/ set org.gnome.shell.extensions.gtk4-ding show-drop-place "false"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/gtk4-ding@smedius.gitlab.com/schemas/ set org.gnome.shell.extensions.gtk4-ding show-home "false"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/gtk4-ding@smedius.gitlab.com/schemas/ set org.gnome.shell.extensions.gtk4-ding show-second-monitor "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/gtk4-ding@smedius.gitlab.com/schemas/ set org.gnome.shell.extensions.gtk4-ding use-nemo "true"

# setup burn my windows
rm -rf "$HOME/.config/burn-my-windows/profiles"
mkdir -p "$HOME/.config/burn-my-windows/profiles"
sudo cp ./assets/extensions/burn-my-windows.conf "$HOME/.config/burn-my-windows/profiles"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/burn-my-windows@schneegans.github.com/schemas/ set org.gnome.shell.extensions.burn-my-windows active-profile "$HOME/.config/burn-my-windows/profiles/burn-my-windows.conf"

# setup date formatter
gsettings --schemadir ~/.local/share/gnome-shell/extensions/date-menu-formatter@marcinjakubowski.github.com/schemas/ set org.gnome.shell.extensions.date-menu-formatter apply-all-panels "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/date-menu-formatter@marcinjakubowski.github.com/schemas/ set org.gnome.shell.extensions.date-menu-formatter pattern "EEE, MMM d  h:mm aaa"

# setup printers
gsettings --schemadir ~/.local/share/gnome-shell/extensions/printers@linux-man.org/schemas/ set org.gnome.shell.extensions.printers show-icon "When printing"

# setup just perfection
gsettings --schemadir ~/.local/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection hot-corner "false"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection startup-status "0"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection workspace-wrap-around "true"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas/ set org.gnome.shell.extensions.just-perfection window-demands-attention-focus "false"

# disable auto airplane mode
gsettings --schemadir ~/.local/share/gnome-shell/extensions/sane-airplane-mode@kippi/schemas/ set org.gnome.shell.extensions.sane-airplane-mode enable-airplane-mode "false"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/sane-airplane-mode@kippi/schemas/ set org.gnome.shell.extensions.sane-airplane-mode enable-bluetooth "false"

# setup user theme
gsettings --schemadir ~/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com/schemas/ set org.gnome.shell.extensions.user-theme name "Fluent-round-Dark"

# other config options
gsettings set org.gnome.TextEditor restore-session "false"


sudo cp -rf "$HOME/.local/share/gnome-shell/extensions" "/etc/skel/.local/share/gnome-shell/extensions"
