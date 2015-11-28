TEMPLATE = app
QT += qml quick xml svg
QTPLUGIN += qsvg
TARGET = asteroid-stopwatch
target.path = /usr/bin/

qtHaveModule(widgets){
    QT += widgets
}

include(src/src.pri)

OTHER_FILES += main.qml

RESOURCES += \
    resources.qrc

INSTALLS += target

desktop.path = /usr/share/applications
desktop.files = asteroid-stopwatch.desktop
INSTALLS += desktop
