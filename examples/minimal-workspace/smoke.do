version 17
clear all
sysuse auto, clear
summarize price mpg weight
twoway scatter price mpg
display "STATA_WORKBENCH_SMOKE_OK"

