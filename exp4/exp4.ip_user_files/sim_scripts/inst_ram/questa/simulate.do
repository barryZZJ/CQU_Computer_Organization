onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib inst_ram_opt

do {wave.do}

view wave
view structure
view signals

do {inst_ram.udo}

run -all

quit -force
