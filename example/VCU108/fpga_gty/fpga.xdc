# XDC constraints for the Xilinx VCU108 board
# part: xcvu095-ffva2104-2-e

# General configuration
set_property CFGBVS GND                                [current_design]
set_property CONFIG_VOLTAGE 1.8                        [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true           [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN {DIV-1} [current_design]
set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1      [current_design]
set_property CONFIG_MODE BPI16                         [current_design]

# System clocks
# 300 MHz
#set_property -dict {LOC G31  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_1_p]
#set_property -dict {LOC F31  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_1_n]
#create_clock -period 3.333 -name clk_300_mhz_1 [get_ports clk_300mhz_1_p]

#set_property -dict {LOC G22  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_2_p]
#set_property -dict {LOC G21  IOSTANDARD DIFF_SSTL12} [get_ports clk_300mhz_2_n]
#create_clock -period 3.333 -name clk_300mhz_2 [get_ports clk_300mhz_2_p]

# 125 MHz
set_property -dict {LOC BC9  IOSTANDARD LVDS} [get_ports clk_125mhz_p]
set_property -dict {LOC BC8  IOSTANDARD LVDS} [get_ports clk_125mhz_n]
create_clock -period 8.000 -name clk_125mhz [get_ports clk_125mhz_p]

# 90 MHz
#set_property -dict {LOC AL20 IOSTANDARD LVCMOS18} [get_ports clk_90mhz]
#create_clock -period 11.111 -name clk_90mhz [get_ports clk_90mhz]

# LEDs
set_property -dict {LOC AT32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[0]}]
set_property -dict {LOC AV34 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[1]}]
set_property -dict {LOC AY30 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[2]}]
set_property -dict {LOC BB32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[3]}]
set_property -dict {LOC BF32 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[4]}]
set_property -dict {LOC AV36 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[5]}]
set_property -dict {LOC AY35 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[6]}]
set_property -dict {LOC BA37 IOSTANDARD LVCMOS12 SLEW SLOW DRIVE 8} [get_ports {led[7]}]

# Reset button
set_property -dict {LOC E36  IOSTANDARD LVCMOS12} [get_ports reset]

# Push buttons
set_property -dict {LOC E34  IOSTANDARD LVCMOS12} [get_ports btnu]
set_property -dict {LOC M22  IOSTANDARD LVCMOS12} [get_ports btnl]
set_property -dict {LOC D9   IOSTANDARD LVCMOS12} [get_ports btnd]
set_property -dict {LOC A10  IOSTANDARD LVCMOS12} [get_ports btnr]
set_property -dict {LOC AW27 IOSTANDARD LVCMOS12} [get_ports btnc]

# DIP switches
set_property -dict {LOC BC40 IOSTANDARD LVCMOS12} [get_ports {sw[0]}]
set_property -dict {LOC L19  IOSTANDARD LVCMOS12} [get_ports {sw[1]}]
set_property -dict {LOC C37  IOSTANDARD LVCMOS12} [get_ports {sw[2]}]
set_property -dict {LOC C38  IOSTANDARD LVCMOS12} [get_ports {sw[3]}]

# UART
set_property -dict {LOC BE24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_txd]
set_property -dict {LOC BC24 IOSTANDARD LVCMOS18} [get_ports uart_rxd]
set_property -dict {LOC BF24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports uart_rts]
set_property -dict {LOC BD22 IOSTANDARD LVCMOS18} [get_ports uart_cts]

# Gigabit Ethernet SGMII PHY
set_property -dict {LOC AR24 IOSTANDARD DIFF_HSTL_I_18} [get_ports phy_sgmii_rx_p]
set_property -dict {LOC AT24 IOSTANDARD DIFF_HSTL_I_18} [get_ports phy_sgmii_rx_n]
set_property -dict {LOC AR23 IOSTANDARD DIFF_HSTL_I_18} [get_ports phy_sgmii_tx_p]
set_property -dict {LOC AR22 IOSTANDARD DIFF_HSTL_I_18} [get_ports phy_sgmii_tx_n]
set_property -dict {LOC AT22 IOSTANDARD LVDS_25} [get_ports phy_sgmii_clk_p]
set_property -dict {LOC AU22 IOSTANDARD LVDS_25} [get_ports phy_sgmii_clk_n]
set_property -dict {LOC AU21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_reset_n]
set_property -dict {LOC AT21 IOSTANDARD LVCMOS18} [get_ports phy_int_n]
#set_property -dict {LOC AV24 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_mdio]
#set_property -dict {LOC AV21 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 8} [get_ports phy_mdc]

