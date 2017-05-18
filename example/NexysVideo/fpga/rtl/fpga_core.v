/*

Copyright (c) 2017 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * FPGA core logic
 */
module fpga_core #
(
    parameter TARGET = "XILINX"
)
(
    /*
     * Clock: 125MHz
     * Synchronous reset
     */
    input  wire       clk,
    input  wire       clk90,
    input  wire       rst,

    /*
     * GPIO
     */
    input  wire       btnu,
    input  wire       btnl,
    input  wire       btnd,
    input  wire       btnr,
    input  wire       btnc,
    input  wire [7:0] sw,
    output wire [7:0] led,

    /*
     * I2C
     */
    input  wire       i2c_scl_i,
    output wire       i2c_scl_o,
    output wire       i2c_scl_t,
    input  wire       i2c_sda_i,
    output wire       i2c_sda_o,
    output wire       i2c_sda_t,

    /*
     * Ethernet: 1000BASE-T RGMII
     */
    input  wire       phy_rx_clk,
    input  wire [3:0] phy_rxd,
    input  wire       phy_rx_ctl,
    output wire       phy_tx_clk,
    output wire [3:0] phy_txd,
    output wire       phy_tx_ctl,
    output wire       phy_reset_n,
    input  wire       phy_int_n,
    input  wire       phy_pme_n,

    /*
     * UART: 115200 bps, 8N1
     */
    input  wire       uart_rxd,
    output wire       uart_txd
);

// XFCP UART interface
wire [7:0] xfcp_uart_interface_down_tdata;
wire xfcp_uart_interface_down_tvalid;
wire xfcp_uart_interface_down_tready;
wire xfcp_uart_interface_down_tlast;
wire xfcp_uart_interface_down_tuser;

wire [7:0] xfcp_uart_interface_up_tdata;
wire xfcp_uart_interface_up_tvalid;
wire xfcp_uart_interface_up_tready;
wire xfcp_uart_interface_up_tlast;
wire xfcp_uart_interface_up_tuser;

xfcp_interface_uart
xfcp_interface_uart_inst (
    .clk(clk),
    .rst(rst),
    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd),
    .down_xfcp_in_tdata(xfcp_uart_interface_up_tdata),
    .down_xfcp_in_tvalid(xfcp_uart_interface_up_tvalid),
    .down_xfcp_in_tready(xfcp_uart_interface_up_tready),
    .down_xfcp_in_tlast(xfcp_uart_interface_up_tlast),
    .down_xfcp_in_tuser(xfcp_uart_interface_up_tuser),
    .down_xfcp_out_tdata(xfcp_uart_interface_down_tdata),
    .down_xfcp_out_tvalid(xfcp_uart_interface_down_tvalid),
    .down_xfcp_out_tready(xfcp_uart_interface_down_tready),
    .down_xfcp_out_tlast(xfcp_uart_interface_down_tlast),
    .down_xfcp_out_tuser(xfcp_uart_interface_down_tuser),
    .prescale(125000000/(115200*8))
);

// XFCP Ethernet interface
wire [7:0] xfcp_udp_interface_down_tdata;
wire xfcp_udp_interface_down_tvalid;
wire xfcp_udp_interface_down_tready;
wire xfcp_udp_interface_down_tlast;
wire xfcp_udp_interface_down_tuser;

wire [7:0] xfcp_udp_interface_up_tdata;
wire xfcp_udp_interface_up_tvalid;
wire xfcp_udp_interface_up_tready;
wire xfcp_udp_interface_up_tlast;
wire xfcp_udp_interface_up_tuser;

// GMII between MAC and PHY IF
wire gmii_rx_clk;
wire gmii_rx_rst;
wire [7:0] gmii_rxd;
wire gmii_rx_dv;
wire gmii_rx_er;

wire gmii_tx_clk;
wire gmii_tx_rst;
wire [7:0] gmii_txd;
wire gmii_tx_en;
wire gmii_tx_er;

// AXI between MAC and Ethernet modules
wire [7:0] rx_eth_axis_tdata;
wire rx_eth_axis_tvalid;
wire rx_eth_axis_tready;
wire rx_eth_axis_tlast;
wire rx_eth_axis_tuser;

