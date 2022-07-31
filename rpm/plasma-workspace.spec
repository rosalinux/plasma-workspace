%define devname %mklibname plasma-workspace -d

# filter qml/plugins provides
%global __provides_exclude_from ^(%{_kde5_qmldir}/.*\\.so|%{_qt5_plugindir}/.*\\.so)$

%global optflags %{optflags} -O3

Name: plasma-workspace
Version: 5.23.5
Release: 2
Source0: plasma-workspace-5.23.5.tar.gz
Source1: kde.pam
Source100: %{name}.rpmlintrc
# FIXME a forward port of this to the new C++ based startup tool
# may be necessary
#Patch0: plasma-workspace-5.9.0-startup-scripts.patch
#Patch1: plasma-workspace-5.3.2-no-lto-in-plasmashell.patch
Patch2: plasma-workspace-5.8.0-use-openmandriva-icon-and-background.patch
Summary: The KDE Plasma workspace
URL: http://kde.org/
License: GPL
Obsoletes: simplesystray < %{EVRD}
Group: Graphical desktop/KDE
BuildRequires: cmake(Breeze)
BuildRequires: cmake(KF5DocTools)
BuildRequires: cmake(KF5Activities)
BuildRequires: cmake(KF5CoreAddons)
BuildRequires: cmake(KF5Crash)
BuildRequires: cmake(KF5Solid)
BuildRequires: cmake(KF5Parts)
BuildRequires: cmake(KF5Activities)
BuildRequires: cmake(KF5TextEditor)
BuildRequires: cmake(KF5DBusAddons)
BuildRequires: cmake(KF5Declarative)
BuildRequires: cmake(KF5XmlGui)
BuildRequires: cmake(KF5FileMetaData)
BuildRequires: cmake(KF5KDELibs4Support)
BuildRequires: cmake(KF5Wayland)
BuildRequires: cmake(KF5NetworkManagerQt)
BuildRequires: cmake(KF5XmlRpcClient)
BuildRequires: cmake(KF5Wallet)
BuildRequires: cmake(KF5GlobalAccel)
BuildRequires: cmake(KF5People)
BuildRequires: cmake(KF5ActivitiesStats)
BuildRequires: cmake(Gettext)
BuildRequires: cmake(ECM)
BuildRequires: cmake(KF5KIO)
BuildRequires: cmake(KWinDBusInterface)
BuildRequires: cmake(KF5Activities)
BuildRequires: cmake(KF5Declarative)
BuildRequires: cmake(KF5Plasma)
BuildRequires: cmake(KF5PlasmaQuick)
BuildRequires: cmake(KF5Config)
BuildRequires: cmake(KF5Prison)
BuildRequires: cmake(Phonon4Qt5)
BuildRequires: cmake(KF5Runner)
BuildRequires: cmake(KF5JsEmbed)
BuildRequires: cmake(KF5NotifyConfig)
BuildRequires: cmake(KF5Su)
BuildRequires: cmake(KF5NewStuff)
BuildRequires: cmake(KF5KCMUtils)
BuildRequires: cmake(KF5IdleTime)
BuildRequires: cmake(KF5WebKit)
BuildRequires: cmake(KF5SysGuard)
BuildRequires: cmake(KF5Screen)
BuildRequires: cmake(KF5Baloo)
BuildRequires: cmake(KF5Prison)
BuildRequires: cmake(KScreenLocker)
BuildRequires: cmake(KF5Holidays)
BuildRequires: cmake(KDED)
BuildRequires: cmake(AppStreamQt)
BuildRequires: cmake(KF5Kirigami2)
BuildRequires: cmake(KF5QuickCharts)
BuildRequires: cmake(KUserFeedback)
BuildRequires: cmake(PlasmaWaylandProtocols)
BuildRequires: cmake(Qt5WaylandClient)
BuildRequires: cmake(LayerShellQt)
BuildRequires: cmake(Qt5XkbCommonSupport)
BuildRequires: cmake(packagekitqt5)
BuildRequires: qt5-qtwayland-private-devel
BuildRequires: pkgconfig(xkbcommon)
BuildRequires: pkgconfig(dbusmenu-qt5)
BuildRequires: pkgconfig(kscreen2)
BuildRequires: pkgconfig(libqalculate)
BuildRequires: pkgconfig(libgps) >= 3.15
BuildRequires: pkgconfig(libpipewire-0.3)
BuildRequires: pkgconfig(libdrm)
BuildRequires: pkgconfig(freetype2)
BuildRequires: pkgconfig(fontconfig)
BuildRequires: pkgconfig(xft)
BuildRequires: pkgconfig(phonon4qt5)
BuildRequires: pkgconfig(Qt5Concurrent)
BuildRequires: pkgconfig(Qt5Core)
BuildRequires: pkgconfig(Qt5DBus)
BuildRequires: pkgconfig(Qt5Gui)
BuildRequires: pkgconfig(Qt5Network)
BuildRequires: pkgconfig(Qt5Qml)
BuildRequires: pkgconfig(Qt5Quick)
BuildRequires: pkgconfig(Qt5QuickWidgets)
BuildRequires: pkgconfig(Qt5Script)
BuildRequires: pkgconfig(Qt5Sql)
BuildRequires: pkgconfig(Qt5Svg)
BuildRequires: pkgconfig(Qt5Test)
BuildRequires: pkgconfig(Qt5WebKit)
BuildRequires: pkgconfig(Qt5WebKitWidgets)
BuildRequires: pkgconfig(Qt5Widgets)
BuildRequires: pkgconfig(Qt5X11Extras)
BuildRequires: qt5-qtwayland
BuildRequires: pkgconfig(wayland-client)
BuildRequires: pkgconfig(wayland-scanner)
BuildRequires: pkgconfig(wayland-server)
BuildRequires: pkgconfig(wayland-egl)
BuildRequires: pkgconfig(x11)
BuildRequires: pkgconfig(xcb)
BuildRequires: pkgconfig(xcb-keysyms)
BuildRequires: pkgconfig(zlib)
BuildRequires: pkgconfig(libqalculate)
BuildRequires: pkgconfig(sm)
BuildRequires: pkgconfig(xcursor)
BuildRequires: pkgconfig(xtst)
BuildRequires: pkgconfig(xcb-util)
BuildRequires: pkgconfig(xcb-image)
BuildRequires: pam-devel
BuildRequires: pkgconfig(iso-codes)
Requires: qt5-qtquickcontrols >= 5.5.0
# External KF5 and Plasma 5 required packages
Requires: kquickcharts
Requires: kactivitymanagerd >= 5.6.0
Requires: kde-cli-tools
Requires: kded
Requires: kimageformats
Requires: kinit
Requires: kwallet5
Requires: plasma-framework
Requires: baloo5
# qtpaths is used by startkde
Requires: qt5-qttools >= 5.5.0
Requires: qt5-qttools-qtdbus >= 5.5.0
Requires: qt5-qtgraphicaleffects >= 5.5.0
# needed if anything will fail on startkde
Requires: xmessage
Requires: xprop
Requires: xset
Requires: xrdb
Requires: iso-codes
# needed for feedback module
Requires: kuserfeedback
# needed for backgrounds and patch 2
Requires: distro-release-theme
Provides: virtual-notification-daemon
Conflicts: kdebase4-workspace
Conflicts: kdebase-workspace
# We need to run on either X11 or Wayland...
Requires: %{name}-backend = %{EVRD}
# Because of pam file
Conflicts: kdm < 2:4.11.22-1.1
Conflicts: kio-extras < 15.08.0
Requires: kio-extras
Requires: kio-fuse
Obsoletes: kde-base-artwork < 15.08.3-3
Provides: kde-base-artwork = 15.08.3-3
Obsoletes: superkaramba < 15.08.3-3
Provides: superkaramba = 15.08.3-3
Obsoletes: %{mklibname superkaramba 4} < 15.08.3-3
Provides: %{mklibname superkaramba 4} = 15.08.3-3
Obsoletes: kactivities-workspace < 5.5.0-3
Provides: kactivities-workspace = 5.5.0-3
Obsoletes: %{mklibname legacytaskmanager 5} < 5.8.2
Provides: %{mklibname legacytaskmanager 5} = 5.8.2
Conflicts: plasma-desktop < 5.16.90