# 625 MHz ref clock from SGMII PHY
#create_clock -period 1.600 -name phy_sgmii_clk [get_ports phy_sgmii_clk_p]

# Bullseye GTY
set_property -dict {LOC AR45} [get_ports bullseye_rx0_p] ;# MGTYRXP0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AR46} [get_ports bullseye_rx0_n] ;# MGTYRXN0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AN45} [get_ports bullseye_rx1_p] ;# MGTYRXP1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AN46} [get_ports bullseye_rx1_n] ;# MGTYRXN1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AL45} [get_ports bullseye_rx2_p] ;# MGTYRXP2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AL46} [get_ports bullseye_rx2_n] ;# MGTYRXN2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AJ45} [get_ports bullseye_rx3_p] ;# MGTYRXP3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AJ46} [get_ports bullseye_rx3_n] ;# MGTYRXN3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AT42} [get_ports bullseye_tx0_p] ;# MGTYTXP0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AT43} [get_ports bullseye_tx0_n] ;# MGTYTXN0_126 GTYE3_CHANNEL_X0Y8 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AP42} [get_ports bullseye_tx1_p] ;# MGTYTXP1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AP43} [get_ports bullseye_tx1_n] ;# MGTYTXN1_126 GTYE3_CHANNEL_X0Y9 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AM42} [get_ports bullseye_tx2_p] ;# MGTYTXP2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AM43} [get_ports bullseye_tx2_n] ;# MGTYTXN2_126 GTYE3_CHANNEL_X0Y10 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AL40} [get_ports bullseye_tx3_p] ;# MGTYTXP3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AL41} [get_ports bullseye_tx3_n] ;# MGTYTXN3_126 GTYE3_CHANNEL_X0Y11 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AK38} [get_ports bullseye_mgt_refclk_0_p] ;# MGTREFCLK0P_126 from J87 P19
#set_property -dict {LOC AK39} [get_ports bullseye_mgt_refclk_0_n] ;# MGTREFCLK0N_126 from J87 P20
set_property -dict {LOC AH38} [get_ports bullseye_mgt_refclk_1_p] ;# MGTREFCLK1P_126 from U32 SI570 via U104 SI53340
#set_property -dict {LOC AH39} [get_ports bullseye_mgt_refclk_1_n] ;# MGTREFCLK1N_126 from U32 SI570 via U104 SI53340

# 156.25 MHz MGT reference clock
create_clock -period 6.4 -name bullseye_mgt_refclk [get_ports bullseye_mgt_refclk_1_p]

# QSFP28 Interface
set_property -dict {LOC AG45} [get_ports qsfp_rx1_p] ;# MGTYRXP0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AG46} [get_ports qsfp_rx1_n] ;# MGTYRXN0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AF43} [get_ports qsfp_rx2_p] ;# MGTYRXP1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AF44} [get_ports qsfp_rx2_n] ;# MGTYRXN1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AE45} [get_ports qsfp_rx3_p] ;# MGTYRXP2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AE46} [get_ports qsfp_rx3_n] ;# MGTYRXN2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AD43} [get_ports qsfp_rx4_p] ;# MGTYRXP3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AD44} [get_ports qsfp_rx4_n] ;# MGTYRXN3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AK42} [get_ports qsfp_tx1_p] ;# MGTYTXP0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AK43} [get_ports qsfp_tx1_n] ;# MGTYTXN0_127 GTYE3_CHANNEL_X0Y12 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AJ40} [get_ports qsfp_tx2_p] ;# MGTYTXP1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AJ41} [get_ports qsfp_tx2_n] ;# MGTYTXN1_127 GTYE3_CHANNEL_X0Y13 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AG40} [get_ports qsfp_tx3_p] ;# MGTYTXP2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AG41} [get_ports qsfp_tx3_n] ;# MGTYTXN2_127 GTYE3_CHANNEL_X0Y14 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AE40} [get_ports qsfp_tx4_p] ;# MGTYTXP3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
#set_property -dict {LOC AE41} [get_ports qsfp_tx4_n] ;# MGTYTXN3_127 GTYE3_CHANNEL_X0Y15 / GTYE3_COMMON_X0Y3
set_property -dict {LOC AF38} [get_ports qsfp_mgt_refclk_0_p] ;# MGTREFCLK0P_127 from U32 SI570 via U104 SI53340
#set_property -dict {LOC AF39} [get_ports qsfp_mgt_refclk_0_n] ;# MGTREFCLK0N_127 from U32 SI570 via U104 SI53340
#set_property -dict {LOC AD38} [get_ports qsfp_mgt_refclk_1_p] ;# MGTREFCLK1P_127 from U57 CKOUT2 SI5328
#set_property -dict {LOC AD39} [get_ports qsfp_mgt_refclk_1_n] ;# MGTREFCLK1N_127 from U57 CKOUT2 SI5328
#set_property -dict {LOC AG34 IOSTANDARD LVDS} [get_ports qsfp_recclk_p] ;# to U57 CKIN1 SI5328
#set_property -dict {LOC AH35 IOSTANDARD LVDS} [get_ports qsfp_recclk_n] ;# to U57 CKIN1 SI5328
set_property -dict {LOC AL24 IOSTANDARD LVCMOS18} [get_ports qsfp_modsell]
set_property -dict {LOC AM24 IOSTANDARD LVCMOS18} [get_ports qsfp_resetl]
set_property -dict {LOC AL25 IOSTANDARD LVCMOS18} [get_ports qsfp_modprsl]
set_property -dict {LOC AL21 IOSTANDARD LVCMOS18} [get_ports qsfp_intl]
set_property -dict {LOC AM21 IOSTANDARD LVCMOS18} [get_ports qsfp_lpmode]