wire [7:0] tx_eth_axis_tdata;
wire tx_eth_axis_tvalid;
wire tx_eth_axis_tready;
wire tx_eth_axis_tlast;
wire tx_eth_axis_tuser;

// Configuration
wire [47:0] local_mac   = 48'h02_00_00_00_00_00;
wire [31:0] local_ip    = {8'd192, 8'd168, 8'd1,   8'd128};
wire [15:0] local_port  = 16'd14000;
wire [31:0] gateway_ip  = {8'd192, 8'd168, 8'd1,   8'd1};
wire [31:0] subnet_mask = {8'd255, 8'd255, 8'd255, 8'd0};

assign phy_reset_n = ~rst;

assign led = 0;

rgmii_phy_if #(
    .TARGET(TARGET),
    .IODDR_STYLE("IODDR"),
    .CLOCK_INPUT_STYLE("BUFR"),
    .USE_CLK90("TRUE")
)
rgmii_phy_if_inst (
    .clk(clk),
    .clk90(clk90),
    .rst(rst),

    .mac_gmii_rx_clk(gmii_rx_clk),
    .mac_gmii_rx_rst(gmii_rx_rst),
    .mac_gmii_rxd(gmii_rxd),
    .mac_gmii_rx_dv(gmii_rx_dv),
    .mac_gmii_rx_er(gmii_rx_er),
    .mac_gmii_tx_clk(gmii_tx_clk),
    .mac_gmii_tx_rst(gmii_tx_rst),
    .mac_gmii_txd(gmii_txd),
    .mac_gmii_tx_en(gmii_tx_en),
    .mac_gmii_tx_er(gmii_tx_er),

    .phy_rgmii_rx_clk(phy_rx_clk),
    .phy_rgmii_rxd(phy_rxd),
    .phy_rgmii_rx_ctl(phy_rx_ctl),
    .phy_rgmii_tx_clk(phy_tx_clk),
    .phy_rgmii_txd(phy_txd),
    .phy_rgmii_tx_ctl(phy_tx_ctl)
);

eth_mac_1g_fifo #(
    .ENABLE_PADDING(1),
    .MIN_FRAME_LENGTH(64),
    .TX_FIFO_ADDR_WIDTH(12),
    .RX_FIFO_ADDR_WIDTH(12)
)
eth_mac_1g_fifo_inst (
    .rx_clk(gmii_rx_clk),
    .rx_rst(gmii_rx_rst),
    .tx_clk(gmii_tx_clk),
    .tx_rst(gmii_tx_rst),
    .logic_clk(clk),
    .logic_rst(rst),

    .tx_axis_tdata(tx_eth_axis_tdata),
    .tx_axis_tvalid(tx_eth_axis_tvalid),
    .tx_axis_tready(tx_eth_axis_tready),
    .tx_axis_tlast(tx_eth_axis_tlast),
    .tx_axis_tuser(tx_eth_axis_tuser),

    .rx_axis_tdata(rx_eth_axis_tdata),
    .rx_axis_tvalid(rx_eth_axis_tvalid),
    .rx_axis_tready(rx_eth_axis_tready),
    .rx_axis_tlast(rx_eth_axis_tlast),
    .rx_axis_tuser(rx_eth_axis_tuser),

    .gmii_rxd(gmii_rxd),
    .gmii_rx_dv(gmii_rx_dv),
    .gmii_rx_er(gmii_rx_er),
    .gmii_txd(gmii_txd),
    .gmii_tx_en(gmii_tx_en),
    .gmii_tx_er(gmii_tx_er),

    .rx_error_bad_frame(rx_error_bad_frame),
    .rx_error_bad_fcs(rx_error_bad_fcs),

    .ifg_delay(12)
);

