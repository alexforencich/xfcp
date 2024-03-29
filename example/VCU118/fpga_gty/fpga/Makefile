
# FPGA settings
FPGA_PART = xcvu9p-flga2104-2L-e
FPGA_TOP = fpga
FPGA_ARCH = virtexuplus

# Files for synthesis
SYN_FILES = rtl/fpga.v
SYN_FILES += rtl/fpga_core.v
SYN_FILES += rtl/debounce_switch.v
SYN_FILES += rtl/sync_signal.v
SYN_FILES += rtl/mdio_master.v
SYN_FILES += lib/xfcp/rtl/xfcp_interface_uart.v
SYN_FILES += lib/xfcp/rtl/xfcp_interface_udp.v
SYN_FILES += lib/xfcp/rtl/xfcp_mod_i2c_master.v
SYN_FILES += lib/xfcp/rtl/xfcp_mod_wb.v
SYN_FILES += lib/xfcp/rtl/xfcp_mod_drp.v
SYN_FILES += lib/xfcp/rtl/xfcp_mod_gty.v
SYN_FILES += lib/xfcp/rtl/xfcp_gty_quad.v
SYN_FILES += lib/xfcp/rtl/wb_drp.v
SYN_FILES += lib/xfcp/rtl/xfcp_arb.v
SYN_FILES += lib/xfcp/rtl/xfcp_switch.v
SYN_FILES += lib/eth/rtl/eth_mac_1g_fifo.v
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
XDC_FILES += lib/eth/syn/vivado/eth_mac_fifo.tcl
XDC_FILES += lib/axis/syn/vivado/axis_async_fifo.tcl
XDC_FILES += lib/axis/syn/vivado/sync_reset.tcl
XDC_FILES += lib/xfcp/syn/vivado/xfcp_mod_gty.tcl

# IP
IP_TCL_FILES = ip/gig_ethernet_pcs_pma_0.tcl
IP_TCL_FILES += ip/gtwizard_ultrascale_0.tcl

include ../common/vivado.mk

program: $(FPGA_TOP).bit
	echo "open_hw" > program.tcl
	echo "connect_hw_server" >> program.tcl
	echo "open_hw_target" >> program.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> program.tcl
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> program.tcl
	echo "set_property PROGRAM.FILE {$(FPGA_TOP).bit} [current_hw_device]" >> program.tcl
	echo "program_hw_devices [current_hw_device]" >> program.tcl
	echo "exit" >> program.tcl
	vivado -nojournal -nolog -mode batch -source program.tcl

%_primary.mcs %_secondary.mcs %_primary.prm %_secondary.prm: %.bit
	echo "write_cfgmem -force -format mcs -size 256 -interface SPIx8 -loadbit {up 0x0000000 $*.bit} -checksum -file $*.mcs" > generate_mcs.tcl
	echo "exit" >> generate_mcs.tcl
	vivado -nojournal -nolog -mode batch -source generate_mcs.tcl
	mkdir -p rev
	COUNT=100; \
	while [ -e rev/$*_rev$$COUNT.bit ]; \
	do COUNT=$$((COUNT+1)); done; \
	COUNT=$$((COUNT-1)); \
	for x in _primary.mcs _secondary.mcs _primary.prm _secondary.prm; \
	do cp $*$$x rev/$*_rev$$COUNT$$x; \
	echo "Output: rev/$*_rev$$COUNT$$x"; done;

flash: $(FPGA_TOP)_primary.mcs $(FPGA_TOP)_secondary.mcs $(FPGA_TOP)_primary.prm $(FPGA_TOP)_secondary.prm
	echo "open_hw" > flash.tcl
	echo "connect_hw_server" >> flash.tcl
	echo "open_hw_target" >> flash.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> flash.tcl
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> flash.tcl
	echo "create_hw_cfgmem -hw_device [current_hw_device] [lindex [get_cfgmem_parts {mt25qu01g-spi-x1_x2_x4_x8}] 0]" >> flash.tcl
	echo "current_hw_cfgmem -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM [current_hw_device]]" >> flash.tcl
	echo "set_property PROGRAM.FILES [list \"$(FPGA_TOP)_primary.mcs\" \"$(FPGA_TOP)_secondary.mcs\"] [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.PRM_FILES [list \"$(FPGA_TOP)_primary.prm\" \"$(FPGA_TOP)_secondary.prm\"] [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.ERASE 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.CFG_PROGRAM 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.VERIFY 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.CHECKSUM 0 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.ADDRESS_RANGE {use_file} [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [current_hw_cfgmem]" >> flash.tcl
	echo "create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [current_hw_device]]" >> flash.tcl
	echo "program_hw_devices [current_hw_device]" >> flash.tcl
	echo "refresh_hw_device [current_hw_device]" >> flash.tcl
	echo "program_hw_cfgmem -hw_cfgmem [current_hw_cfgmem]" >> flash.tcl
	echo "boot_hw_device [current_hw_device]" >> flash.tcl
	echo "exit" >> flash.tcl
	vivado -nojournal -nolog -mode batch -source flash.tcl

