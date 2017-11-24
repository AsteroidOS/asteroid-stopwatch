TARGET = asteroid-stopwatch
CONFIG += asteroidapp

SOURCES +=     main.cpp
RESOURCES +=   resources.qrc
OTHER_FILES += main.qml

lupdate_only{ SOURCES += i18n/asteroid-stopwatch.desktop.h }
TRANSLATIONS = $$files(i18n/$$TARGET.*.ts)