xfcp_interface_udp
xfcp_interface_udp_inst (
    .clk(clk),
    .rst(rst),
    .input_eth_axis_tdata(rx_eth_axis_tdata),
    .input_eth_axis_tvalid(rx_eth_axis_tvalid),
    .input_eth_axis_tready(rx_eth_axis_tready),
    .input_eth_axis_tlast(rx_eth_axis_tlast),
    .input_eth_axis_tuser(rx_eth_axis_tuser),
    .output_eth_axis_tdata(tx_eth_axis_tdata),
    .output_eth_axis_tvalid(tx_eth_axis_tvalid),
    .output_eth_axis_tready(tx_eth_axis_tready),
    .output_eth_axis_tlast(tx_eth_axis_tlast),
    .output_eth_axis_tuser(tx_eth_axis_tuser),
    .down_xfcp_in_tdata(xfcp_udp_interface_up_tdata),
    .down_xfcp_in_tvalid(xfcp_udp_interface_up_tvalid),
    .down_xfcp_in_tready(xfcp_udp_interface_up_tready),
    .down_xfcp_in_tlast(xfcp_udp_interface_up_tlast),
    .down_xfcp_in_tuser(xfcp_udp_interface_up_tuser),
    .down_xfcp_out_tdata(xfcp_udp_interface_down_tdata),
    .down_xfcp_out_tvalid(xfcp_udp_interface_down_tvalid),
    .down_xfcp_out_tready(xfcp_udp_interface_down_tready),
    .down_xfcp_out_tlast(xfcp_udp_interface_down_tlast),
    .down_xfcp_out_tuser(xfcp_udp_interface_down_tuser),
    .local_mac(local_mac),
    .local_ip(local_ip),
    .local_port(local_port),
    .gateway_ip(gateway_ip),
    .subnet_mask(subnet_mask)
);

// XFCP 2x1 switch
wire [7:0] xfcp_interface_switch_down_tdata;
wire xfcp_interface_switch_down_tvalid;
wire xfcp_interface_switch_down_tready;
wire xfcp_interface_switch_down_tlast;
wire xfcp_interface_switch_down_tuser;

wire [7:0] xfcp_interface_switch_up_tdata;
wire xfcp_interface_switch_up_tvalid;
wire xfcp_interface_switch_up_tready;
wire xfcp_interface_switch_up_tlast;
wire xfcp_interface_switch_up_tuser;

xfcp_switch_2x1
xfcp_interface_switch_inst (
    .clk(clk),
    .rst(rst),
    .up_xfcp_0_in_tdata(xfcp_uart_interface_down_tdata),
    .up_xfcp_0_in_tvalid(xfcp_uart_interface_down_tvalid),
    .up_xfcp_0_in_tready(xfcp_uart_interface_down_tready),
    .up_xfcp_0_in_tlast(xfcp_uart_interface_down_tlast),
    .up_xfcp_0_in_tuser(xfcp_uart_interface_down_tuser),
    .up_xfcp_0_out_tdata(xfcp_uart_interface_up_tdata),
    .up_xfcp_0_out_tvalid(xfcp_uart_interface_up_tvalid),
    .up_xfcp_0_out_tready(xfcp_uart_interface_up_tready),
    .up_xfcp_0_out_tlast(xfcp_uart_interface_up_tlast),
    .up_xfcp_0_out_tuser(xfcp_uart_interface_up_tuser),
    .up_xfcp_1_in_tdata(xfcp_udp_interface_down_tdata),
    .up_xfcp_1_in_tvalid(xfcp_udp_interface_down_tvalid),
    .up_xfcp_1_in_tready(xfcp_udp_interface_down_tready),
    .up_xfcp_1_in_tlast(xfcp_udp_interface_down_tlast),
    .up_xfcp_1_in_tuser(xfcp_udp_interface_down_tuser),
    .up_xfcp_1_out_tdata(xfcp_udp_interface_up_tdata),
    .up_xfcp_1_out_tvalid(xfcp_udp_interface_up_tvalid),
    .up_xfcp_1_out_tready(xfcp_udp_interface_up_tready),
    .up_xfcp_1_out_tlast(xfcp_udp_interface_up_tlast),
    .up_xfcp_1_out_tuser(xfcp_udp_interface_up_tuser),
    .down_xfcp_in_tdata(xfcp_interface_switch_up_tdata),
    .down_xfcp_in_tvalid(xfcp_interface_switch_up_tvalid),
    .down_xfcp_in_tready(xfcp_interface_switch_up_tready),
    .down_xfcp_in_tlast(xfcp_interface_switch_up_tlast),
    .down_xfcp_in_tuser(xfcp_interface_switch_up_tuser),
    .down_xfcp_out_tdata(xfcp_interface_switch_down_tdata),
    .down_xfcp_out_tvalid(xfcp_interface_switch_down_tvalid),
    .down_xfcp_out_tready(xfcp_interface_switch_down_tready),
    .down_xfcp_out_tlast(xfcp_interface_switch_down_tlast),
    .down_xfcp_out_tuser(xfcp_interface_switch_down_tuser)
);

