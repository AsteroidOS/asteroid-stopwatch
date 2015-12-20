TEMPLATE = app
QT += widgets qml quick xml svg
QTPLUGIN += qsvg

SOURCES +=     main.cpp
RESOURCES +=   resources.qrc
OTHER_FILES += main.qml

TARGET = asteroid-stopwatch
target.path = /usr/bin/

desktop.files = asteroid-stopwatch.desktop
desktop.path = /usr/share/applications

INSTALLS += target desktop
