# XDC constraints for the Digilent Nexys Video board
# part: xc7a200tsbg484-1

# General configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

# 100 MHz clock
set_property -dict {LOC R4 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name clk [get_ports clk]

# LEDs
set_property -dict {LOC T14 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[0]}]
set_property -dict {LOC T15 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[1]}]
set_property -dict {LOC T16 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[2]}]
set_property -dict {LOC U16 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[3]}]
set_property -dict {LOC V15 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[4]}]
set_property -dict {LOC W16 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[5]}]
set_property -dict {LOC W15 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[6]}]
set_property -dict {LOC Y13 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports {led[7]}]

# Reset button
set_property -dict {LOC G4 IOSTANDARD LVCMOS15} [get_ports reset_n]

# Push buttons
set_property -dict {LOC F15 IOSTANDARD LVCMOS12} [get_ports btnu]
set_property -dict {LOC C22 IOSTANDARD LVCMOS12} [get_ports btnl]
set_property -dict {LOC D22 IOSTANDARD LVCMOS12} [get_ports btnd]
set_property -dict {LOC D14 IOSTANDARD LVCMOS12} [get_ports btnr]
set_property -dict {LOC B22 IOSTANDARD LVCMOS12} [get_ports btnc]

# Toggle switches
set_property -dict {LOC E22 IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {LOC F21 IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {LOC G21 IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {LOC G22 IOSTANDARD LVCMOS12} [get_ports {sw[3]}]
set_property -dict {LOC H17 IOSTANDARD LVCMOS12} [get_ports {sw[4]}]
set_property -dict {LOC J16 IOSTANDARD LVCMOS12} [get_ports {sw[5]}]
set_property -dict {LOC K13 IOSTANDARD LVCMOS12} [get_ports {sw[6]}]
set_property -dict {LOC M17 IOSTANDARD LVCMOS12} [get_ports {sw[7]}]

# UART
set_property -dict {LOC AA19 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports uart_txd]
set_property -dict {LOC V18 IOSTANDARD LVCMOS33} [get_ports uart_rxd]

# FTDI USB FIFO
#set_property -dict {LOC U20 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_d[0]]
#set_property -dict {LOC P14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_d[1]]
#set_property -dict {LOC P15 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_d[2]]
#set_property -dict {LOC U17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_d[3]]
#set_property -dict {LOC R17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_d[4]]
#set_property -dict {LOC P16 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_d[5]]
#set_property -dict {LOC R18 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_d[6]]
#set_property -dict {LOC N14 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_d[7]]
#set_property -dict {LOC N17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_rxf_n]
#set_property -dict {LOC Y19 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_txe_n]
#set_property -dict {LOC P19 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_rd_n]
#set_property -dict {LOC R19 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_wr_n]
#set_property -dict {LOC P17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_siwu_n]
#set_property -dict {LOC V17 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_oe_n]
#set_property -dict {LOC Y18 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports fifo_clkout_n]

# Gigabit Ethernet RGMII PHY
set_property -dict {LOC V13 IOSTANDARD LVCMOS25} [get_ports phy_rx_clk]
set_property -dict {LOC AB16 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[0]}]
set_property -dict {LOC AA15 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[1]}]
set_property -dict {LOC AB15 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[2]}]
set_property -dict {LOC AB11 IOSTANDARD LVCMOS25} [get_ports {phy_rxd[3]}]
set_property -dict {LOC W10 IOSTANDARD LVCMOS25} [get_ports phy_rx_ctl]
set_property -dict {LOC AA14 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports phy_tx_clk]
set_property -dict {LOC Y12 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[0]}]
set_property -dict {LOC W12 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[1]}]
set_property -dict {LOC W11 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[2]}]
set_property -dict {LOC Y11 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports {phy_txd[3]}]
set_property -dict {LOC V10 IOSTANDARD LVCMOS25 SLEW FAST DRIVE 16} [get_ports phy_tx_ctl]
set_property -dict {LOC U7 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_reset_n]
set_property -dict {LOC Y14 IOSTANDARD LVCMOS25} [get_ports phy_int_n]
set_property -dict {LOC W14 IOSTANDARD LVCMOS25} [get_ports phy_pme_n]
#set_property -dict {LOC Y16  IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports phy_mdio]
#set_property -dict {LOC AA16 IOSTANDARD LVCMOS25 SLEW SLOW DRIVE 12} [get_ports phy_mdc]

create_clock -period 8.000 -name phy_rx_clk [get_ports phy_rx_clk]

# I2C interface
set_property -dict {LOC W5 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports i2c_scl]
set_property -dict {LOC V5 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 8} [get_ports i2c_sda]