// XFCP 1x4 switch
wire [7:0] xfcp_switch_port_0_down_tdata;
wire xfcp_switch_port_0_down_tvalid;
wire xfcp_switch_port_0_down_tready;
wire xfcp_switch_port_0_down_tlast;
wire xfcp_switch_port_0_down_tuser;

wire [7:0] xfcp_switch_port_0_up_tdata;
wire xfcp_switch_port_0_up_tvalid;
wire xfcp_switch_port_0_up_tready;
wire xfcp_switch_port_0_up_tlast;
wire xfcp_switch_port_0_up_tuser;

wire [7:0] xfcp_switch_port_1_down_tdata;
wire xfcp_switch_port_1_down_tvalid;
wire xfcp_switch_port_1_down_tready;
wire xfcp_switch_port_1_down_tlast;
wire xfcp_switch_port_1_down_tuser;

wire [7:0] xfcp_switch_port_1_up_tdata;
wire xfcp_switch_port_1_up_tvalid;
wire xfcp_switch_port_1_up_tready;
wire xfcp_switch_port_1_up_tlast;
wire xfcp_switch_port_1_up_tuser;

wire [7:0] xfcp_switch_port_2_down_tdata;
wire xfcp_switch_port_2_down_tvalid;
wire xfcp_switch_port_2_down_tready;
wire xfcp_switch_port_2_down_tlast;
wire xfcp_switch_port_2_down_tuser;

wire [7:0] xfcp_switch_port_2_up_tdata;
wire xfcp_switch_port_2_up_tvalid;
wire xfcp_switch_port_2_up_tready;
wire xfcp_switch_port_2_up_tlast;
wire xfcp_switch_port_2_up_tuser;

wire [7:0] xfcp_switch_port_3_down_tdata;
wire xfcp_switch_port_3_down_tvalid;
wire xfcp_switch_port_3_down_tready;
wire xfcp_switch_port_3_down_tlast;
wire xfcp_switch_port_3_down_tuser;

wire [7:0] xfcp_switch_port_3_up_tdata;
wire xfcp_switch_port_3_up_tvalid;
wire xfcp_switch_port_3_up_tready;
wire xfcp_switch_port_3_up_tlast;
wire xfcp_switch_port_3_up_tuser;

