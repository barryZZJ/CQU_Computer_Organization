onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib mem_opt

do {wave.do}

view wave
view structure
view signals

do {mem.udo}

run -all

quit -force
