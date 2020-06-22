@echo off
set xv_path=D:\\Software\\Vivado\\Vivado\\Vivado\\2015.2\\bin
call %xv_path%/xsim sim2_behav -key {Behavioral:sim_1:Functional:sim2} -tclbatch sim2.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
