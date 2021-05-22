
# FPGA settings
FPGA_TOP = fpga
FPGA_FAMILY = "Stratix 10 MX"
FPGA_DEVICE = 1SM21BHU2F53E1VG

# Files for synthesis
SYN_FILES = rtl/fpga.v
SYN_FILES += rtl/fpga_core.v
SYN_FILES += rtl/sync_signal.v
SYN_FILES += rtl/eth_xcvr_phy_wrapper.v
SYN_FILES += rtl/eth_xcvr_phy_quad_wrapper.v
SYN_FILES += lib/xfcp/rtl/xfcp_interface_uart.v
SYN_FILES += lib/xfcp/rtl/xfcp_interface_udp.v
SYN_FILES += lib/xfcp/rtl/xfcp_mod_i2c_master.v
SYN_FILES += lib/xfcp/rtl/xfcp_mod_wb.v
SYN_FILES += lib/xfcp/rtl/xfcp_switch.v
SYN_FILES += lib/eth/rtl/eth_mac_10g_fifo.v
SYN_FILES += lib/eth/rtl/eth_mac_10g.v
SYN_FILES += lib/eth/rtl/axis_xgmii_rx_64.v
SYN_FILES += lib/eth/rtl/axis_xgmii_tx_64.v
SYN_FILES += lib/eth/rtl/eth_phy_10g.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx_if.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx_frame_sync.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_rx_ber_mon.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_tx.v
SYN_FILES += lib/eth/rtl/eth_phy_10g_tx_if.v
SYN_FILES += lib/eth/rtl/xgmii_baser_dec_64.v
SYN_FILES += lib/eth/rtl/xgmii_baser_enc_64.v
SYN_FILES += lib/eth/rtl/lfsr.v
SYN_FILES += lib/eth/rtl/eth_axis_rx.v
SYN_FILES += lib/eth/rtl/eth_axis_tx.v
SYN_FILES += lib/eth/rtl/udp_complete.v
SYN_FILES += lib/eth/rtl/udp_checksum_gen.v
SYN_FILES += lib/eth/rtl/udp.v
SYN_FILES += lib/eth/rtl/udp_ip_rx.v
SYN_FILES += lib/eth/rtl/udp_ip_tx.v
SYN_FILES += lib/eth/rtl/ip_complete.v
SYN_FILES += lib/eth/rtl/ip.v
SYN_FILES += lib/eth/rtl/ip_eth_rx.v
SYN_FILES += lib/eth/rtl/ip_eth_tx.v
SYN_FILES += lib/eth/rtl/ip_arb_mux.v
SYN_FILES += lib/eth/rtl/arp.v
SYN_FILES += lib/eth/rtl/arp_cache.v
SYN_FILES += lib/eth/rtl/arp_eth_rx.v
SYN_FILES += lib/eth/rtl/arp_eth_tx.v
SYN_FILES += lib/eth/rtl/eth_arb_mux.v
SYN_FILES += lib/i2c/rtl/i2c_master.v
SYN_FILES += lib/wb/rtl/wb_ram.v
SYN_FILES += lib/axis/rtl/arbiter.v
SYN_FILES += lib/axis/rtl/priority_encoder.v
SYN_FILES += lib/axis/rtl/axis_cobs_encode.v
SYN_FILES += lib/axis/rtl/axis_cobs_decode.v
SYN_FILES += lib/axis/rtl/axis_fifo.v
SYN_FILES += lib/axis/rtl/axis_register.v
SYN_FILES += lib/axis/rtl/axis_async_fifo.v
SYN_FILES += lib/axis/rtl/axis_async_fifo_adapter.v
SYN_FILES += lib/axis/rtl/sync_reset.v

# IP files
IP_TCL_FILES += ip/reset_release.tcl
IP_TCL_FILES += ip/iopll.tcl
IP_TCL_FILES += ip/eth_xcvr.tcl
IP_TCL_FILES += ip/eth_xcvr_pll.tcl
IP_TCL_FILES += ip/eth_xcvr_reset.tcl

# QSF files
QSF_FILES = fpga.qsf

# SDC files
SDC_FILES = fpga.sdc

include ../common/quartus_pro.mk

program: fpga
	quartus_pgm --no_banner --mode=jtag -o "P;$(FPGA_TOP).sof@1"