xfcp_switch_1x4 #(
    .XFCP_ID_TYPE(16'h0100),
    .XFCP_ID_STR("XFCP switch"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR("NexysVideo")
)
xfcp_switch_inst (
    .clk(clk),
    .rst(rst),
    .up_xfcp_in_tdata(xfcp_interface_switch_down_tdata),
    .up_xfcp_in_tvalid(xfcp_interface_switch_down_tvalid),
    .up_xfcp_in_tready(xfcp_interface_switch_down_tready),
    .up_xfcp_in_tlast(xfcp_interface_switch_down_tlast),
    .up_xfcp_in_tuser(xfcp_interface_switch_down_tuser),
    .up_xfcp_out_tdata(xfcp_interface_switch_up_tdata),
    .up_xfcp_out_tvalid(xfcp_interface_switch_up_tvalid),
    .up_xfcp_out_tready(xfcp_interface_switch_up_tready),
    .up_xfcp_out_tlast(xfcp_interface_switch_up_tlast),
    .up_xfcp_out_tuser(xfcp_interface_switch_up_tuser),
    .down_xfcp_0_in_tdata(xfcp_switch_port_0_up_tdata),
    .down_xfcp_0_in_tvalid(xfcp_switch_port_0_up_tvalid),
    .down_xfcp_0_in_tready(xfcp_switch_port_0_up_tready),
    .down_xfcp_0_in_tlast(xfcp_switch_port_0_up_tlast),
    .down_xfcp_0_in_tuser(xfcp_switch_port_0_up_tuser),
    .down_xfcp_0_out_tdata(xfcp_switch_port_0_down_tdata),
    .down_xfcp_0_out_tvalid(xfcp_switch_port_0_down_tvalid),
    .down_xfcp_0_out_tready(xfcp_switch_port_0_down_tready),
    .down_xfcp_0_out_tlast(xfcp_switch_port_0_down_tlast),
    .down_xfcp_0_out_tuser(xfcp_switch_port_0_down_tuser),
    .down_xfcp_1_in_tdata(xfcp_switch_port_1_up_tdata),
    .down_xfcp_1_in_tvalid(xfcp_switch_port_1_up_tvalid),
    .down_xfcp_1_in_tready(xfcp_switch_port_1_up_tready),
    .down_xfcp_1_in_tlast(xfcp_switch_port_1_up_tlast),
    .down_xfcp_1_in_tuser(xfcp_switch_port_1_up_tuser),
    .down_xfcp_1_out_tdata(xfcp_switch_port_1_down_tdata),
    .down_xfcp_1_out_tvalid(xfcp_switch_port_1_down_tvalid),
    .down_xfcp_1_out_tready(xfcp_switch_port_1_down_tready),
    .down_xfcp_1_out_tlast(xfcp_switch_port_1_down_tlast),
    .down_xfcp_1_out_tuser(xfcp_switch_port_1_down_tuser),
    .down_xfcp_2_in_tdata(xfcp_switch_port_2_up_tdata),
    .down_xfcp_2_in_tvalid(xfcp_switch_port_2_up_tvalid),
    .down_xfcp_2_in_tready(xfcp_switch_port_2_up_tready),
    .down_xfcp_2_in_tlast(xfcp_switch_port_2_up_tlast),
    .down_xfcp_2_in_tuser(xfcp_switch_port_2_up_tuser),
    .down_xfcp_2_out_tdata(xfcp_switch_port_2_down_tdata),
    .down_xfcp_2_out_tvalid(xfcp_switch_port_2_down_tvalid),
    .down_xfcp_2_out_tready(xfcp_switch_port_2_down_tready),
    .down_xfcp_2_out_tlast(xfcp_switch_port_2_down_tlast),
    .down_xfcp_2_out_tuser(xfcp_switch_port_2_down_tuser),
    .down_xfcp_3_in_tdata(xfcp_switch_port_3_up_tdata),
    .down_xfcp_3_in_tvalid(xfcp_switch_port_3_up_tvalid),
    .down_xfcp_3_in_tready(xfcp_switch_port_3_up_tready),
    .down_xfcp_3_in_tlast(xfcp_switch_port_3_up_tlast),
    .down_xfcp_3_in_tuser(xfcp_switch_port_3_up_tuser),
    .down_xfcp_3_out_tdata(xfcp_switch_port_3_down_tdata),
    .down_xfcp_3_out_tvalid(xfcp_switch_port_3_down_tvalid),
    .down_xfcp_3_out_tready(xfcp_switch_port_3_down_tready),
    .down_xfcp_3_out_tlast(xfcp_switch_port_3_down_tlast),
    .down_xfcp_3_out_tuser(xfcp_switch_port_3_down_tuser)
);

// XFCP WB RAM 0
wire [7:0] ram_0_wb_adr_i;
wire [31:0] ram_0_wb_dat_i;
wire [31:0] ram_0_wb_dat_o;
wire ram_0_wb_we_i;
wire [3:0] ram_0_wb_sel_i;
wire ram_0_wb_stb_i;
wire ram_0_wb_ack_o;
wire ram_0_wb_cyc_i;

xfcp_mod_wb #(
    .XFCP_ID_STR("XFCP RAM 0"),
    .COUNT_SIZE(16),
    .WB_DATA_WIDTH(32),
    .WB_ADDR_WIDTH(8),
    .WB_SELECT_WIDTH(4)
)
xfcp_mod_wb_ram_0 (
    .clk(clk),
    .rst(rst),
    .up_xfcp_in_tdata(xfcp_switch_port_0_down_tdata),
    .up_xfcp_in_tvalid(xfcp_switch_port_0_down_tvalid),
    .up_xfcp_in_tready(xfcp_switch_port_0_down_tready),
    .up_xfcp_in_tlast(xfcp_switch_port_0_down_tlast),
    .up_xfcp_in_tuser(xfcp_switch_port_0_down_tuser),
    .up_xfcp_out_tdata(xfcp_switch_port_0_up_tdata),
    .up_xfcp_out_tvalid(xfcp_switch_port_0_up_tvalid),
    .up_xfcp_out_tready(xfcp_switch_port_0_up_tready),
    .up_xfcp_out_tlast(xfcp_switch_port_0_up_tlast),
    .up_xfcp_out_tuser(xfcp_switch_port_0_up_tuser),
    .wb_adr_o(ram_0_wb_adr_i),
    .wb_dat_i(ram_0_wb_dat_o),
    .wb_dat_o(ram_0_wb_dat_i),
    .wb_we_o(ram_0_wb_we_i),
    .wb_sel_o(ram_0_wb_sel_i),
    .wb_stb_o(ram_0_wb_stb_i),
    .wb_ack_i(ram_0_wb_ack_o),
    .wb_err_i(1'b0),
    .wb_cyc_o(ram_0_wb_cyc_i)
);

wb_ram #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8),
    .SELECT_WIDTH(4)
)
ram_0_inst (
    .clk(clk),
    .adr_i(ram_0_wb_adr_i),
    .dat_i(ram_0_wb_dat_i),
    .dat_o(ram_0_wb_dat_o),
    .we_i(ram_0_wb_we_i),
    .sel_i(ram_0_wb_sel_i),
    .stb_i(ram_0_wb_stb_i),
    .ack_o(ram_0_wb_ack_o),
    .cyc_i(ram_0_wb_cyc_i)
);

