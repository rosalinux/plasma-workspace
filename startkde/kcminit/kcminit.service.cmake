[Unit]
Description=KDE Config Module Initialization
#kded.service kactivitymanagerd.service

[Service]
ExecStart=@CMAKE_INSTALL_FULL_BINDIR@/kcminit_startup
Restart=no
Type=forking

[Install]
Alias=plasma-workspace.service
