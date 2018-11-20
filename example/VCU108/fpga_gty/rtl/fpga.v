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
 * FPGA top-level module
 */
module fpga (
    /*
     * Clock: 125MHz LVDS
     * Reset: Push button, active low
     */
    input  wire       clk_125mhz_p,
    input  wire       clk_125mhz_n,
    input  wire       reset,

    /*
     * GPIO
     */
    input  wire       btnu,
    input  wire       btnl,
    input  wire       btnd,
    input  wire       btnr,
    input  wire       btnc,
    input  wire [3:0] sw,
    output wire [7:0] led,

    /*
     * I2C for board management
     */
    inout  wire       i2c_scl,
    inout  wire       i2c_sda,

    /*
     * Ethernet: QSFP28
     */
    input  wire       qsfp_rx1_p,
    input  wire       qsfp_rx1_n,
    input  wire       qsfp_rx2_p,
    input  wire       qsfp_rx2_n,
    input  wire       qsfp_rx3_n,
    input  wire       qsfp_rx3_p,
    input  wire       qsfp_rx4_p,
    input  wire       qsfp_rx4_n,
    output wire       qsfp_tx1_p,
    output wire       qsfp_tx1_n,
    output wire       qsfp_tx2_p,
    output wire       qsfp_tx2_n,
    output wire       qsfp_tx3_p,
    output wire       qsfp_tx3_n,
    output wire       qsfp_tx4_p,
    output wire       qsfp_tx4_n,
    input  wire       qsfp_mgt_refclk_0_p,
    input  wire       qsfp_mgt_refclk_0_n,
    // input  wire       qsfp_mgt_refclk_1_p,
    // input  wire       qsfp_mgt_refclk_1_n,
    // output wire       qsfp_recclk_p,
    // output wire       qsfp_recclk_n,
    output wire       qsfp_modsell,
    output wire       qsfp_resetl,
    input  wire       qsfp_modprsl,
    input  wire       qsfp_intl,
    output wire       qsfp_lpmode,

    /*
     * Ethernet: 1000BASE-T SGMII
     */
    input  wire       phy_sgmii_rx_p,
    input  wire       phy_sgmii_rx_n,
    output wire       phy_sgmii_tx_p,
    output wire       phy_sgmii_tx_n,
    input  wire       phy_sgmii_clk_p,
    input  wire       phy_sgmii_clk_n,
    output wire       phy_reset_n,
    input  wire       phy_int_n,

    /*
     * UART: 115200 bps, 8N1
     */
    input  wire       uart_rxd,
    output wire       uart_txd,
    output wire       uart_rts,
    input  wire       uart_cts
);

// Clock and reset

wire clk_125mhz_ibufg;
wire clk_125mhz_mmcm_out;
wire clk_62mhz_mmcm_out;

// Internal 125 MHz clock
wire clk_125mhz_int;
wire rst_125mhz_int;

// Internal 62.5 MHz clock
wire clk_62mhz_int;
wire rst_62mhz_int;

wire mmcm_rst = reset;
wire mmcm_locked;
wire mmcm_clkfb;

IBUFGDS #(
   .DIFF_TERM("FALSE"),
   .IBUF_LOW_PWR("FALSE")   
)
clk_125mhz_ibufg_inst (
   .O   (clk_125mhz_ibufg),
   .I   (clk_125mhz_p),
   .IB  (clk_125mhz_n) 
);

// MMCM instance
// 125 MHz in, 125 MHz and 62.5 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 600 MHz to 1440 MHz
// M = 5, D = 1 sets Fvco = 625 MHz (in range)
// Divide by 5 to get output frequency of 125 MHz
// Divide by 10 to get output frequency of 62.5 MHz
MMCME3_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(5),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(10),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT6_PHASE(0),
    .CLKFBOUT_MULT_F(5),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(8.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_125mhz_ibufg),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_125mhz_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(clk_62mhz_mmcm_out),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(mmcm_clkfb),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked)
);

BUFG
clk_125mhz_bufg_inst (
    .I(clk_125mhz_mmcm_out),
    .O(clk_125mhz_int)
);

BUFG
clk_62mhz_bufg_inst (
    .I(clk_62mhz_mmcm_out),
    .O(clk_62mhz_int)
);

sync_reset #(
    .N(4)
)
sync_reset_125mhz_inst (
    .clk(clk_125mhz_int),
    .rst(~mmcm_locked),
    .sync_reset_out(rst_125mhz_int)
);

sync_reset #(
    .N(4)
)
sync_reset_62mhz_inst (
    .clk(clk_62mhz_int),
    .rst(~mmcm_locked),
    .sync_reset_out(rst_62mhz_int)
);

// GPIO
wire btnu_int;
wire btnl_int;
wire btnd_int;
wire btnr_int;
wire btnc_int;
wire [3:0] sw_int;

debounce_switch #(
    .WIDTH(9),
    .N(4),
    .RATE(125000)
)
debounce_switch_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    .in({btnu,
        btnl,
        btnd,
        btnr,
        btnc,
        sw}),
    .out({btnu_int,
        btnl_int,
        btnd_int,
        btnr_int,
        btnc_int,
        sw_int})
);

