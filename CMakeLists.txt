cmake_minimum_required(VERSION 3.6.0)

project(asteroid-stopwatch
	VERSION 0.0.1
	DESCRIPTION "Default stopwatch app for AsteroidOS")

find_package(ECM REQUIRED NO_MODULE)
find_package(AsteroidApp REQUIRED)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ASTEROID_MODULE_PATH})

include(FeatureSummary)
include(GNUInstallDirs)
include(ECMFindQmlModule)
include(AsteroidCMakeSettings)
include(AsteroidTranslations)

ecm_find_qmlmodule(Nemo.Configuration 1.0)

add_subdirectory(src)

build_translations(i18n)
generate_desktop(${CMAKE_SOURCE_DIR} asteroid-stopwatch)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