// XFCP WB RAM 1
wire [7:0] ram_1_wb_adr_i;
wire [31:0] ram_1_wb_dat_i;
wire [31:0] ram_1_wb_dat_o;
wire ram_1_wb_we_i;
wire [3:0] ram_1_wb_sel_i;
wire ram_1_wb_stb_i;
wire ram_1_wb_ack_o;
wire ram_1_wb_cyc_i;

xfcp_mod_wb #(
    .XFCP_ID_STR("XFCP RAM 1"),
    .COUNT_SIZE(16),
    .WB_DATA_WIDTH(32),
    .WB_ADDR_WIDTH(8),
    .WB_SELECT_WIDTH(4)
)
xfcp_mod_wb_ram_1 (
    .clk(clk),
    .rst(rst),
    .up_xfcp_in_tdata(xfcp_switch_port_1_down_tdata),
    .up_xfcp_in_tvalid(xfcp_switch_port_1_down_tvalid),
    .up_xfcp_in_tready(xfcp_switch_port_1_down_tready),
    .up_xfcp_in_tlast(xfcp_switch_port_1_down_tlast),
    .up_xfcp_in_tuser(xfcp_switch_port_1_down_tuser),
    .up_xfcp_out_tdata(xfcp_switch_port_1_up_tdata),
    .up_xfcp_out_tvalid(xfcp_switch_port_1_up_tvalid),
    .up_xfcp_out_tready(xfcp_switch_port_1_up_tready),
    .up_xfcp_out_tlast(xfcp_switch_port_1_up_tlast),
    .up_xfcp_out_tuser(xfcp_switch_port_1_up_tuser),
    .wb_adr_o(ram_1_wb_adr_i),
    .wb_dat_i(ram_1_wb_dat_o),
    .wb_dat_o(ram_1_wb_dat_i),
    .wb_we_o(ram_1_wb_we_i),
    .wb_sel_o(ram_1_wb_sel_i),
    .wb_stb_o(ram_1_wb_stb_i),
    .wb_ack_i(ram_1_wb_ack_o),
    .wb_err_i(1'b0),
    .wb_cyc_o(ram_1_wb_cyc_i)
);

wb_ram #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8),
    .SELECT_WIDTH(4)
)
ram_1_inst (
    .clk(clk),
    .adr_i(ram_1_wb_adr_i),
    .dat_i(ram_1_wb_dat_i),
    .dat_o(ram_1_wb_dat_o),
    .we_i(ram_1_wb_we_i),
    .sel_i(ram_1_wb_sel_i),
    .stb_i(ram_1_wb_stb_i),
    .ack_o(ram_1_wb_ack_o),
    .cyc_i(ram_1_wb_cyc_i)
);