wire uart_rxd_int;
wire uart_cts_int;

sync_signal #(
    .WIDTH(2),
    .N(2)
)
sync_signal_inst (
    .clk(clk_125mhz_int),
    .in({uart_rxd, uart_cts}),
    .out({uart_rxd_int, uart_cts_int})
);

assign i2c_scl_i = i2c_scl;
assign i2c_scl = i2c_scl_t ? 1'bz : i2c_scl_o;
assign i2c_sda_i = i2c_sda;
assign i2c_sda = i2c_sda_t ? 1'bz : i2c_sda_o;

// GTY instance
assign qsfp_modsell = 1'b0;
assign qsfp_resetl = 1'b1;
assign qsfp_lpmode = 1'b0;

wire gty_drp_clk = clk_62mhz_int;
wire gty_drp_rst = rst_62mhz_int;

wire [7:0] xfcp_mgt_up_tdata;
wire xfcp_mgt_up_tvalid;
wire xfcp_mgt_up_tready;
wire xfcp_mgt_up_tlast;
wire xfcp_mgt_up_tuser;
wire [7:0] xfcp_mgt_down_tdata;
wire xfcp_mgt_down_tvalid;
wire xfcp_mgt_down_tready;
wire xfcp_mgt_down_tlast;
wire xfcp_mgt_down_tuser;

wire [7:0] xfcp_mgt_fifo_up_tdata;
wire xfcp_mgt_fifo_up_tvalid;
wire xfcp_mgt_fifo_up_tready;
wire xfcp_mgt_fifo_up_tlast;
wire xfcp_mgt_fifo_up_tuser;
wire [7:0] xfcp_mgt_fifo_down_tdata;
wire xfcp_mgt_fifo_down_tvalid;
wire xfcp_mgt_fifo_down_tready;
wire xfcp_mgt_fifo_down_tlast;
wire xfcp_mgt_fifo_down_tuser;

wire [7:0] xfcp_gty_1_up_tdata;
wire xfcp_gty_1_up_tvalid;
wire xfcp_gty_1_up_tready;
wire xfcp_gty_1_up_tlast;
wire xfcp_gty_1_up_tuser;
wire [7:0] xfcp_gty_1_down_tdata;
wire xfcp_gty_1_down_tvalid;
wire xfcp_gty_1_down_tready;
wire xfcp_gty_1_down_tlast;
wire xfcp_gty_1_down_tuser;

wire [7:0] xfcp_gty_2_up_tdata;
wire xfcp_gty_2_up_tvalid;
wire xfcp_gty_2_up_tready;
wire xfcp_gty_2_up_tlast;
wire xfcp_gty_2_up_tuser;
wire [7:0] xfcp_gty_2_down_tdata;
wire xfcp_gty_2_down_tvalid;
wire xfcp_gty_2_down_tready;
wire xfcp_gty_2_down_tlast;
wire xfcp_gty_2_down_tuser;

wire [7:0] xfcp_gty_3_up_tdata;
wire xfcp_gty_3_up_tvalid;
wire xfcp_gty_3_up_tready;
wire xfcp_gty_3_up_tlast;
wire xfcp_gty_3_up_tuser;
wire [7:0] xfcp_gty_3_down_tdata;
wire xfcp_gty_3_down_tvalid;
wire xfcp_gty_3_down_tready;
wire xfcp_gty_3_down_tlast;
wire xfcp_gty_3_down_tuser;

wire [7:0] xfcp_gty_4_up_tdata;
wire xfcp_gty_4_up_tvalid;
wire xfcp_gty_4_up_tready;
wire xfcp_gty_4_up_tlast;
wire xfcp_gty_4_up_tuser;
wire [7:0] xfcp_gty_4_down_tdata;
wire xfcp_gty_4_down_tvalid;
wire xfcp_gty_4_down_tready;
wire xfcp_gty_4_down_tlast;
wire xfcp_gty_4_down_tuser;

wire [7:0] xfcp_gty_5_up_tdata;
wire xfcp_gty_5_up_tvalid;
wire xfcp_gty_5_up_tready;
wire xfcp_gty_5_up_tlast;
wire xfcp_gty_5_up_tuser;
wire [7:0] xfcp_gty_5_down_tdata;
wire xfcp_gty_5_down_tvalid;
wire xfcp_gty_5_down_tready;
wire xfcp_gty_5_down_tlast;
wire xfcp_gty_5_down_tuser;

axis_async_fifo #(
    .ADDR_WIDTH(5),
    .DATA_WIDTH(8)
)
xfcp_mgt_fifo_down (
    // Common reset
    .async_rst(rst_125mhz_int | gty_drp_rst),
    // AXI input
    .s_clk(clk_125mhz_int),
    .s_axis_tdata(xfcp_mgt_down_tdata),
    .s_axis_tvalid(xfcp_mgt_down_tvalid),
    .s_axis_tready(xfcp_mgt_down_tready),
    .s_axis_tlast(xfcp_mgt_down_tlast),
    .s_axis_tuser(xfcp_mgt_down_tuser),
    // AXI output
    .m_clk(gty_drp_clk),
    .m_axis_tdata(xfcp_mgt_fifo_down_tdata),
    .m_axis_tvalid(xfcp_mgt_fifo_down_tvalid),
    .m_axis_tready(xfcp_mgt_fifo_down_tready),
    .m_axis_tlast(xfcp_mgt_fifo_down_tlast),
    .m_axis_tuser(xfcp_mgt_fifo_down_tuser)
);

