
# FPGA settings
FPGA_PART = xc7a200t-sbg484-1
FPGA_TOP = fpga
FPGA_ARCH = artix7

# Files for synthesis
SYN_FILES = rtl/fpga.v
SYN_FILES += rtl/fpga_core.v
SYN_FILES += rtl/debounce_switch.v
SYN_FILES += rtl/sync_signal.v
SYN_FILES += lib/xfcp/rtl/xfcp_interface_uart.v
SYN_FILES += lib/xfcp/rtl/xfcp_interface_udp.v
SYN_FILES += lib/xfcp/rtl/xfcp_mod_i2c_master.v
SYN_FILES += lib/xfcp/rtl/xfcp_mod_wb.v
SYN_FILES += lib/xfcp/rtl/xfcp_arb.v
SYN_FILES += lib/xfcp/rtl/xfcp_switch.v
SYN_FILES += lib/eth/rtl/iddr.v
SYN_FILES += lib/eth/rtl/oddr.v
SYN_FILES += lib/eth/rtl/ssio_ddr_in.v
SYN_FILES += lib/eth/rtl/ssio_ddr_out.v
SYN_FILES += lib/eth/rtl/rgmii_phy_if.v
SYN_FILES += lib/eth/rtl/eth_mac_1g_rgmii_fifo.v
SYN_FILES += lib/eth/rtl/eth_mac_1g_rgmii.v
SYN_FILES += lib/eth/rtl/eth_mac_1g.v
SYN_FILES += lib/eth/rtl/axis_gmii_rx.v
SYN_FILES += lib/eth/rtl/axis_gmii_tx.v
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
SYN_FILES += lib/uart/rtl/uart.v
SYN_FILES += lib/uart/rtl/uart_rx.v
SYN_FILES += lib/uart/rtl/uart_tx.v
SYN_FILES += lib/wb/rtl/wb_ram.v
SYN_FILES += lib/axis/rtl/arbiter.v
SYN_FILES += lib/axis/rtl/priority_encoder.v
SYN_FILES += lib/axis/rtl/axis_cobs_encode.v
SYN_FILES += lib/axis/rtl/axis_cobs_decode.v
SYN_FILES += lib/axis/rtl/axis_fifo.v
SYN_FILES += lib/axis/rtl/axis_async_fifo.v
SYN_FILES += lib/axis/rtl/axis_async_fifo_adapter.v
SYN_FILES += lib/axis/rtl/sync_reset.v

# XDC files
XDC_FILES = fpga.xdc
XDC_FILES += eth.xdc
XDC_FILES += lib/eth/syn/vivado/rgmii_phy_if.tcl
XDC_FILES += lib/eth/syn/vivado/eth_mac_1g_rgmii.tcl
XDC_FILES += lib/eth/syn/vivado/eth_mac_fifo.tcl
XDC_FILES += lib/axis/syn/vivado/axis_async_fifo.tcl
XDC_FILES += lib/axis/syn/vivado/sync_reset.tcl

include ../common/vivado.mk

program: $(FPGA_TOP).bit
	djtgcfg prog -d NexysVideo --index 0 --file $(FPGA_TOP).bit