%description
The KDE Plasma workspace.

%libpackage kworkspace5 5

%libpackage plasma-geolocation-interface 5

%libpackage weather_ion 7

%libpackage taskmanager 6
%{_libdir}/libtaskmanager.so.5*

%libpackage colorcorrect 5

%libpackage notificationmanager 5
%{_libdir}/libnotificationmanager.so.1

%package -n %{devname}
Summary: Development files for the KDE Plasma workspace
Group: Development/KDE and Qt
Requires: %{mklibname kworkspace5 5} = %{EVRD}
Requires: %{mklibname plasma-geolocation-interface 5} = %{EVRD}
Requires: %{mklibname taskmanager 6} = %{EVRD}
Requires: %{mklibname weather_ion 7} = %{EVRD}
Requires: %{mklibname colorcorrect 5} = %{EVRD}
Requires: %{mklibname notificationmanager 5} = %{EVRD}
Provides: %{mklibname -d kworkspace} = %{EVRD}
Provides: %{mklibname -d plasma-geolocation-interface} = %{EVRD}
Provides: %{mklibname -d taskmanager} = %{EVRD}
Provides: %{mklibname -d weather_ion} = %{EVRD}
Provides: %{mklibname -d colorcorrect} = %{EVRD}
Provides: %{mklibname -d notificationmanager} = %{EVRD}
# Autodetected devel(libprocesscore) is also provided by KDE 4.x -- let's
# make sure we pick the right thing
Requires: cmake(KF5SysGuard)

