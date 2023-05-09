add_library(asteroid-stopwatch main.cpp resources.qrc)
set_target_properties(asteroid-stopwatch PROPERTIES PREFIX "")

target_link_libraries(asteroid-stopwatch PUBLIC
	AsteroidApp)

install(TARGETS asteroid-stopwatch
	DESTINATION ${CMAKE_INSTALL_LIBDIR})