axis_async_fifo #(
    .ADDR_WIDTH(5),
    .DATA_WIDTH(8)
)
xfcp_mgt_fifo_up (
    // Common reset
    .async_rst(rst_125mhz_int | gty_drp_rst),
    // AXI input
    .s_clk(gty_drp_clk),
    .s_axis_tdata(xfcp_mgt_fifo_up_tdata),
    .s_axis_tvalid(xfcp_mgt_fifo_up_tvalid),
    .s_axis_tready(xfcp_mgt_fifo_up_tready),
    .s_axis_tlast(xfcp_mgt_fifo_up_tlast),
    .s_axis_tuser(xfcp_mgt_fifo_up_tuser),
    // AXI output
    .m_clk(clk_125mhz_int),
    .m_axis_tdata(xfcp_mgt_up_tdata),
    .m_axis_tvalid(xfcp_mgt_up_tvalid),
    .m_axis_tready(xfcp_mgt_up_tready),
    .m_axis_tlast(xfcp_mgt_up_tlast),
    .m_axis_tuser(xfcp_mgt_up_tuser)
);

xfcp_switch #(
    .PORTS(5),
    .XFCP_ID_TYPE(16'h0100),
    .XFCP_ID_STR("QSFP GTY QUAD"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR("")
)
xfcp_switch_inst (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_mgt_fifo_down_tdata),
    .up_xfcp_in_tvalid(xfcp_mgt_fifo_down_tvalid),
    .up_xfcp_in_tready(xfcp_mgt_fifo_down_tready),
    .up_xfcp_in_tlast(xfcp_mgt_fifo_down_tlast),
    .up_xfcp_in_tuser(xfcp_mgt_fifo_down_tuser),
    .up_xfcp_out_tdata(xfcp_mgt_fifo_up_tdata),
    .up_xfcp_out_tvalid(xfcp_mgt_fifo_up_tvalid),
    .up_xfcp_out_tready(xfcp_mgt_fifo_up_tready),
    .up_xfcp_out_tlast(xfcp_mgt_fifo_up_tlast),
    .up_xfcp_out_tuser(xfcp_mgt_fifo_up_tuser),
    .down_xfcp_in_tdata(  {xfcp_gty_5_up_tdata,    xfcp_gty_4_up_tdata,    xfcp_gty_3_up_tdata,    xfcp_gty_2_up_tdata,    xfcp_gty_1_up_tdata   }),
    .down_xfcp_in_tvalid( {xfcp_gty_5_up_tvalid,   xfcp_gty_4_up_tvalid,   xfcp_gty_3_up_tvalid,   xfcp_gty_2_up_tvalid,   xfcp_gty_1_up_tvalid  }),
    .down_xfcp_in_tready( {xfcp_gty_5_up_tready,   xfcp_gty_4_up_tready,   xfcp_gty_3_up_tready,   xfcp_gty_2_up_tready,   xfcp_gty_1_up_tready  }),
    .down_xfcp_in_tlast(  {xfcp_gty_5_up_tlast,    xfcp_gty_4_up_tlast,    xfcp_gty_3_up_tlast,    xfcp_gty_2_up_tlast,    xfcp_gty_1_up_tlast   }),
    .down_xfcp_in_tuser(  {xfcp_gty_5_up_tuser,    xfcp_gty_4_up_tuser,    xfcp_gty_3_up_tuser,    xfcp_gty_2_up_tuser,    xfcp_gty_1_up_tuser   }),
    .down_xfcp_out_tdata( {xfcp_gty_5_down_tdata,  xfcp_gty_4_down_tdata,  xfcp_gty_3_down_tdata,  xfcp_gty_2_down_tdata,  xfcp_gty_1_down_tdata }),
    .down_xfcp_out_tvalid({xfcp_gty_5_down_tvalid, xfcp_gty_4_down_tvalid, xfcp_gty_3_down_tvalid, xfcp_gty_2_down_tvalid, xfcp_gty_1_down_tvalid}),
    .down_xfcp_out_tready({xfcp_gty_5_down_tready, xfcp_gty_4_down_tready, xfcp_gty_3_down_tready, xfcp_gty_2_down_tready, xfcp_gty_1_down_tready}),
    .down_xfcp_out_tlast( {xfcp_gty_5_down_tlast,  xfcp_gty_4_down_tlast,  xfcp_gty_3_down_tlast,  xfcp_gty_2_down_tlast,  xfcp_gty_1_down_tlast }),
    .down_xfcp_out_tuser( {xfcp_gty_5_down_tuser,  xfcp_gty_4_down_tuser,  xfcp_gty_3_down_tuser,  xfcp_gty_2_down_tuser,  xfcp_gty_1_down_tuser })
);

