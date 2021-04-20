TARGET = asteroid-stopwatch
CONFIG += asteroidapp link_pkgconfig
PKGCONFIG += asteroidapp

SOURCES +=     main.cpp
RESOURCES +=   resources.qrc
OTHER_FILES += main.qml

lupdate_only{ SOURCES += i18n/asteroid-stopwatch.desktop.h }
TRANSLATIONS = $$files(i18n/$$TARGET.*.ts)

target.path = /usr/bin/
INSTALLS += target
