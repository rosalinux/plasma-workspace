[Unit]
Description=KSplash "ready" Stage
Wants=plasma-core.target
After=plasma-core.target

[Service]
Type=oneshot
ExecStart=@QtBinariesDir@/qdbus org.kde.KSplash /KSplash org.kde.KSplash.setStage ready

# [Install]
# WantedBy=plasma-workspace.target
