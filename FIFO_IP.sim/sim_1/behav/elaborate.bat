@echo off
set xv_path=E:\\Softwares\\Vivado\\Vivado\\2016.4\\bin
call %xv_path%/xelab  -wto 1703d794b56f4285b18a201e20b969d0 -m64 --debug typical --relax --mt 2 -L fifo_generator_v13_1_3 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot tb_fifo_0_behav xil_defaultlib.tb_fifo_0 xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