%description -n %{devname}
Development files for the KDE Plasma workspace.

%package -n sddm-theme-breeze
Summary: KDE Breeze theme for the SDDM display manager
Group: Graphical desktop/KDE
Requires: sddm

%description -n sddm-theme-breeze
KDE Breeze theme for the SDDM display manager.

%package x11
Summary: X11 support for Plasma Workspace
Group: Graphical desktop/KDE
Provides: %{name}-backend = %{EVRD}

%description x11
X11 support for Plasma Workspace.

%package wayland
Summary: Wayland support for Plasma Workspace
Group: Graphical desktop/KDE
Requires: %{name}
Provides: %{name}-backend = %{EVRD}
Requires: xwayland
Requires: kwin-wayland

%description wayland
Wayland support for Plasma Workspace.

%prep
%autosetup -p1
# (tpg) do not start second dbus user session
# see also https://invent.kde.org/plasma/plasma-workspace/-/merge_requests/128/diffs?commit_id=8475fe4545998c806704a45a7d912f777a11533f
sed -i -e 's/dbus-run-session //g' login-sessions/plasmawayland*.desktop.cmake

%cmake_kde5 -DKDE4_COMMON_PAM_SERVICE=kde -DKDE_DEFAULT_HOME=.kde4 -DPLASMA_SYSTEMD_BOOT=true

%build
%ninja -C build

%install
%ninja_install -C build

install -Dpm 644 %{SOURCE1} %{buildroot}%{_sysconfdir}/pam.d/kde

# breeze backgrounds
rm -rf %{buildroot}%{_datadir}/plasma/look-and-feel/org.kde.breeze.desktop/contents/components/artwork/background.png
ln -sf %{_datadir}/mdk/backgrounds/default.png %{buildroot}%{_datadir}/plasma/look-and-feel/org.kde.breeze.desktop/contents/components/artwork/background.png

# sddm breeze theme background
rm -rf %{buildroot}%{_datadir}/sddm/themes/breeze/components/artwork/background.png
ln -sf %{_datadir}/mdk/backgrounds/OpenMandriva-splash.png %{buildroot}%{_datadir}/sddm/themes/breeze/components/artwork/background.png
sed -i -e "s#^background=.*#background=%{_datadir}/mdk/backgrounds/OpenMandriva-splash.png#" %{buildroot}%{_datadir}/sddm/themes/breeze/theme.conf
sed -i -e "s#^type=.*#type=image#" %{buildroot}%{_datadir}/sddm/themes/breeze/theme.conf