# 156.25 MHz MGT reference clock
create_clock -period 6.4 -name qsfp_mgt_refclk [get_ports qsfp_mgt_refclk_0_p]

# CFP2 GTY
set_property -dict {LOC J45 } [get_ports cfp2_rx0_p] ;# MGTYRXP1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC J46 } [get_ports cfp2_rx0_n] ;# MGTYRXN1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
set_property -dict {LOC N45 } [get_ports cfp2_rx1_p] ;# MGTYRXP3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC N46 } [get_ports cfp2_rx1_n] ;# MGTYRXN3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
set_property -dict {LOC R45 } [get_ports cfp2_rx2_p] ;# MGTYRXP2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC R46 } [get_ports cfp2_rx2_n] ;# MGTYRXN2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
set_property -dict {LOC L45 } [get_ports cfp2_rx3_p] ;# MGTYRXP0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC L46 } [get_ports cfp2_rx3_n] ;# MGTYRXN0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
set_property -dict {LOC Y43 } [get_ports cfp2_rx4_p] ;# MGTYRXP3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC Y44 } [get_ports cfp2_rx4_n] ;# MGTYRXN3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
set_property -dict {LOC U45 } [get_ports cfp2_rx5_p] ;# MGTYRXP1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC U46 } [get_ports cfp2_rx5_n] ;# MGTYRXN1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
set_property -dict {LOC W45 } [get_ports cfp2_rx6_p] ;# MGTYRXP0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC W46 } [get_ports cfp2_rx6_n] ;# MGTYRXN0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
set_property -dict {LOC AA45} [get_ports cfp2_rx7_p] ;# MGTYRXP2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AA46} [get_ports cfp2_rx7_n] ;# MGTYRXN2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
set_property -dict {LOC AB43} [get_ports cfp2_rx8_p] ;# MGTYRXP1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AB44} [get_ports cfp2_rx8_n] ;# MGTYRXN1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
set_property -dict {LOC AC45} [get_ports cfp2_rx9_p] ;# MGTYRXP0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AC46} [get_ports cfp2_rx9_n] ;# MGTYRXN0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
set_property -dict {LOC F42 } [get_ports cfp2_tx0_p] ;# MGTYTXP1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC F43 } [get_ports cfp2_tx0_n] ;# MGTYTXN1_130 GTYE3_CHANNEL_X0Y25 / GTYE3_COMMON_X0Y6
set_property -dict {LOC K42 } [get_ports cfp2_tx1_p] ;# MGTYTXP3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC K43 } [get_ports cfp2_tx1_n] ;# MGTYTXN3_129 GTYE3_CHANNEL_X0Y23 / GTYE3_COMMON_X0Y5
set_property -dict {LOC M42 } [get_ports cfp2_tx2_p] ;# MGTYTXP2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC M43 } [get_ports cfp2_tx2_n] ;# MGTYTXN2_129 GTYE3_CHANNEL_X0Y22 / GTYE3_COMMON_X0Y5
set_property -dict {LOC H42 } [get_ports cfp2_tx3_p] ;# MGTYTXP0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
#set_property -dict {LOC H43 } [get_ports cfp2_tx3_n] ;# MGTYTXN0_130 GTYE3_CHANNEL_X0Y24 / GTYE3_COMMON_X0Y6
set_property -dict {LOC U40 } [get_ports cfp2_tx4_p] ;# MGTYTXP3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC U41 } [get_ports cfp2_tx4_n] ;# MGTYTXN3_128 GTYE3_CHANNEL_X0Y19 / GTYE3_COMMON_X0Y4
set_property -dict {LOC P42 } [get_ports cfp2_tx5_p] ;# MGTYTXP1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC P43 } [get_ports cfp2_tx5_n] ;# MGTYTXN1_129 GTYE3_CHANNEL_X0Y21 / GTYE3_COMMON_X0Y5
set_property -dict {LOC T42 } [get_ports cfp2_tx6_p] ;# MGTYTXP0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
#set_property -dict {LOC T43 } [get_ports cfp2_tx6_n] ;# MGTYTXN0_129 GTYE3_CHANNEL_X0Y20 / GTYE3_COMMON_X0Y5
set_property -dict {LOC W40 } [get_ports cfp2_tx7_p] ;# MGTYTXP2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC W41 } [get_ports cfp2_tx7_n] ;# MGTYTXN2_128 GTYE3_CHANNEL_X0Y18 / GTYE3_COMMON_X0Y4
set_property -dict {LOC AA40} [get_ports cfp2_tx8_p] ;# MGTYTXP1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AA41} [get_ports cfp2_tx8_n] ;# MGTYTXN1_128 GTYE3_CHANNEL_X0Y17 / GTYE3_COMMON_X0Y4
set_property -dict {LOC AC40} [get_ports cfp2_tx9_p] ;# MGTYTXP0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
#set_property -dict {LOC AC41} [get_ports cfp2_tx9_n] ;# MGTYTXN0_128 GTYE3_CHANNEL_X0Y16 / GTYE3_COMMON_X0Y4
set_property -dict {LOC V38 } [get_ports cfp2_mgt_refclk_0_p] ;# MGTREFCLK0P_129 from U32 SI570 via U104 SI53340
#set_property -dict {LOC V39 } [get_ports cfp2_mgt_refclk_0_n] ;# MGTREFCLK0N_129 from U32 SI570 via U104 SI53340
#set_property -dict {LOC T38 } [get_ports cfp2_mgt_refclk_1_p] ;# MGTREFCLK1P_129 from U57 CKOUT1 SI5328
#set_property -dict {LOC T39 } [get_ports cfp2_mgt_refclk_1_n] ;# MGTREFCLK1N_129 from U57 CKOUT1 SI5328
set_property -dict {LOC BA21 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_cntl[0]}]
set_property -dict {LOC AY24 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_cntl[1]}]
set_property -dict {LOC AY23 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_cntl[2]}]
set_property -dict {LOC BB24 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_alrm[0]}]
set_property -dict {LOC BB23 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_alrm[1]}]
set_property -dict {LOC BB22 IOSTANDARD LVCMOS18} [get_ports {cfp2_prg_alrm[2]}]
set_property -dict {LOC BA22 IOSTANDARD LVCMOS18} [get_ports {cfp2_prtadr[0]}]
set_property -dict {LOC AW25 IOSTANDARD LVCMOS18} [get_ports {cfp2_prtadr[1]}]
set_property -dict {LOC AY25 IOSTANDARD LVCMOS18} [get_ports {cfp2_prtadr[2]}]
set_property -dict {LOC AY22 IOSTANDARD LVCMOS18} [get_ports cfp2_tx_dis]
set_property -dict {LOC BB21 IOSTANDARD LVCMOS18} [get_ports cfp2_rx_los]
set_property -dict {LOC BC21 IOSTANDARD LVCMOS18} [get_ports cfp2_mod_lopwr]
set_property -dict {LOC BD21 IOSTANDARD LVCMOS18} [get_ports cfp2_mod_rstn]
set_property -dict {LOC BA25 IOSTANDARD LVCMOS18} [get_ports cfp2_mod_abs]
set_property -dict {LOC BA24 IOSTANDARD LVCMOS18} [get_ports cfp2_glb_alrmn]
set_property -dict {LOC BE22 IOSTANDARD LVCMOS18} [get_ports cfp2_mdc]
set_property -dict {LOC BF22 IOSTANDARD LVCMOS18} [get_ports cfp2_mdio]

# 156.25 MHz MGT reference clock
create_clock -period 6.4 -name cfp2_mgt_refclk [get_ports cfp2_mgt_refclk_0_p]

# I2C interface
set_property -dict {LOC AN21 IOSTANDARD LVCMOS18} [get_ports i2c_scl]
set_property -dict {LOC AP21 IOSTANDARD LVCMOS18} [get_ports i2c_sda]

