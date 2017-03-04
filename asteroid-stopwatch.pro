TEMPLATE = app
QT += qml quick
CONFIG += link_pkgconfig
PKGCONFIG += qdeclarative5-boostable

SOURCES +=     main.cpp
RESOURCES +=   resources.qrc
OTHER_FILES += main.qml

lupdate_only{
    SOURCES = i18n/asteroid-stopwatch.desktop.h
}

# Needed for lupdate
TRANSLATIONS = i18n/asteroid-stopwatch.de.ts \
               i18n/asteroid-stopwatch.es.ts \
               i18n/asteroid-stopwatch.fa.ts \
               i18n/asteroid-stopwatch.fr.ts \
               i18n/asteroid-stopwatch.ko.ts \
               i18n/asteroid-stopwatch.nl.ts \
               i18n/asteroid-stopwatch.pl.ts \
               i18n/asteroid-stopwatch.pt_BR.ts \
               i18n/asteroid-stopwatch.ru.ts \
               i18n/asteroid-stopwatch.sv.ts \
               i18n/asteroid-stopwatch.uk.ts

TARGET = asteroid-stopwatch
target.path = /usr/bin/

desktop.commands = bash $$PWD/i18n/generate-desktop.sh $$PWD asteroid-stopwatch.desktop
desktop.files = $$OUT_PWD/asteroid-stopwatch.desktop
desktop.path = /usr/share/applications

INSTALLS += target desktop
