
create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -module_name gtwizard_ultrascale_1

set_property -dict [list CONFIG.preset {GTY-10GBASE-R}] [get_ips gtwizard_ultrascale_1]

set_property -dict [list \
    CONFIG.CHANNEL_ENABLE {X0Y25 X0Y24 X0Y23 X0Y22 X0Y21 X0Y20 X0Y19 X0Y18 X0Y17 X0Y16} \
    CONFIG.TX_MASTER_CHANNEL {X0Y25} \
    CONFIG.RX_MASTER_CHANNEL {X0Y25} \
    CONFIG.TX_LINE_RATE {10.3125} \
    CONFIG.TX_DATA_ENCODING {RAW} \
    CONFIG.TX_REFCLK_FREQUENCY {156.25} \
    CONFIG.TX_USER_DATA_WIDTH {64} \
    CONFIG.TX_INT_DATA_WIDTH {64} \
    CONFIG.RX_LINE_RATE {10.3125} \
    CONFIG.RX_DATA_DECODING {RAW} \
    CONFIG.RX_REFCLK_FREQUENCY {156.25} \
    CONFIG.RX_USER_DATA_WIDTH {64} \
    CONFIG.RX_INT_DATA_WIDTH {64} \
    CONFIG.RX_REFCLK_SOURCE {X0Y25 clk0-1 X0Y24 clk0-1 X0Y23 clk0 X0Y22 clk0 X0Y21 clk0 X0Y20 clk0 X0Y19 clk0+1 X0Y18 clk0+1 X0Y17 clk0+1 X0Y16 clk0+1} \
    CONFIG.TX_REFCLK_SOURCE {X0Y25 clk0-1 X0Y24 clk0-1 X0Y23 clk0 X0Y22 clk0 X0Y21 clk0 X0Y20 clk0 X0Y19 clk0+1 X0Y18 clk0+1 X0Y17 clk0+1 X0Y16 clk0+1} \
    CONFIG.FREERUN_FREQUENCY {62.5} \
    CONFIG.ENABLE_OPTIONAL_PORTS {drpaddr_common_in drpaddr_in drpclk_common_in drpclk_in drpdi_common_in drpdi_in drpen_common_in drpen_in drpwe_common_in drpwe_in rxpolarity_in rxprbscntreset_in rxprbssel_in txdiffctrl_in txelecidle_in txinhibit_in txmaincursor_in txpolarity_in txpostcursor_in txprbsforceerr_in txprbssel_in txprecursor_in drpdo_common_out drpdo_out drprdy_common_out drprdy_out rxprbserr_out rxprbslocked_out} \
    CONFIG.LOCATE_TX_USER_CLOCKING {CORE} \
    CONFIG.LOCATE_RX_USER_CLOCKING {CORE} \
] [get_ips gtwizard_ultrascale_1]