wire gty_txusrclk2;
wire gty_rxusrclk2;

wire [9:0] gty_drp_addr_1;
wire [15:0] gty_drp_di_1;
wire [15:0] gty_drp_do_1;
wire gty_drp_rdy_1;
wire gty_drp_en_1;
wire gty_drp_we_1;

wire gty_reset_1;
wire gty_tx_reset_1;
wire gty_rx_reset_1;
wire [3:0] gty_txprbssel_1;
wire gty_txprbsforceerr_1;
wire gty_txpolarity_1;
wire gty_rxpolarity_1;
wire gty_rxprbscntreset_1;
wire [3:0] gty_rxprbssel_1;
wire gty_rxprbserr_1;
wire gty_rxprbslocked_1;

wire [9:0] gty_drp_addr_2;
wire [15:0] gty_drp_di_2;
wire [15:0] gty_drp_do_2;
wire gty_drp_rdy_2;
wire gty_drp_en_2;
wire gty_drp_we_2;

wire gty_reset_2;
wire gty_tx_reset_2;
wire gty_rx_reset_2;
wire [3:0] gty_txprbssel_2;
wire gty_txprbsforceerr_2;
wire gty_txpolarity_2;
wire gty_rxpolarity_2;
wire gty_rxprbscntreset_2;
wire [3:0] gty_rxprbssel_2;
wire gty_rxprbserr_2;
wire gty_rxprbslocked_2;

wire [9:0] gty_drp_addr_3;
wire [15:0] gty_drp_di_3;
wire [15:0] gty_drp_do_3;
wire gty_drp_rdy_3;
wire gty_drp_en_3;
wire gty_drp_we_3;

wire gty_reset_3;
wire gty_tx_reset_3;
wire gty_rx_reset_3;
wire [3:0] gty_txprbssel_3;
wire gty_txprbsforceerr_3;
wire gty_txpolarity_3;
wire gty_rxpolarity_3;
wire gty_rxprbscntreset_3;
wire [3:0] gty_rxprbssel_3;
wire gty_rxprbserr_3;
wire gty_rxprbslocked_3;

wire [9:0] gty_drp_addr_4;
wire [15:0] gty_drp_di_4;
wire [15:0] gty_drp_do_4;
wire gty_drp_rdy_4;
wire gty_drp_en_4;
wire gty_drp_we_4;

wire gty_reset_4;
wire gty_tx_reset_4;
wire gty_rx_reset_4;
wire [3:0] gty_txprbssel_4;
wire gty_txprbsforceerr_4;
wire gty_txpolarity_4;
wire gty_rxpolarity_4;
wire gty_rxprbscntreset_4;
wire [3:0] gty_rxprbssel_4;
wire gty_rxprbserr_4;
wire gty_rxprbslocked_4;

