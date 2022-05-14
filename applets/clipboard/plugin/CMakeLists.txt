add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.plasma.clipboard\")

set(clipboardplugin_SRCS
    clipboardplugin.cpp
    draghelper/draghelper.cpp
)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/clipboard)

add_library(clipboardplugin SHARED ${clipboardplugin_SRCS})

target_link_libraries(clipboardplugin
    Qt::Core
    Qt::Qml
    Qt::Quick
)

install(TARGETS clipboardplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/clipboard)

