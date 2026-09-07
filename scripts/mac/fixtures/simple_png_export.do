* fixture: simple quoted png export
sysuse auto, clear
scatter mpg weight
graph export "out/simple.png", as(png) width(800) replace
