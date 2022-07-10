onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group tb /tb/clk
add wave -noupdate -expand -group tb /tb/reset_n
add wave -noupdate -expand -group tb /tb/count
add wave -noupdate -expand -group tb /tb/idata
add wave -noupdate -expand -group tb /tb/ocode
add wave -noupdate -expand -group tb /tb/error
add wave -noupdate -expand -group tb /tb/icode
add wave -noupdate -expand -group tb /tb/odata
add wave -noupdate -expand -group tb /tb/cmp_error
add wave -noupdate -group enc /tb/enc/s
add wave -noupdate -group enc /tb/enc/GF_log
add wave -noupdate -group enc /tb/enc/GF_alog
add wave -noupdate -group enc -radix unsigned /tb/enc/p_poly
add wave -noupdate -group enc -radix unsigned /tb/enc/q_poly
add wave -noupdate -group enc -expand /tb/enc/p_data
add wave -noupdate -group enc -expand /tb/enc/q_data
add wave -noupdate -group enc /tb/enc/P
add wave -noupdate -group enc /tb/enc/Q
add wave -noupdate -group enc /tb/enc/idata
add wave -noupdate -group enc /tb/enc/ocode
add wave -noupdate -group enc /tb/enc/idx
add wave -noupdate -expand -group dec /tb/dec/GF_alog
add wave -noupdate -expand -group dec /tb/dec/GF_log
add wave -noupdate -expand -group dec /tb/dec/icode
add wave -noupdate -expand -group dec /tb/dec/s
add wave -noupdate -expand -group dec /tb/dec/S0
add wave -noupdate -expand -group dec /tb/dec/S1_poly
add wave -noupdate -expand -group dec /tb/dec/S1
add wave -noupdate -expand -group dec /tb/dec/k
add wave -noupdate -expand -group dec /tb/dec/odata
add wave -noupdate -expand -group dec /tb/dec/idx
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {1165500 ps}