wire [9:0] gty_drp_addr_5;
wire [15:0] gty_drp_di_5;
wire [15:0] gty_drp_do_5;
wire gty_drp_rdy_5;
wire gty_drp_en_5;
wire gty_drp_we_5;

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A83),
    .XFCP_ID_STR("QSFP 1 X0Y12"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_inst_1 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_gty_1_down_tdata),
    .up_xfcp_in_tvalid(xfcp_gty_1_down_tvalid),
    .up_xfcp_in_tready(xfcp_gty_1_down_tready),
    .up_xfcp_in_tlast(xfcp_gty_1_down_tlast),
    .up_xfcp_in_tuser(xfcp_gty_1_down_tuser),
    .up_xfcp_out_tdata(xfcp_gty_1_up_tdata),
    .up_xfcp_out_tvalid(xfcp_gty_1_up_tvalid),
    .up_xfcp_out_tready(xfcp_gty_1_up_tready),
    .up_xfcp_out_tlast(xfcp_gty_1_up_tlast),
    .up_xfcp_out_tuser(xfcp_gty_1_up_tuser),
    .gty_drp_addr(gty_drp_addr_1),
    .gty_drp_do(gty_drp_di_1),
    .gty_drp_di(gty_drp_do_1),
    .gty_drp_en(gty_drp_en_1),
    .gty_drp_we(gty_drp_we_1),
    .gty_drp_rdy(gty_drp_rdy_1),
    .gty_reset(gty_reset_1),
    .gty_tx_reset(gty_tx_reset_1),
    .gty_rx_reset(gty_rx_reset_1),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(gty_txprbssel_1),
    .gty_txprbsforceerr(gty_txprbsforceerr_1),
    .gty_txpolarity(gty_txpolarity_1),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(gty_rxpolarity_1),
    .gty_rxprbscntreset(gty_rxprbscntreset_1),
    .gty_rxprbssel(gty_rxprbssel_1),
    .gty_rxprbserr(gty_rxprbserr_1),
    .gty_rxprbslocked(gty_rxprbslocked_1)
);

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A83),
    .XFCP_ID_STR("QSFP 2 X0Y13"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_inst_2 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_gty_2_down_tdata),
    .up_xfcp_in_tvalid(xfcp_gty_2_down_tvalid),
    .up_xfcp_in_tready(xfcp_gty_2_down_tready),
    .up_xfcp_in_tlast(xfcp_gty_2_down_tlast),
    .up_xfcp_in_tuser(xfcp_gty_2_down_tuser),
    .up_xfcp_out_tdata(xfcp_gty_2_up_tdata),
    .up_xfcp_out_tvalid(xfcp_gty_2_up_tvalid),
    .up_xfcp_out_tready(xfcp_gty_2_up_tready),
    .up_xfcp_out_tlast(xfcp_gty_2_up_tlast),
    .up_xfcp_out_tuser(xfcp_gty_2_up_tuser),
    .gty_drp_addr(gty_drp_addr_2),
    .gty_drp_do(gty_drp_di_2),
    .gty_drp_di(gty_drp_do_2),
    .gty_drp_en(gty_drp_en_2),
    .gty_drp_we(gty_drp_we_2),
    .gty_drp_rdy(gty_drp_rdy_2),
    .gty_reset(gty_reset_2),
    .gty_tx_reset(gty_tx_reset_2),
    .gty_rx_reset(gty_rx_reset_2),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(gty_txprbssel_2),
    .gty_txprbsforceerr(gty_txprbsforceerr_2),
    .gty_txpolarity(gty_txpolarity_2),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(gty_rxpolarity_2),
    .gty_rxprbscntreset(gty_rxprbscntreset_2),
    .gty_rxprbssel(gty_rxprbssel_2),
    .gty_rxprbserr(gty_rxprbserr_2),
    .gty_rxprbslocked(gty_rxprbslocked_2)
);

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A83),
    .XFCP_ID_STR("QSFP 3 X0Y14"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_inst_3 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_gty_3_down_tdata),
    .up_xfcp_in_tvalid(xfcp_gty_3_down_tvalid),
    .up_xfcp_in_tready(xfcp_gty_3_down_tready),
    .up_xfcp_in_tlast(xfcp_gty_3_down_tlast),
    .up_xfcp_in_tuser(xfcp_gty_3_down_tuser),
    .up_xfcp_out_tdata(xfcp_gty_3_up_tdata),
    .up_xfcp_out_tvalid(xfcp_gty_3_up_tvalid),
    .up_xfcp_out_tready(xfcp_gty_3_up_tready),
    .up_xfcp_out_tlast(xfcp_gty_3_up_tlast),
    .up_xfcp_out_tuser(xfcp_gty_3_up_tuser),
    .gty_drp_addr(gty_drp_addr_3),
    .gty_drp_do(gty_drp_di_3),
    .gty_drp_di(gty_drp_do_3),
    .gty_drp_en(gty_drp_en_3),
    .gty_drp_we(gty_drp_we_3),
    .gty_drp_rdy(gty_drp_rdy_3),
    .gty_reset(gty_reset_3),
    .gty_tx_reset(gty_tx_reset_3),
    .gty_rx_reset(gty_rx_reset_3),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(gty_txprbssel_3),
    .gty_txprbsforceerr(gty_txprbsforceerr_3),
    .gty_txpolarity(gty_txpolarity_3),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(gty_rxpolarity_3),
    .gty_rxprbscntreset(gty_rxprbscntreset_3),
    .gty_rxprbssel(gty_rxprbssel_3),
    .gty_rxprbserr(gty_rxprbserr_3),
    .gty_rxprbslocked(gty_rxprbslocked_3)
);

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A83),
    .XFCP_ID_STR("QSFP 4 X0Y15"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_inst_4 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_gty_4_down_tdata),
    .up_xfcp_in_tvalid(xfcp_gty_4_down_tvalid),
    .up_xfcp_in_tready(xfcp_gty_4_down_tready),
    .up_xfcp_in_tlast(xfcp_gty_4_down_tlast),
    .up_xfcp_in_tuser(xfcp_gty_4_down_tuser),
    .up_xfcp_out_tdata(xfcp_gty_4_up_tdata),
    .up_xfcp_out_tvalid(xfcp_gty_4_up_tvalid),
    .up_xfcp_out_tready(xfcp_gty_4_up_tready),
    .up_xfcp_out_tlast(xfcp_gty_4_up_tlast),
    .up_xfcp_out_tuser(xfcp_gty_4_up_tuser),
    .gty_drp_addr(gty_drp_addr_4),
    .gty_drp_do(gty_drp_di_4),
    .gty_drp_di(gty_drp_do_4),
    .gty_drp_en(gty_drp_en_4),
    .gty_drp_we(gty_drp_we_4),
    .gty_drp_rdy(gty_drp_rdy_4),
    .gty_reset(gty_reset_4),
    .gty_tx_reset(gty_tx_reset_4),
    .gty_rx_reset(gty_rx_reset_4),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(gty_txprbssel_4),
    .gty_txprbsforceerr(gty_txprbsforceerr_4),
    .gty_txpolarity(gty_txpolarity_4),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(gty_rxpolarity_4),
    .gty_rxprbscntreset(gty_rxprbscntreset_4),
    .gty_rxprbssel(gty_rxprbssel_4),
    .gty_rxprbserr(gty_rxprbserr_4),
    .gty_rxprbslocked(gty_rxprbslocked_4)
);

