onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group tb /tb/CLK_FREQ_MHZ
add wave -noupdate -expand -group tb /tb/RESET_PERIOD
add wave -noupdate -expand -group tb /tb/clk
add wave -noupdate -expand -group tb /tb/reset_n
add wave -noupdate -expand -group tb /tb/count
add wave -noupdate -expand -group tb /tb/txdata
add wave -noupdate -expand -group tb /tb/txcode
add wave -noupdate -expand -group tb /tb/chan_error1
add wave -noupdate -expand -group tb /tb/chan_error2
add wave -noupdate -expand -group tb /tb/chan_error
add wave -noupdate -expand -group tb /tb/rxcode
add wave -noupdate -expand -group tb /tb/rxdata
add wave -noupdate -expand -group tb /tb/rxerror
add wave -noupdate -expand -group dec /tb/dec/code
add wave -noupdate -expand -group dec /tb/dec/corr_code
add wave -noupdate -expand -group dec /tb/dec/corr_parity
add wave -noupdate -expand -group dec /tb/dec/e
add wave -noupdate -expand -group dec /tb/dec/flip_mask
add wave -noupdate -expand -group dec /tb/dec/data
add wave -noupdate -expand -group dec /tb/dec/error
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {40955133 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {40953179 ps} {40975318 ps}