# (tpg) fix autostart permissions
chmod 644 %{buildroot}%{_sysconfdir}/xdg/autostart/*

%find_lang %{name} --all-name --with-html

%libpackage kfontinst 5
%libpackage kfontinstui 5

%files -f %{name}.lang
%{_bindir}/plasma-apply-colorscheme
%{_bindir}/plasma-apply-cursortheme
%{_bindir}/plasma-apply-desktoptheme
%{_bindir}/plasma-apply-lookandfeel
%{_bindir}/plasma-apply-wallpaperimage
%{_bindir}/plasma-shutdown
%{_sysconfdir}/xdg/autostart/gmenudbusmenuproxy.desktop
%{_sysconfdir}/xdg/autostart/klipper.desktop
%{_sysconfdir}/xdg/autostart/org.kde.plasmashell.desktop
%{_sysconfdir}/xdg/autostart/xembedsniproxy.desktop
%{_sysconfdir}/xdg/taskmanagerrulesrc
%{_sysconfdir}/pam.d/kde
%{_bindir}/gmenudbusmenuproxy
%{_bindir}/kcminit
%{_bindir}/kcminit_startup
%{_bindir}/klipper
%{_bindir}/krunner
%{_bindir}/ksmserver
%{_bindir}/ksplashqml
%{_bindir}/plasmashell
%{_bindir}/plasma_waitforname
%{_bindir}/plasmawindowed
%{_bindir}/plasma_session
%{_bindir}/systemmonitor
%{_bindir}/xembedsniproxy
%{_bindir}/kde-systemd-start-condition
%{_libdir}/libexec/baloorunner
%{_libdir}/libexec/ksmserver-logout-greeter
%dir %{_libdir}/qt5/plugins/plasma
%dir %{_libdir}/qt5/plugins/plasma/applets
%dir %{_libdir}/qt5/plugins/kf5/krunner
%{_libdir}/qt5/plugins/*.so
%{_libdir}/qt5/plugins/kf5/kded/*.so
%{_libdir}/qt5/plugins/kf5/kio/*.so
%{_libdir}/qt5/plugins/kf5/krunner/*.so
%{_libdir}/qt5/plugins/plasma/containmentactions
%{_libdir}/qt5/plugins/kpackage/packagestructure/*.so
%{_libdir}/qt5/plugins/phonon_platform
%{_libdir}/qt5/plugins/plasma/applets/*.so
%{_libdir}/qt5/plugins/kcms/*.so
%{_libdir}/qt5/plugins/plasma/dataengine
%{_libdir}/qt5/plugins/plasmacalendarplugins
%{_libdir}/qt5/qml/org/kde/colorcorrect
%dir %{_libdir}/qt5/qml/org/kde/plasma/private
%{_libdir}/qt5/qml/org/kde/plasma/private/digitalclock
%{_libdir}/qt5/qml/org/kde/plasma/private/shell
%{_libdir}/qt5/qml/org/kde/plasma/private/sessions
%{_libdir}/qt5/qml/org/kde/plasma/wallpapers
%{_libdir}/qt5/qml/org/kde/plasma/workspace
%{_libdir}/qt5/qml/org/kde/holidayeventshelperplugin
%{_libdir}/qt5/qml/org/kde/plasma/private/appmenu
%{_datadir}/metainfo/*.xml
%{_datadir}/applications/org.kde.klipper.desktop
%{_datadir}/applications/org.kde.plasmashell.desktop
%{_datadir}/applications/org.kde.systemmonitor.desktop
%{_datadir}/applications/plasma-windowed.desktop
%{_datadir}/config.kcfg/*.kcfg
%{_datadir}/dbus-1/services/*.service
%{_datadir}/desktop-directories
%{_datadir}/kio_desktop/*.desktop
%{_datadir}/kio_desktop/*.trash
%{_datadir}/knotifications5/*.notifyrc
%{_datadir}/kpackage/kcms/kcm_feedback
%{_datadir}/kpackage/kcms/kcm_translations
%{_datadir}/kservices5/*
%{_datadir}/kservicetypes5/*.desktop
%{_datadir}/ksplash
%{_datadir}/kstyle
%{_datadir}/solid/actions/test-predicate-openinwindow.desktop
%{_datadir}/plasma/look-and-feel
%dir %{_datadir}/plasma/plasmoids
%{_datadir}/plasma/plasmoids/org.kde.plasma.activitybar
%{_datadir}/plasma/plasmoids/org.kde.plasma.analogclock
%{_datadir}/plasma/plasmoids/org.kde.plasma.battery
%{_datadir}/plasma/plasmoids/org.kde.plasma.calendar
%{_datadir}/plasma/plasmoids/org.kde.plasma.clipboard
%{_datadir}/plasma/plasmoids/org.kde.plasma.devicenotifier
%{_datadir}/plasma/plasmoids/org.kde.plasma.digitalclock
%{_datadir}/plasma/plasmoids/org.kde.plasma.icon
%{_datadir}/plasma/plasmoids/org.kde.plasma.lock_logout
%{_datadir}/plasma/plasmoids/org.kde.plasma.mediacontroller
%{_datadir}/plasma/plasmoids/org.kde.plasma.notifications
%{_datadir}/plasma/plasmoids/org.kde.plasma.panelspacer
%{_datadir}/plasma/plasmoids/org.kde.plasma.systemtray
%{_datadir}/plasma/plasmoids/org.kde.plasma.systemmonitor
%{_datadir}/plasma/plasmoids/org.kde.plasma.systemmonitor.cpu
%{_datadir}/plasma/plasmoids/org.kde.plasma.systemmonitor.cpucore
%{_datadir}/plasma/plasmoids/org.kde.plasma.systemmonitor.diskactivity
%{_datadir}/plasma/plasmoids/org.kde.plasma.systemmonitor.diskusage
%{_datadir}/plasma/plasmoids/org.kde.plasma.systemmonitor.memory
%{_datadir}/plasma/plasmoids/org.kde.plasma.systemmonitor.net
%{_datadir}/plasma/plasmoids/org.kde.plasma.private.systemtray
%{_datadir}/plasma/plasmoids/org.kde.plasma.appmenu
%{_datadir}/plasma/services/*.operations
%dir %{_datadir}/plasma/wallpapers
%{_datadir}/plasma/wallpapers/org.kde.color
%{_datadir}/plasma/wallpapers/org.kde.image
%{_datadir}/plasma/wallpapers/org.kde.slideshow
%{_libdir}/libkrdb.so
%{_libdir}/qt5/qml/org/kde/taskmanager
%{_datadir}/qlogging-categories5/*.categories
%{_sysconfdir}/xdg/plasmanotifyrc
%{_libdir}/qt5/qml/org/kde/notificationmanager
%{_libdir}/qt5/qml/org/kde/plasma/private/containmentlayoutmanager
%{_libdir}/qt5/qml/org/kde/plasma/private/kicker
%{_libdir}/kconf_update_bin/krunnerglobalshortcuts
%{_libdir}/libexec/plasma-sourceenv.sh
%{_libdir}/libexec/startplasma-waylandsession
%{_bindir}/kcolorschemeeditor
%{_bindir}/kfontinst
%{_bindir}/kfontview
%{_bindir}/lookandfeeltool
%{_libdir}/libexec/kauth/fontinst*
%{_datadir}/polkit-1/actions/org.kde.fontinst.policy
%{_libdir}/libexec/kfontprint
%{_libdir}/libexec/plasma-changeicons
%{_libdir}/libexec/plasma-dbus-run-session-if-needed
%{_userunitdir}/*.service
%{_userunitdir}/*.target
%{_libdir}/kconf_update_bin/krunnerhistory
%{_datadir}/applications/org.kde.kcolorschemeeditor.desktop
%{_datadir}/applications/org.kde.kfontview.desktop
%{_datadir}/dbus-1/system-services/org.kde.fontinst.service
%{_datadir}/dbus-1/system.d/org.kde.fontinst.conf
%{_datadir}/icons/hicolor/*/mimetypes/fonts-package.*
%{_datadir}/icons/hicolor/*/apps/kfontview.*
%{_datadir}/icons/hicolor/scalable/apps/preferences-desktop-font-installer.svgz
%{_datadir}/kconf_update/*.pl
%{_datadir}/kconf_update/*.upd
%{_datadir}/kfontinst/icons/hicolor/*/actions/*.png
%{_datadir}/knsrcfiles/*.knsrc
%{_datadir}/konqsidebartng/virtual_folders/services/fonts.desktop
%{_datadir}/kpackage/kcms/kcm5_icons/contents/ui/IconSizePopup.qml
%{_datadir}/kpackage/kcms/kcm5_icons/contents/ui/main.qml
%{_datadir}/kpackage/kcms/kcm5_icons/metadata.desktop
%{_datadir}/kpackage/kcms/kcm5_icons/metadata.json
%{_datadir}/kpackage/kcms/kcm_colors/contents/ui/main.qml
%{_datadir}/kpackage/kcms/kcm_colors/metadata.desktop
%{_datadir}/kpackage/kcms/kcm_colors/metadata.json
%{_datadir}/kpackage/kcms/kcm_cursortheme/contents/ui/Delegate.qml
%{_datadir}/kpackage/kcms/kcm_cursortheme/contents/ui/main.qml
%{_datadir}/kpackage/kcms/kcm_cursortheme/metadata.desktop
%{_datadir}/kpackage/kcms/kcm_cursortheme/metadata.json
%{_datadir}/kpackage/kcms/kcm_desktoptheme/contents/ui/Hand.qml
%{_datadir}/kpackage/kcms/kcm_desktoptheme/contents/ui/ThemePreview.qml
%{_datadir}/kpackage/kcms/kcm_desktoptheme/contents/ui/main.qml
%{_datadir}/kpackage/kcms/kcm_desktoptheme/metadata.desktop
%{_datadir}/kpackage/kcms/kcm_desktoptheme/metadata.json
%{_datadir}/kpackage/kcms/kcm_fonts/contents/ui/FontWidget.qml
%{_datadir}/kpackage/kcms/kcm_fonts/contents/ui/main.qml
%{_datadir}/kpackage/kcms/kcm_fonts/metadata.desktop
%{_datadir}/kpackage/kcms/kcm_fonts/metadata.json
%{_datadir}/kpackage/kcms/kcm_lookandfeel/contents/ui/main.qml
%{_datadir}/kpackage/kcms/kcm_lookandfeel/metadata.desktop
%{_datadir}/kpackage/kcms/kcm_lookandfeel/metadata.json
%{_datadir}/kpackage/kcms/kcm_style/contents/ui/EffectSettingsPopup.qml
%{_datadir}/kpackage/kcms/kcm_style/contents/ui/GtkStylePage.qml
%{_datadir}/kpackage/kcms/kcm_style/contents/ui/main.qml
%{_datadir}/kpackage/kcms/kcm_style/metadata.desktop
%{_datadir}/kpackage/kcms/kcm_style/metadata.json
%{_datadir}/kpackage/kcms/kcm_autostart
%{_datadir}/kpackage/kcms/kcm_nightcolor
%{_datadir}/kpackage/kcms/kcm_notifications
%{_datadir}/krunner/dbusplugins/plasma-runner-baloosearch.desktop
%{_datadir}/kxmlgui5/kfontview/*.rc
%{_datadir}/kxmlgui5/kfontinst/*.rc
%{_datadir}/kglobalaccel/org.kde.krunner.desktop
%{_datadir}/plasma/plasmoids/org.kde.plasma.manage-inputmethod
%{_libdir}/qt5/plugins/plasma/geolocationprovider
%{_libdir}/qt5/plugins/kf5/parts/kfontviewpart.so
%{_bindir}/plasma-interactiveconsole

%files x11
%{_bindir}/startplasma-x11
%{_datadir}/xsessions/plasma.desktop

%files wayland
%{_bindir}/startplasma-wayland
%{_datadir}/wayland-sessions/plasmawayland.desktop

%files -n sddm-theme-breeze
%{_datadir}/sddm/themes/breeze

%files -n %{devname}
%{_includedir}/*
%{_libdir}/lib*.so
%exclude %{_libdir}/libkdeinit5_*.so
%exclude %{_libdir}/libkrdb.so
%{_libdir}/cmake/KRunnerAppDBusInterface
%{_libdir}/cmake/KSMServerDBusInterface
%{_libdir}/cmake/LibKWorkspace
%{_libdir}/cmake/LibTaskManager
%{_libdir}/cmake/LibColorCorrect
%{_datadir}/dbus-1/interfaces/*.xml
%{_libdir}/cmake/LibNotificationManager