xfcp_mod_drp #(
    .XFCP_ID_TYPE(16'h8A82),
    .XFCP_ID_STR("GTY COM X0Y3"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_drp_inst (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_gty_5_down_tdata),
    .up_xfcp_in_tvalid(xfcp_gty_5_down_tvalid),
    .up_xfcp_in_tready(xfcp_gty_5_down_tready),
    .up_xfcp_in_tlast(xfcp_gty_5_down_tlast),
    .up_xfcp_in_tuser(xfcp_gty_5_down_tuser),
    .up_xfcp_out_tdata(xfcp_gty_5_up_tdata),
    .up_xfcp_out_tvalid(xfcp_gty_5_up_tvalid),
    .up_xfcp_out_tready(xfcp_gty_5_up_tready),
    .up_xfcp_out_tlast(xfcp_gty_5_up_tlast),
    .up_xfcp_out_tuser(xfcp_gty_5_up_tuser),
    .drp_addr(gty_drp_addr_5),
    .drp_do(gty_drp_di_5),
    .drp_di(gty_drp_do_5),
    .drp_en(gty_drp_en_5),
    .drp_we(gty_drp_we_5),
    .drp_rdy(gty_drp_rdy_5)
);

wire qsfp_mgt_refclk_0;

IBUFDS_GTE3 ibufds_gte3_qsfp_mgt_refclk_0_inst (
    .I             (qsfp_mgt_refclk_0_p),
    .IB            (qsfp_mgt_refclk_0_n),
    .CEB           (1'b0),
    .O             (qsfp_mgt_refclk_0),
    .ODIV2         ()
);

gtwizard_ultrascale_0 gtwizard_ultrascale_0_inst (
    .gtyrxn_in                           ({qsfp_rx4_n, qsfp_rx3_n, qsfp_rx2_n, qsfp_rx1_n}),
    .gtyrxp_in                           ({qsfp_rx4_p, qsfp_rx3_p, qsfp_rx2_p, qsfp_rx1_p}),
    .gtytxn_out                          ({qsfp_tx4_n, qsfp_tx3_n, qsfp_tx2_n, qsfp_tx1_n}),
    .gtytxp_out                          ({qsfp_tx4_p, qsfp_tx3_p, qsfp_tx2_p, qsfp_tx1_p}),
    .gtwiz_userclk_tx_reset_in           (gty_drp_rst),
    .gtwiz_userclk_tx_srcclk_out         (),
    .gtwiz_userclk_tx_usrclk_out         (),
    .gtwiz_userclk_tx_usrclk2_out        (gty_txusrclk2),
    .gtwiz_userclk_tx_active_out         (),
    .gtwiz_userclk_rx_reset_in           (gty_drp_rst),
    .gtwiz_userclk_rx_srcclk_out         (),
    .gtwiz_userclk_rx_usrclk_out         (),
    .gtwiz_userclk_rx_usrclk2_out        (gty_rxusrclk2),
    .gtwiz_userclk_rx_active_out         (),
    .gtwiz_reset_clk_freerun_in          (gty_drp_clk),
    .gtwiz_reset_all_in                  (gty_drp_rst | gty_reset_1 | gty_reset_2 | gty_reset_3 | gty_reset_4),
    .gtwiz_reset_tx_pll_and_datapath_in  (gty_tx_reset_1 | gty_tx_reset_2 | gty_tx_reset_3 | gty_tx_reset_4),
    .gtwiz_reset_tx_datapath_in          (1'b0),
    .gtwiz_reset_rx_pll_and_datapath_in  (gty_rx_reset_1 | gty_rx_reset_2 | gty_rx_reset_3 | gty_rx_reset_4),
    .gtwiz_reset_rx_datapath_in          (1'b0),
    .gtwiz_reset_rx_cdr_stable_out       (),
    .gtwiz_reset_tx_done_out             (),
    .gtwiz_reset_rx_done_out             (),
    .gtwiz_userdata_tx_in                ({4{128'd0}}),
    .gtwiz_userdata_rx_out               (),
    .drpaddr_common_in                   (gty_drp_addr_5),
    .drpclk_common_in                    (gty_drp_clk),
    .drpdi_common_in                     (gty_drp_di_5),
    .drpen_common_in                     (gty_drp_en_5),
    .drpwe_common_in                     (gty_drp_we_5),
    .gtrefclk00_in                       (qsfp_mgt_refclk_0),
    .drpdo_common_out                    (gty_drp_do_5),
    .drprdy_common_out                   (gty_drp_rdy_5),
    .qpll0outclk_out                     (),
    .qpll0outrefclk_out                  (),
    .drpaddr_in                          ({gty_drp_addr_4, gty_drp_addr_3, gty_drp_addr_2, gty_drp_addr_1}),
    .drpclk_in                           ({4{gty_drp_clk}}),
    .drpdi_in                            ({gty_drp_di_4, gty_drp_di_3, gty_drp_di_2, gty_drp_di_1}),
    .drpen_in                            ({gty_drp_en_4, gty_drp_en_3, gty_drp_en_2, gty_drp_en_1}),
    .drpwe_in                            ({gty_drp_we_4, gty_drp_we_3, gty_drp_we_2, gty_drp_we_1}),
    .rxpolarity_in                       ({gty_rxpolarity_4, gty_rxpolarity_3, gty_rxpolarity_2, gty_rxpolarity_1}),
    .rxprbscntreset_in                   ({gty_rxprbscntreset_4, gty_rxprbscntreset_3, gty_rxprbscntreset_2, gty_rxprbscntreset_1}),
    .rxprbssel_in                        ({gty_rxprbssel_4, gty_rxprbssel_3, gty_rxprbssel_2, gty_rxprbssel_1}),
    .txpolarity_in                       ({gty_txpolarity_4, gty_txpolarity_3, gty_txpolarity_2, gty_txpolarity_1}),
    .txprbsforceerr_in                   ({gty_txprbsforceerr_4, gty_txprbsforceerr_3, gty_txprbsforceerr_2, gty_txprbsforceerr_1}),
    .txprbssel_in                        ({gty_txprbssel_4, gty_txprbssel_3, gty_txprbssel_2, gty_txprbssel_1}),
    .drpdo_out                           ({gty_drp_do_4, gty_drp_do_3, gty_drp_do_2, gty_drp_do_1}),
    .drprdy_out                          ({gty_drp_rdy_4, gty_drp_rdy_3, gty_drp_rdy_2, gty_drp_rdy_1}),
    .rxpmaresetdone_out                  (),
    .rxprbserr_out                       ({gty_rxprbserr_4, gty_rxprbserr_3, gty_rxprbserr_2, gty_rxprbserr_1}),
    .rxprbslocked_out                    ({gty_rxprbslocked_4, gty_rxprbslocked_3, gty_rxprbslocked_2, gty_rxprbslocked_1}),
    .txpmaresetdone_out                  (),
    .txprgdivresetdone_out               ()
);

// SGMII interface to PHY
wire phy_gmii_clk_int;
wire phy_gmii_rst_int;
wire phy_gmii_clk_en_int;
wire [7:0] phy_gmii_txd_int;
wire phy_gmii_tx_en_int;
wire phy_gmii_tx_er_int;
wire [7:0] phy_gmii_rxd_int;
wire phy_gmii_rx_dv_int;
wire phy_gmii_rx_er_int;

wire [15:0] gig_eth_pcspma_status_vector;

wire gig_eth_pcspma_status_link_status              = gig_eth_pcspma_status_vector[0];
wire gig_eth_pcspma_status_link_synchronization     = gig_eth_pcspma_status_vector[1];
wire gig_eth_pcspma_status_rudi_c                   = gig_eth_pcspma_status_vector[2];
wire gig_eth_pcspma_status_rudi_i                   = gig_eth_pcspma_status_vector[3];
wire gig_eth_pcspma_status_rudi_invalid             = gig_eth_pcspma_status_vector[4];
wire gig_eth_pcspma_status_rxdisperr                = gig_eth_pcspma_status_vector[5];
wire gig_eth_pcspma_status_rxnotintable             = gig_eth_pcspma_status_vector[6];
wire gig_eth_pcspma_status_phy_link_status          = gig_eth_pcspma_status_vector[7];
wire [1:0] gig_eth_pcspma_status_remote_fault_encdg = gig_eth_pcspma_status_vector[9:8];
wire [1:0] gig_eth_pcspma_status_speed              = gig_eth_pcspma_status_vector[11:10];
wire gig_eth_pcspma_status_duplex                   = gig_eth_pcspma_status_vector[12];
wire gig_eth_pcspma_status_remote_fault             = gig_eth_pcspma_status_vector[13];
wire [1:0] gig_eth_pcspma_status_pause              = gig_eth_pcspma_status_vector[15:14];

wire [4:0] gig_eth_pcspma_config_vector;

assign gig_eth_pcspma_config_vector[4] = 1'b1; // autonegotiation enable
assign gig_eth_pcspma_config_vector[3] = 1'b0; // isolate
assign gig_eth_pcspma_config_vector[2] = 1'b0; // power down
assign gig_eth_pcspma_config_vector[1] = 1'b0; // loopback enable
assign gig_eth_pcspma_config_vector[0] = 1'b0; // unidirectional enable

wire [15:0] gig_eth_pcspma_an_config_vector;

assign gig_eth_pcspma_an_config_vector[15]    = 1'b1;    // SGMII link status
assign gig_eth_pcspma_an_config_vector[14]    = 1'b1;    // SGMII Acknowledge
assign gig_eth_pcspma_an_config_vector[13:12] = 2'b01;   // full duplex
assign gig_eth_pcspma_an_config_vector[11:10] = 2'b10;   // SGMII speed
assign gig_eth_pcspma_an_config_vector[9]     = 1'b0;    // reserved
assign gig_eth_pcspma_an_config_vector[8:7]   = 2'b00;   // pause frames - SGMII reserved
assign gig_eth_pcspma_an_config_vector[6]     = 1'b0;    // reserved
assign gig_eth_pcspma_an_config_vector[5]     = 1'b0;    // full duplex - SGMII reserved
assign gig_eth_pcspma_an_config_vector[4:1]   = 4'b0000; // reserved
assign gig_eth_pcspma_an_config_vector[0]     = 1'b1;    // SGMII

gig_ethernet_pcs_pma_0
gig_eth_pcspma (
    // SGMII
    .txp                    (phy_sgmii_tx_p),
    .txn                    (phy_sgmii_tx_n),
    .rxp                    (phy_sgmii_rx_p),
    .rxn                    (phy_sgmii_rx_n),

    // Ref clock from PHY
    .refclk625_p            (phy_sgmii_clk_p),
    .refclk625_n            (phy_sgmii_clk_n),

    // async reset
    .reset                  (rst_125mhz_int),

    // clock and reset outputs
    .clk125_out             (phy_gmii_clk_int),
    .clk625_out             (),
    .clk312_out             (),
    .rst_125_out            (phy_gmii_rst_int),
    .idelay_rdy_out         (),
    .mmcm_locked_out        (),

    // MAC clocking
    .sgmii_clk_r            (),
    .sgmii_clk_f            (),
    .sgmii_clk_en           (phy_gmii_clk_en_int),
    
    // Speed control
    .speed_is_10_100        (gig_eth_pcspma_status_speed != 2'b10),
    .speed_is_100           (gig_eth_pcspma_status_speed == 2'b01),

    // Internal GMII
    .gmii_txd               (phy_gmii_txd_int),
    .gmii_tx_en             (phy_gmii_tx_en_int),
    .gmii_tx_er             (phy_gmii_tx_er_int),
    .gmii_rxd               (phy_gmii_rxd_int),
    .gmii_rx_dv             (phy_gmii_rx_dv_int),
    .gmii_rx_er             (phy_gmii_rx_er_int),
    .gmii_isolate           (),

    // Configuration
    .configuration_vector   (gig_eth_pcspma_config_vector),

    .an_interrupt           (),
    .an_adv_config_vector   (gig_eth_pcspma_an_config_vector),
    .an_restart_config      (1'b0),

    // Status
    .status_vector          (gig_eth_pcspma_status_vector),
    .signal_detect          (1'b1)
);

fpga_core
core_inst (
    /*
     * Clock: 125MHz
     * Synchronous reset
     */
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),
    /*
     * GPIO
     */
    .btnu(btnu_int),
    .btnl(btnl_int),
    .btnd(btnd_int),
    .btnr(btnr_int),
    .btnc(btnc_int),
    .sw(sw_int),
    .led(led),
    /*
     * I2C
     */
    .i2c_scl_i(i2c_scl_i),
    .i2c_scl_o(i2c_scl_o),
    .i2c_scl_t(i2c_scl_t),
    .i2c_sda_i(i2c_sda_i),
    .i2c_sda_o(i2c_sda_o),
    .i2c_sda_t(i2c_sda_t),
    /*
     * Ethernet: 1000BASE-T SGMII
     */
    .phy_gmii_clk(phy_gmii_clk_int),
    .phy_gmii_rst(phy_gmii_rst_int),
    .phy_gmii_clk_en(phy_gmii_clk_en_int),
    .phy_gmii_rxd(phy_gmii_rxd_int),
    .phy_gmii_rx_dv(phy_gmii_rx_dv_int),
    .phy_gmii_rx_er(phy_gmii_rx_er_int),
    .phy_gmii_txd(phy_gmii_txd_int),
    .phy_gmii_tx_en(phy_gmii_tx_en_int),
    .phy_gmii_tx_er(phy_gmii_tx_er_int),
    .phy_reset_n(phy_reset_n),
    .phy_int_n(phy_int_n),
    /*
     * UART: 115200 bps, 8N1
     */
    .uart_rxd(uart_rxd_int),
    .uart_txd(uart_txd),
    .uart_rts(uart_rts),
    .uart_cts(uart_cts_int),
    /*
     * Transceiver control
     */
    .xfcp_mgt_up_tdata(xfcp_mgt_up_tdata),
    .xfcp_mgt_up_tvalid(xfcp_mgt_up_tvalid),
    .xfcp_mgt_up_tready(xfcp_mgt_up_tready),
    .xfcp_mgt_up_tlast(xfcp_mgt_up_tlast),
    .xfcp_mgt_up_tuser(xfcp_mgt_up_tuser),
    .xfcp_mgt_down_tdata(xfcp_mgt_down_tdata),
    .xfcp_mgt_down_tvalid(xfcp_mgt_down_tvalid),
    .xfcp_mgt_down_tready(xfcp_mgt_down_tready),
    .xfcp_mgt_down_tlast(xfcp_mgt_down_tlast),
    .xfcp_mgt_down_tuser(xfcp_mgt_down_tuser)
);

endmodule