// XFCP WB RAM 2
wire [7:0] ram_2_wb_adr_i;
wire [31:0] ram_2_wb_dat_i;
wire [31:0] ram_2_wb_dat_o;
wire ram_2_wb_we_i;
wire [3:0] ram_2_wb_sel_i;
wire ram_2_wb_stb_i;
wire ram_2_wb_ack_o;
wire ram_2_wb_cyc_i;

xfcp_mod_wb #(
    .XFCP_ID_STR("XFCP RAM 2"),
    .COUNT_SIZE(16),
    .WB_DATA_WIDTH(32),
    .WB_ADDR_WIDTH(8),
    .WB_SELECT_WIDTH(4)
)
xfcp_mod_wb_ram_2 (
    .clk(clk),
    .rst(rst),
    .up_xfcp_in_tdata(xfcp_switch_port_2_down_tdata),
    .up_xfcp_in_tvalid(xfcp_switch_port_2_down_tvalid),
    .up_xfcp_in_tready(xfcp_switch_port_2_down_tready),
    .up_xfcp_in_tlast(xfcp_switch_port_2_down_tlast),
    .up_xfcp_in_tuser(xfcp_switch_port_2_down_tuser),
    .up_xfcp_out_tdata(xfcp_switch_port_2_up_tdata),
    .up_xfcp_out_tvalid(xfcp_switch_port_2_up_tvalid),
    .up_xfcp_out_tready(xfcp_switch_port_2_up_tready),
    .up_xfcp_out_tlast(xfcp_switch_port_2_up_tlast),
    .up_xfcp_out_tuser(xfcp_switch_port_2_up_tuser),
    .wb_adr_o(ram_2_wb_adr_i),
    .wb_dat_i(ram_2_wb_dat_o),
    .wb_dat_o(ram_2_wb_dat_i),
    .wb_we_o(ram_2_wb_we_i),
    .wb_sel_o(ram_2_wb_sel_i),
    .wb_stb_o(ram_2_wb_stb_i),
    .wb_ack_i(ram_2_wb_ack_o),
    .wb_err_i(1'b0),
    .wb_cyc_o(ram_2_wb_cyc_i)
);

wb_ram #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8),
    .SELECT_WIDTH(4)
)
ram_2_inst (
    .clk(clk),
    .adr_i(ram_2_wb_adr_i),
    .dat_i(ram_2_wb_dat_i),
    .dat_o(ram_2_wb_dat_o),
    .we_i(ram_2_wb_we_i),
    .sel_i(ram_2_wb_sel_i),
    .stb_i(ram_2_wb_stb_i),
    .ack_o(ram_2_wb_ack_o),
    .cyc_i(ram_2_wb_cyc_i)
);

// XFCP I2C Master
xfcp_mod_i2c_master #(
    .XFCP_ID_STR("XFCP I2C Master"),
    .DEFAULT_PRESCALE(125000000/(400000*4))
)
i2c_master_inst (
    .clk(clk),
    .rst(rst),
    .up_xfcp_in_tdata(xfcp_switch_port_3_down_tdata),
    .up_xfcp_in_tvalid(xfcp_switch_port_3_down_tvalid),
    .up_xfcp_in_tready(xfcp_switch_port_3_down_tready),
    .up_xfcp_in_tlast(xfcp_switch_port_3_down_tlast),
    .up_xfcp_in_tuser(xfcp_switch_port_3_down_tuser),
    .up_xfcp_out_tdata(xfcp_switch_port_3_up_tdata),
    .up_xfcp_out_tvalid(xfcp_switch_port_3_up_tvalid),
    .up_xfcp_out_tready(xfcp_switch_port_3_up_tready),
    .up_xfcp_out_tlast(xfcp_switch_port_3_up_tlast),
    .up_xfcp_out_tuser(xfcp_switch_port_3_up_tuser),
    .i2c_scl_i(i2c_scl_i),
    .i2c_scl_o(i2c_scl_o),
    .i2c_scl_t(i2c_scl_t),
    .i2c_sda_i(i2c_sda_i),
    .i2c_sda_o(i2c_sda_o),
    .i2c_sda_t(i2c_sda_t)
);

endmodule
