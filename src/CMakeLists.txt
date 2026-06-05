add_library(asteroid-stopwatch main.cpp StopwatchController.cpp)
set_target_properties(asteroid-stopwatch PROPERTIES PREFIX "")

asteroid_app_qml_module(asteroid-stopwatch
	main.qml
	LapPage.qml
)

target_link_libraries(
	asteroid-stopwatch
	PUBLIC
		Asteroid::AsteroidApp6
)

install(
	TARGETS asteroid-stopwatch
	DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
