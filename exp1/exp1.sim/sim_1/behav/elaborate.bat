@echo off
set xv_path=D:\\Software\\Vivado\\Vivado\\Vivado\\2015.2\\bin
call %xv_path%/xelab  -wto e5c5e90a3d444df5bcbe14b943a5fac5 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot sim2_behav xil_defaultlib.sim2 xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
