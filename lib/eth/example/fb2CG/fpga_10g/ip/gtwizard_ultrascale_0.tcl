
create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -module_name gtwizard_ultrascale_0

set_property -dict [list CONFIG.preset {GTY-10GBASE-R}] [get_ips gtwizard_ultrascale_0]

set_property -dict [list \
    CONFIG.CHANNEL_ENABLE {X0Y23 X0Y22 X0Y21 X0Y20 X0Y15 X0Y14 X0Y13 X0Y12} \
    CONFIG.TX_MASTER_CHANNEL {X0Y12} \
    CONFIG.RX_MASTER_CHANNEL {X0Y12} \
    CONFIG.TX_LINE_RATE {10.3125} \
    CONFIG.TX_REFCLK_FREQUENCY {161.1328125} \
    CONFIG.TX_USER_DATA_WIDTH {64} \
    CONFIG.TX_INT_DATA_WIDTH {64} \
    CONFIG.RX_LINE_RATE {10.3125} \
    CONFIG.RX_REFCLK_FREQUENCY {161.1328125} \
    CONFIG.RX_USER_DATA_WIDTH {64} \
    CONFIG.RX_INT_DATA_WIDTH {64} \
    CONFIG.RX_REFCLK_SOURCE {X0Y23 clk0 X0Y22 clk0 X0Y21 clk0 X0Y20 clk0 X0Y15 clk0 X0Y14 clk0 X0Y13 clk0 X0Y12 clk0} \
    CONFIG.TX_REFCLK_SOURCE {X0Y23 clk0 X0Y22 clk0 X0Y21 clk0 X0Y20 clk0 X0Y15 clk0 X0Y14 clk0 X0Y13 clk0 X0Y12 clk0} \
    CONFIG.FREERUN_FREQUENCY {125} \
] [get_ips gtwizard_ultrascale_0]
