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
    output wire       qsfp1_tx1_p,
    output wire       qsfp1_tx1_n,
    input  wire       qsfp1_rx1_p,
    input  wire       qsfp1_rx1_n,
    output wire       qsfp1_tx2_p,
    output wire       qsfp1_tx2_n,
    input  wire       qsfp1_rx2_p,
    input  wire       qsfp1_rx2_n,
    output wire       qsfp1_tx3_p,
    output wire       qsfp1_tx3_n,
    input  wire       qsfp1_rx3_p,
    input  wire       qsfp1_rx3_n,
    output wire       qsfp1_tx4_p,
    output wire       qsfp1_tx4_n,
    input  wire       qsfp1_rx4_p,
    input  wire       qsfp1_rx4_n,
    input  wire       qsfp1_mgt_refclk_0_p,
    input  wire       qsfp1_mgt_refclk_0_n,
    // input  wire       qsfp1_mgt_refclk_1_p,
    // input  wire       qsfp1_mgt_refclk_1_n,
    // output wire       qsfp1_recclk_p,
    // output wire       qsfp1_recclk_n,
    output wire       qsfp1_modsell,
    output wire       qsfp1_resetl,
    input  wire       qsfp1_modprsl,
    input  wire       qsfp1_intl,
    output wire       qsfp1_lpmode,

    output wire       qsfp2_tx1_p,
    output wire       qsfp2_tx1_n,
    input  wire       qsfp2_rx1_p,
    input  wire       qsfp2_rx1_n,
    output wire       qsfp2_tx2_p,
    output wire       qsfp2_tx2_n,
    input  wire       qsfp2_rx2_p,
    input  wire       qsfp2_rx2_n,
    output wire       qsfp2_tx3_p,
    output wire       qsfp2_tx3_n,
    input  wire       qsfp2_rx3_p,
    input  wire       qsfp2_rx3_n,
    output wire       qsfp2_tx4_p,
    output wire       qsfp2_tx4_n,
    input  wire       qsfp2_rx4_p,
    input  wire       qsfp2_rx4_n,
    // input  wire       qsfp2_mgt_refclk_0_p,
    // input  wire       qsfp2_mgt_refclk_0_n,
    // input  wire       qsfp2_mgt_refclk_1_p,
    // input  wire       qsfp2_mgt_refclk_1_n,
    // output wire       qsfp2_recclk_p,
    // output wire       qsfp2_recclk_n,
    output wire       qsfp2_modsell,
    output wire       qsfp2_resetl,
    input  wire       qsfp2_modprsl,
    input  wire       qsfp2_intl,
    output wire       qsfp2_lpmode,

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
    inout  wire       phy_mdio,
    output wire       phy_mdc,

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
// 125 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 8, D = 1 sets Fvco = 1000 MHz (in range)
// Divide by 8 to get output frequency of 125 MHz
// Divide by 16 to get output frequency of 62.5 MHz
MMCME4_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(8),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(16),
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
    .CLKFBOUT_MULT_F(8),
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

wire i2c_scl_i;
wire i2c_scl_o;
wire i2c_scl_t;
wire i2c_sda_i;
wire i2c_sda_o;
wire i2c_sda_t;

assign i2c_scl_i = i2c_scl;
assign i2c_scl = i2c_scl_t ? 1'bz : i2c_scl_o;
assign i2c_sda_i = i2c_sda;
assign i2c_sda = i2c_sda_t ? 1'bz : i2c_sda_o;

// GTY instance
assign qsfp1_modsell = 1'b0;
assign qsfp1_resetl = 1'b1;
assign qsfp1_lpmode = 1'b0;

assign qsfp2_modsell = 1'b0;
assign qsfp2_resetl = 1'b1;
assign qsfp2_lpmode = 1'b0;

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

wire [7:0] xfcp_qsfp1_up_tdata;
wire xfcp_qsfp1_up_tvalid;
wire xfcp_qsfp1_up_tready;
wire xfcp_qsfp1_up_tlast;
wire xfcp_qsfp1_up_tuser;
wire [7:0] xfcp_qsfp1_down_tdata;
wire xfcp_qsfp1_down_tvalid;
wire xfcp_qsfp1_down_tready;
wire xfcp_qsfp1_down_tlast;
wire xfcp_qsfp1_down_tuser;

wire [7:0] xfcp_qsfp2_up_tdata;
wire xfcp_qsfp2_up_tvalid;
wire xfcp_qsfp2_up_tready;
wire xfcp_qsfp2_up_tlast;
wire xfcp_qsfp2_up_tuser;
wire [7:0] xfcp_qsfp2_down_tdata;
wire xfcp_qsfp2_down_tvalid;
wire xfcp_qsfp2_down_tready;
wire xfcp_qsfp2_down_tlast;
wire xfcp_qsfp2_down_tuser;

axis_async_fifo #(
    .DEPTH(32),
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
    .DEPTH(32),
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
    .PORTS(2),
    .XFCP_ID_TYPE(16'h0100),
    .XFCP_ID_STR("XFCP switch"),
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
    .down_xfcp_in_tdata(  {xfcp_qsfp2_up_tdata,    xfcp_qsfp1_up_tdata   }),
    .down_xfcp_in_tvalid( {xfcp_qsfp2_up_tvalid,   xfcp_qsfp1_up_tvalid  }),
    .down_xfcp_in_tready( {xfcp_qsfp2_up_tready,   xfcp_qsfp1_up_tready  }),
    .down_xfcp_in_tlast(  {xfcp_qsfp2_up_tlast,    xfcp_qsfp1_up_tlast   }),
    .down_xfcp_in_tuser(  {xfcp_qsfp2_up_tuser,    xfcp_qsfp1_up_tuser   }),
    .down_xfcp_out_tdata( {xfcp_qsfp2_down_tdata,  xfcp_qsfp1_down_tdata }),
    .down_xfcp_out_tvalid({xfcp_qsfp2_down_tvalid, xfcp_qsfp1_down_tvalid}),
    .down_xfcp_out_tready({xfcp_qsfp2_down_tready, xfcp_qsfp1_down_tready}),
    .down_xfcp_out_tlast( {xfcp_qsfp2_down_tlast,  xfcp_qsfp1_down_tlast }),
    .down_xfcp_out_tuser( {xfcp_qsfp2_down_tuser,  xfcp_qsfp1_down_tuser })
);

wire [7:0] xfcp_qsfp1_gty_1_up_tdata;
wire xfcp_qsfp1_gty_1_up_tvalid;
wire xfcp_qsfp1_gty_1_up_tready;
wire xfcp_qsfp1_gty_1_up_tlast;
wire xfcp_qsfp1_gty_1_up_tuser;
wire [7:0] xfcp_qsfp1_gty_1_down_tdata;
wire xfcp_qsfp1_gty_1_down_tvalid;
wire xfcp_qsfp1_gty_1_down_tready;
wire xfcp_qsfp1_gty_1_down_tlast;
wire xfcp_qsfp1_gty_1_down_tuser;

wire [7:0] xfcp_qsfp1_gty_2_up_tdata;
wire xfcp_qsfp1_gty_2_up_tvalid;
wire xfcp_qsfp1_gty_2_up_tready;
wire xfcp_qsfp1_gty_2_up_tlast;
wire xfcp_qsfp1_gty_2_up_tuser;
wire [7:0] xfcp_qsfp1_gty_2_down_tdata;
wire xfcp_qsfp1_gty_2_down_tvalid;
wire xfcp_qsfp1_gty_2_down_tready;
wire xfcp_qsfp1_gty_2_down_tlast;
wire xfcp_qsfp1_gty_2_down_tuser;

wire [7:0] xfcp_qsfp1_gty_3_up_tdata;
wire xfcp_qsfp1_gty_3_up_tvalid;
wire xfcp_qsfp1_gty_3_up_tready;
wire xfcp_qsfp1_gty_3_up_tlast;
wire xfcp_qsfp1_gty_3_up_tuser;
wire [7:0] xfcp_qsfp1_gty_3_down_tdata;
wire xfcp_qsfp1_gty_3_down_tvalid;
wire xfcp_qsfp1_gty_3_down_tready;
wire xfcp_qsfp1_gty_3_down_tlast;
wire xfcp_qsfp1_gty_3_down_tuser;

wire [7:0] xfcp_qsfp1_gty_4_up_tdata;
wire xfcp_qsfp1_gty_4_up_tvalid;
wire xfcp_qsfp1_gty_4_up_tready;
wire xfcp_qsfp1_gty_4_up_tlast;
wire xfcp_qsfp1_gty_4_up_tuser;
wire [7:0] xfcp_qsfp1_gty_4_down_tdata;
wire xfcp_qsfp1_gty_4_down_tvalid;
wire xfcp_qsfp1_gty_4_down_tready;
wire xfcp_qsfp1_gty_4_down_tlast;
wire xfcp_qsfp1_gty_4_down_tuser;

wire [7:0] xfcp_qsfp1_gty_5_up_tdata;
wire xfcp_qsfp1_gty_5_up_tvalid;
wire xfcp_qsfp1_gty_5_up_tready;
wire xfcp_qsfp1_gty_5_up_tlast;
wire xfcp_qsfp1_gty_5_up_tuser;
wire [7:0] xfcp_qsfp1_gty_5_down_tdata;
wire xfcp_qsfp1_gty_5_down_tvalid;
wire xfcp_qsfp1_gty_5_down_tready;
wire xfcp_qsfp1_gty_5_down_tlast;
wire xfcp_qsfp1_gty_5_down_tuser;

xfcp_switch #(
    .PORTS(5),
    .XFCP_ID_TYPE(16'h0100),
    .XFCP_ID_STR("QSFP1 GTY QUAD"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR("")
)
xfcp_switch_qsfp1_inst (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp1_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp1_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp1_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp1_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp1_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp1_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp1_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp1_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp1_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp1_up_tuser),
    .down_xfcp_in_tdata(  {xfcp_qsfp1_gty_5_up_tdata,    xfcp_qsfp1_gty_4_up_tdata,    xfcp_qsfp1_gty_3_up_tdata,    xfcp_qsfp1_gty_2_up_tdata,    xfcp_qsfp1_gty_1_up_tdata   }),
    .down_xfcp_in_tvalid( {xfcp_qsfp1_gty_5_up_tvalid,   xfcp_qsfp1_gty_4_up_tvalid,   xfcp_qsfp1_gty_3_up_tvalid,   xfcp_qsfp1_gty_2_up_tvalid,   xfcp_qsfp1_gty_1_up_tvalid  }),
    .down_xfcp_in_tready( {xfcp_qsfp1_gty_5_up_tready,   xfcp_qsfp1_gty_4_up_tready,   xfcp_qsfp1_gty_3_up_tready,   xfcp_qsfp1_gty_2_up_tready,   xfcp_qsfp1_gty_1_up_tready  }),
    .down_xfcp_in_tlast(  {xfcp_qsfp1_gty_5_up_tlast,    xfcp_qsfp1_gty_4_up_tlast,    xfcp_qsfp1_gty_3_up_tlast,    xfcp_qsfp1_gty_2_up_tlast,    xfcp_qsfp1_gty_1_up_tlast   }),
    .down_xfcp_in_tuser(  {xfcp_qsfp1_gty_5_up_tuser,    xfcp_qsfp1_gty_4_up_tuser,    xfcp_qsfp1_gty_3_up_tuser,    xfcp_qsfp1_gty_2_up_tuser,    xfcp_qsfp1_gty_1_up_tuser   }),
    .down_xfcp_out_tdata( {xfcp_qsfp1_gty_5_down_tdata,  xfcp_qsfp1_gty_4_down_tdata,  xfcp_qsfp1_gty_3_down_tdata,  xfcp_qsfp1_gty_2_down_tdata,  xfcp_qsfp1_gty_1_down_tdata }),
    .down_xfcp_out_tvalid({xfcp_qsfp1_gty_5_down_tvalid, xfcp_qsfp1_gty_4_down_tvalid, xfcp_qsfp1_gty_3_down_tvalid, xfcp_qsfp1_gty_2_down_tvalid, xfcp_qsfp1_gty_1_down_tvalid}),
    .down_xfcp_out_tready({xfcp_qsfp1_gty_5_down_tready, xfcp_qsfp1_gty_4_down_tready, xfcp_qsfp1_gty_3_down_tready, xfcp_qsfp1_gty_2_down_tready, xfcp_qsfp1_gty_1_down_tready}),
    .down_xfcp_out_tlast( {xfcp_qsfp1_gty_5_down_tlast,  xfcp_qsfp1_gty_4_down_tlast,  xfcp_qsfp1_gty_3_down_tlast,  xfcp_qsfp1_gty_2_down_tlast,  xfcp_qsfp1_gty_1_down_tlast }),
    .down_xfcp_out_tuser( {xfcp_qsfp1_gty_5_down_tuser,  xfcp_qsfp1_gty_4_down_tuser,  xfcp_qsfp1_gty_3_down_tuser,  xfcp_qsfp1_gty_2_down_tuser,  xfcp_qsfp1_gty_1_down_tuser })
);

wire [7:0] xfcp_qsfp2_gty_1_up_tdata;
wire xfcp_qsfp2_gty_1_up_tvalid;
wire xfcp_qsfp2_gty_1_up_tready;
wire xfcp_qsfp2_gty_1_up_tlast;
wire xfcp_qsfp2_gty_1_up_tuser;
wire [7:0] xfcp_qsfp2_gty_1_down_tdata;
wire xfcp_qsfp2_gty_1_down_tvalid;
wire xfcp_qsfp2_gty_1_down_tready;
wire xfcp_qsfp2_gty_1_down_tlast;
wire xfcp_qsfp2_gty_1_down_tuser;

wire [7:0] xfcp_qsfp2_gty_2_up_tdata;
wire xfcp_qsfp2_gty_2_up_tvalid;
wire xfcp_qsfp2_gty_2_up_tready;
wire xfcp_qsfp2_gty_2_up_tlast;
wire xfcp_qsfp2_gty_2_up_tuser;
wire [7:0] xfcp_qsfp2_gty_2_down_tdata;
wire xfcp_qsfp2_gty_2_down_tvalid;
wire xfcp_qsfp2_gty_2_down_tready;
wire xfcp_qsfp2_gty_2_down_tlast;
wire xfcp_qsfp2_gty_2_down_tuser;

wire [7:0] xfcp_qsfp2_gty_3_up_tdata;
wire xfcp_qsfp2_gty_3_up_tvalid;
wire xfcp_qsfp2_gty_3_up_tready;
wire xfcp_qsfp2_gty_3_up_tlast;
wire xfcp_qsfp2_gty_3_up_tuser;
wire [7:0] xfcp_qsfp2_gty_3_down_tdata;
wire xfcp_qsfp2_gty_3_down_tvalid;
wire xfcp_qsfp2_gty_3_down_tready;
wire xfcp_qsfp2_gty_3_down_tlast;
wire xfcp_qsfp2_gty_3_down_tuser;

wire [7:0] xfcp_qsfp2_gty_4_up_tdata;
wire xfcp_qsfp2_gty_4_up_tvalid;
wire xfcp_qsfp2_gty_4_up_tready;
wire xfcp_qsfp2_gty_4_up_tlast;
wire xfcp_qsfp2_gty_4_up_tuser;
wire [7:0] xfcp_qsfp2_gty_4_down_tdata;
wire xfcp_qsfp2_gty_4_down_tvalid;
wire xfcp_qsfp2_gty_4_down_tready;
wire xfcp_qsfp2_gty_4_down_tlast;
wire xfcp_qsfp2_gty_4_down_tuser;

wire [7:0] xfcp_qsfp2_gty_5_up_tdata;
wire xfcp_qsfp2_gty_5_up_tvalid;
wire xfcp_qsfp2_gty_5_up_tready;
wire xfcp_qsfp2_gty_5_up_tlast;
wire xfcp_qsfp2_gty_5_up_tuser;
wire [7:0] xfcp_qsfp2_gty_5_down_tdata;
wire xfcp_qsfp2_gty_5_down_tvalid;
wire xfcp_qsfp2_gty_5_down_tready;
wire xfcp_qsfp2_gty_5_down_tlast;
wire xfcp_qsfp2_gty_5_down_tuser;

xfcp_switch #(
    .PORTS(5),
    .XFCP_ID_TYPE(16'h0100),
    .XFCP_ID_STR("QSFP2 GTY QUAD"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR("")
)
xfcp_switch_qsfp2_inst (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp2_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp2_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp2_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp2_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp2_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp2_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp2_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp2_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp2_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp2_up_tuser),
    .down_xfcp_in_tdata(  {xfcp_qsfp2_gty_5_up_tdata,    xfcp_qsfp2_gty_4_up_tdata,    xfcp_qsfp2_gty_3_up_tdata,    xfcp_qsfp2_gty_2_up_tdata,    xfcp_qsfp2_gty_1_up_tdata   }),
    .down_xfcp_in_tvalid( {xfcp_qsfp2_gty_5_up_tvalid,   xfcp_qsfp2_gty_4_up_tvalid,   xfcp_qsfp2_gty_3_up_tvalid,   xfcp_qsfp2_gty_2_up_tvalid,   xfcp_qsfp2_gty_1_up_tvalid  }),
    .down_xfcp_in_tready( {xfcp_qsfp2_gty_5_up_tready,   xfcp_qsfp2_gty_4_up_tready,   xfcp_qsfp2_gty_3_up_tready,   xfcp_qsfp2_gty_2_up_tready,   xfcp_qsfp2_gty_1_up_tready  }),
    .down_xfcp_in_tlast(  {xfcp_qsfp2_gty_5_up_tlast,    xfcp_qsfp2_gty_4_up_tlast,    xfcp_qsfp2_gty_3_up_tlast,    xfcp_qsfp2_gty_2_up_tlast,    xfcp_qsfp2_gty_1_up_tlast   }),
    .down_xfcp_in_tuser(  {xfcp_qsfp2_gty_5_up_tuser,    xfcp_qsfp2_gty_4_up_tuser,    xfcp_qsfp2_gty_3_up_tuser,    xfcp_qsfp2_gty_2_up_tuser,    xfcp_qsfp2_gty_1_up_tuser   }),
    .down_xfcp_out_tdata( {xfcp_qsfp2_gty_5_down_tdata,  xfcp_qsfp2_gty_4_down_tdata,  xfcp_qsfp2_gty_3_down_tdata,  xfcp_qsfp2_gty_2_down_tdata,  xfcp_qsfp2_gty_1_down_tdata }),
    .down_xfcp_out_tvalid({xfcp_qsfp2_gty_5_down_tvalid, xfcp_qsfp2_gty_4_down_tvalid, xfcp_qsfp2_gty_3_down_tvalid, xfcp_qsfp2_gty_2_down_tvalid, xfcp_qsfp2_gty_1_down_tvalid}),
    .down_xfcp_out_tready({xfcp_qsfp2_gty_5_down_tready, xfcp_qsfp2_gty_4_down_tready, xfcp_qsfp2_gty_3_down_tready, xfcp_qsfp2_gty_2_down_tready, xfcp_qsfp2_gty_1_down_tready}),
    .down_xfcp_out_tlast( {xfcp_qsfp2_gty_5_down_tlast,  xfcp_qsfp2_gty_4_down_tlast,  xfcp_qsfp2_gty_3_down_tlast,  xfcp_qsfp2_gty_2_down_tlast,  xfcp_qsfp2_gty_1_down_tlast }),
    .down_xfcp_out_tuser( {xfcp_qsfp2_gty_5_down_tuser,  xfcp_qsfp2_gty_4_down_tuser,  xfcp_qsfp2_gty_3_down_tuser,  xfcp_qsfp2_gty_2_down_tuser,  xfcp_qsfp2_gty_1_down_tuser })
);

wire gty_txusrclk2;
wire gty_rxusrclk2;

wire [9:0] qsfp1_gty_drp_addr_1;
wire [15:0] qsfp1_gty_drp_di_1;
wire [15:0] qsfp1_gty_drp_do_1;
wire qsfp1_gty_drp_rdy_1;
wire qsfp1_gty_drp_en_1;
wire qsfp1_gty_drp_we_1;

wire qsfp1_gty_reset_1;
wire qsfp1_gty_tx_reset_1;
wire qsfp1_gty_rx_reset_1;
wire [3:0] qsfp1_gty_txprbssel_1;
wire qsfp1_gty_txprbsforceerr_1;
wire qsfp1_gty_txpolarity_1;
wire qsfp1_gty_rxpolarity_1;
wire qsfp1_gty_rxprbscntreset_1;
wire [3:0] qsfp1_gty_rxprbssel_1;
wire qsfp1_gty_rxprbserr_1;
wire qsfp1_gty_rxprbslocked_1;

wire [9:0] qsfp1_gty_drp_addr_2;
wire [15:0] qsfp1_gty_drp_di_2;
wire [15:0] qsfp1_gty_drp_do_2;
wire qsfp1_gty_drp_rdy_2;
wire qsfp1_gty_drp_en_2;
wire qsfp1_gty_drp_we_2;

wire qsfp1_gty_reset_2;
wire qsfp1_gty_tx_reset_2;
wire qsfp1_gty_rx_reset_2;
wire [3:0] qsfp1_gty_txprbssel_2;
wire qsfp1_gty_txprbsforceerr_2;
wire qsfp1_gty_txpolarity_2;
wire qsfp1_gty_rxpolarity_2;
wire qsfp1_gty_rxprbscntreset_2;
wire [3:0] qsfp1_gty_rxprbssel_2;
wire qsfp1_gty_rxprbserr_2;
wire qsfp1_gty_rxprbslocked_2;

wire [9:0] qsfp1_gty_drp_addr_3;
wire [15:0] qsfp1_gty_drp_di_3;
wire [15:0] qsfp1_gty_drp_do_3;
wire qsfp1_gty_drp_rdy_3;
wire qsfp1_gty_drp_en_3;
wire qsfp1_gty_drp_we_3;

wire qsfp1_gty_reset_3;
wire qsfp1_gty_tx_reset_3;
wire qsfp1_gty_rx_reset_3;
wire [3:0] qsfp1_gty_txprbssel_3;
wire qsfp1_gty_txprbsforceerr_3;
wire qsfp1_gty_txpolarity_3;
wire qsfp1_gty_rxpolarity_3;
wire qsfp1_gty_rxprbscntreset_3;
wire [3:0] qsfp1_gty_rxprbssel_3;
wire qsfp1_gty_rxprbserr_3;
wire qsfp1_gty_rxprbslocked_3;

wire [9:0] qsfp1_gty_drp_addr_4;
wire [15:0] qsfp1_gty_drp_di_4;
wire [15:0] qsfp1_gty_drp_do_4;
wire qsfp1_gty_drp_rdy_4;
wire qsfp1_gty_drp_en_4;
wire qsfp1_gty_drp_we_4;

wire qsfp1_gty_reset_4;
wire qsfp1_gty_tx_reset_4;
wire qsfp1_gty_rx_reset_4;
wire [3:0] qsfp1_gty_txprbssel_4;
wire qsfp1_gty_txprbsforceerr_4;
wire qsfp1_gty_txpolarity_4;
wire qsfp1_gty_rxpolarity_4;
wire qsfp1_gty_rxprbscntreset_4;
wire [3:0] qsfp1_gty_rxprbssel_4;
wire qsfp1_gty_rxprbserr_4;
wire qsfp1_gty_rxprbslocked_4;

wire [9:0] qsfp1_gty_drp_addr_5;
wire [15:0] qsfp1_gty_drp_di_5;
wire [15:0] qsfp1_gty_drp_do_5;
wire qsfp1_gty_drp_rdy_5;
wire qsfp1_gty_drp_en_5;
wire qsfp1_gty_drp_we_5;

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A8B),
    .XFCP_ID_STR("QSFP1 1 X1Y48"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_qsfp1_inst_1 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp1_gty_1_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp1_gty_1_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp1_gty_1_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp1_gty_1_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp1_gty_1_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp1_gty_1_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp1_gty_1_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp1_gty_1_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp1_gty_1_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp1_gty_1_up_tuser),
    .gty_drp_addr(qsfp1_gty_drp_addr_1),
    .gty_drp_do(qsfp1_gty_drp_di_1),
    .gty_drp_di(qsfp1_gty_drp_do_1),
    .gty_drp_en(qsfp1_gty_drp_en_1),
    .gty_drp_we(qsfp1_gty_drp_we_1),
    .gty_drp_rdy(qsfp1_gty_drp_rdy_1),
    .gty_reset(qsfp1_gty_reset_1),
    .gty_tx_reset(qsfp1_gty_tx_reset_1),
    .gty_rx_reset(qsfp1_gty_rx_reset_1),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(qsfp1_gty_txprbssel_1),
    .gty_txprbsforceerr(qsfp1_gty_txprbsforceerr_1),
    .gty_txpolarity(qsfp1_gty_txpolarity_1),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(qsfp1_gty_rxpolarity_1),
    .gty_rxprbscntreset(qsfp1_gty_rxprbscntreset_1),
    .gty_rxprbssel(qsfp1_gty_rxprbssel_1),
    .gty_rxprbserr(qsfp1_gty_rxprbserr_1),
    .gty_rxprbslocked(qsfp1_gty_rxprbslocked_1)
);

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A8B),
    .XFCP_ID_STR("QSFP1 2 X1Y49"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_qsfp1_inst_2 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp1_gty_2_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp1_gty_2_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp1_gty_2_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp1_gty_2_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp1_gty_2_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp1_gty_2_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp1_gty_2_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp1_gty_2_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp1_gty_2_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp1_gty_2_up_tuser),
    .gty_drp_addr(qsfp1_gty_drp_addr_2),
    .gty_drp_do(qsfp1_gty_drp_di_2),
    .gty_drp_di(qsfp1_gty_drp_do_2),
    .gty_drp_en(qsfp1_gty_drp_en_2),
    .gty_drp_we(qsfp1_gty_drp_we_2),
    .gty_drp_rdy(qsfp1_gty_drp_rdy_2),
    .gty_reset(qsfp1_gty_reset_2),
    .gty_tx_reset(qsfp1_gty_tx_reset_2),
    .gty_rx_reset(qsfp1_gty_rx_reset_2),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(qsfp1_gty_txprbssel_2),
    .gty_txprbsforceerr(qsfp1_gty_txprbsforceerr_2),
    .gty_txpolarity(qsfp1_gty_txpolarity_2),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(qsfp1_gty_rxpolarity_2),
    .gty_rxprbscntreset(qsfp1_gty_rxprbscntreset_2),
    .gty_rxprbssel(qsfp1_gty_rxprbssel_2),
    .gty_rxprbserr(qsfp1_gty_rxprbserr_2),
    .gty_rxprbslocked(qsfp1_gty_rxprbslocked_2)
);

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A8B),
    .XFCP_ID_STR("QSFP1 3 X1Y50"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_qsfp1_inst_3 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp1_gty_3_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp1_gty_3_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp1_gty_3_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp1_gty_3_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp1_gty_3_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp1_gty_3_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp1_gty_3_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp1_gty_3_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp1_gty_3_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp1_gty_3_up_tuser),
    .gty_drp_addr(qsfp1_gty_drp_addr_3),
    .gty_drp_do(qsfp1_gty_drp_di_3),
    .gty_drp_di(qsfp1_gty_drp_do_3),
    .gty_drp_en(qsfp1_gty_drp_en_3),
    .gty_drp_we(qsfp1_gty_drp_we_3),
    .gty_drp_rdy(qsfp1_gty_drp_rdy_3),
    .gty_reset(qsfp1_gty_reset_3),
    .gty_tx_reset(qsfp1_gty_tx_reset_3),
    .gty_rx_reset(qsfp1_gty_rx_reset_3),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(qsfp1_gty_txprbssel_3),
    .gty_txprbsforceerr(qsfp1_gty_txprbsforceerr_3),
    .gty_txpolarity(qsfp1_gty_txpolarity_3),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(qsfp1_gty_rxpolarity_3),
    .gty_rxprbscntreset(qsfp1_gty_rxprbscntreset_3),
    .gty_rxprbssel(qsfp1_gty_rxprbssel_3),
    .gty_rxprbserr(qsfp1_gty_rxprbserr_3),
    .gty_rxprbslocked(qsfp1_gty_rxprbslocked_3)
);

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A8B),
    .XFCP_ID_STR("QSFP1 4 X1Y51"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_qsfp1_inst_4 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp1_gty_4_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp1_gty_4_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp1_gty_4_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp1_gty_4_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp1_gty_4_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp1_gty_4_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp1_gty_4_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp1_gty_4_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp1_gty_4_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp1_gty_4_up_tuser),
    .gty_drp_addr(qsfp1_gty_drp_addr_4),
    .gty_drp_do(qsfp1_gty_drp_di_4),
    .gty_drp_di(qsfp1_gty_drp_do_4),
    .gty_drp_en(qsfp1_gty_drp_en_4),
    .gty_drp_we(qsfp1_gty_drp_we_4),
    .gty_drp_rdy(qsfp1_gty_drp_rdy_4),
    .gty_reset(qsfp1_gty_reset_4),
    .gty_tx_reset(qsfp1_gty_tx_reset_4),
    .gty_rx_reset(qsfp1_gty_rx_reset_4),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(qsfp1_gty_txprbssel_4),
    .gty_txprbsforceerr(qsfp1_gty_txprbsforceerr_4),
    .gty_txpolarity(qsfp1_gty_txpolarity_4),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(qsfp1_gty_rxpolarity_4),
    .gty_rxprbscntreset(qsfp1_gty_rxprbscntreset_4),
    .gty_rxprbssel(qsfp1_gty_rxprbssel_4),
    .gty_rxprbserr(qsfp1_gty_rxprbserr_4),
    .gty_rxprbslocked(qsfp1_gty_rxprbslocked_4)
);

xfcp_mod_drp #(
    .XFCP_ID_TYPE(16'h8A8A),
    .XFCP_ID_STR("QSFP1 COM X1Y12"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_drp_qsfp1_inst (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp1_gty_5_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp1_gty_5_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp1_gty_5_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp1_gty_5_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp1_gty_5_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp1_gty_5_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp1_gty_5_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp1_gty_5_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp1_gty_5_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp1_gty_5_up_tuser),
    .drp_addr(qsfp1_gty_drp_addr_5),
    .drp_do(qsfp1_gty_drp_di_5),
    .drp_di(qsfp1_gty_drp_do_5),
    .drp_en(qsfp1_gty_drp_en_5),
    .drp_we(qsfp1_gty_drp_we_5),
    .drp_rdy(qsfp1_gty_drp_rdy_5)
);

wire [9:0] qsfp2_gty_drp_addr_1;
wire [15:0] qsfp2_gty_drp_di_1;
wire [15:0] qsfp2_gty_drp_do_1;
wire qsfp2_gty_drp_rdy_1;
wire qsfp2_gty_drp_en_1;
wire qsfp2_gty_drp_we_1;

wire qsfp2_gty_reset_1;
wire qsfp2_gty_tx_reset_1;
wire qsfp2_gty_rx_reset_1;
wire [3:0] qsfp2_gty_txprbssel_1;
wire qsfp2_gty_txprbsforceerr_1;
wire qsfp2_gty_txpolarity_1;
wire qsfp2_gty_rxpolarity_1;
wire qsfp2_gty_rxprbscntreset_1;
wire [3:0] qsfp2_gty_rxprbssel_1;
wire qsfp2_gty_rxprbserr_1;
wire qsfp2_gty_rxprbslocked_1;

wire [9:0] qsfp2_gty_drp_addr_2;
wire [15:0] qsfp2_gty_drp_di_2;
wire [15:0] qsfp2_gty_drp_do_2;
wire qsfp2_gty_drp_rdy_2;
wire qsfp2_gty_drp_en_2;
wire qsfp2_gty_drp_we_2;

wire qsfp2_gty_reset_2;
wire qsfp2_gty_tx_reset_2;
wire qsfp2_gty_rx_reset_2;
wire [3:0] qsfp2_gty_txprbssel_2;
wire qsfp2_gty_txprbsforceerr_2;
wire qsfp2_gty_txpolarity_2;
wire qsfp2_gty_rxpolarity_2;
wire qsfp2_gty_rxprbscntreset_2;
wire [3:0] qsfp2_gty_rxprbssel_2;
wire qsfp2_gty_rxprbserr_2;
wire qsfp2_gty_rxprbslocked_2;

wire [9:0] qsfp2_gty_drp_addr_3;
wire [15:0] qsfp2_gty_drp_di_3;
wire [15:0] qsfp2_gty_drp_do_3;
wire qsfp2_gty_drp_rdy_3;
wire qsfp2_gty_drp_en_3;
wire qsfp2_gty_drp_we_3;

wire qsfp2_gty_reset_3;
wire qsfp2_gty_tx_reset_3;
wire qsfp2_gty_rx_reset_3;
wire [3:0] qsfp2_gty_txprbssel_3;
wire qsfp2_gty_txprbsforceerr_3;
wire qsfp2_gty_txpolarity_3;
wire qsfp2_gty_rxpolarity_3;
wire qsfp2_gty_rxprbscntreset_3;
wire [3:0] qsfp2_gty_rxprbssel_3;
wire qsfp2_gty_rxprbserr_3;
wire qsfp2_gty_rxprbslocked_3;

wire [9:0] qsfp2_gty_drp_addr_4;
wire [15:0] qsfp2_gty_drp_di_4;
wire [15:0] qsfp2_gty_drp_do_4;
wire qsfp2_gty_drp_rdy_4;
wire qsfp2_gty_drp_en_4;
wire qsfp2_gty_drp_we_4;

wire qsfp2_gty_reset_4;
wire qsfp2_gty_tx_reset_4;
wire qsfp2_gty_rx_reset_4;
wire [3:0] qsfp2_gty_txprbssel_4;
wire qsfp2_gty_txprbsforceerr_4;
wire qsfp2_gty_txpolarity_4;
wire qsfp2_gty_rxpolarity_4;
wire qsfp2_gty_rxprbscntreset_4;
wire [3:0] qsfp2_gty_rxprbssel_4;
wire qsfp2_gty_rxprbserr_4;
wire qsfp2_gty_rxprbslocked_4;

wire [9:0] qsfp2_gty_drp_addr_5;
wire [15:0] qsfp2_gty_drp_di_5;
wire [15:0] qsfp2_gty_drp_do_5;
wire qsfp2_gty_drp_rdy_5;
wire qsfp2_gty_drp_en_5;
wire qsfp2_gty_drp_we_5;

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A8B),
    .XFCP_ID_STR("QSFP2 1 X1Y52"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_qsfp2_inst_1 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp2_gty_1_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp2_gty_1_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp2_gty_1_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp2_gty_1_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp2_gty_1_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp2_gty_1_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp2_gty_1_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp2_gty_1_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp2_gty_1_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp2_gty_1_up_tuser),
    .gty_drp_addr(qsfp2_gty_drp_addr_1),
    .gty_drp_do(qsfp2_gty_drp_di_1),
    .gty_drp_di(qsfp2_gty_drp_do_1),
    .gty_drp_en(qsfp2_gty_drp_en_1),
    .gty_drp_we(qsfp2_gty_drp_we_1),
    .gty_drp_rdy(qsfp2_gty_drp_rdy_1),
    .gty_reset(qsfp2_gty_reset_1),
    .gty_tx_reset(qsfp2_gty_tx_reset_1),
    .gty_rx_reset(qsfp2_gty_rx_reset_1),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(qsfp2_gty_txprbssel_1),
    .gty_txprbsforceerr(qsfp2_gty_txprbsforceerr_1),
    .gty_txpolarity(qsfp2_gty_txpolarity_1),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(qsfp2_gty_rxpolarity_1),
    .gty_rxprbscntreset(qsfp2_gty_rxprbscntreset_1),
    .gty_rxprbssel(qsfp2_gty_rxprbssel_1),
    .gty_rxprbserr(qsfp2_gty_rxprbserr_1),
    .gty_rxprbslocked(qsfp2_gty_rxprbslocked_1)
);

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A8B),
    .XFCP_ID_STR("QSFP2 2 X1Y53"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_qsfp2_inst_2 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp2_gty_2_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp2_gty_2_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp2_gty_2_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp2_gty_2_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp2_gty_2_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp2_gty_2_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp2_gty_2_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp2_gty_2_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp2_gty_2_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp2_gty_2_up_tuser),
    .gty_drp_addr(qsfp2_gty_drp_addr_2),
    .gty_drp_do(qsfp2_gty_drp_di_2),
    .gty_drp_di(qsfp2_gty_drp_do_2),
    .gty_drp_en(qsfp2_gty_drp_en_2),
    .gty_drp_we(qsfp2_gty_drp_we_2),
    .gty_drp_rdy(qsfp2_gty_drp_rdy_2),
    .gty_reset(qsfp2_gty_reset_2),
    .gty_tx_reset(qsfp2_gty_tx_reset_2),
    .gty_rx_reset(qsfp2_gty_rx_reset_2),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(qsfp2_gty_txprbssel_2),
    .gty_txprbsforceerr(qsfp2_gty_txprbsforceerr_2),
    .gty_txpolarity(qsfp2_gty_txpolarity_2),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(qsfp2_gty_rxpolarity_2),
    .gty_rxprbscntreset(qsfp2_gty_rxprbscntreset_2),
    .gty_rxprbssel(qsfp2_gty_rxprbssel_2),
    .gty_rxprbserr(qsfp2_gty_rxprbserr_2),
    .gty_rxprbslocked(qsfp2_gty_rxprbslocked_2)
);

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A8B),
    .XFCP_ID_STR("QSFP2 3 X1Y54"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_qsfp2_inst_3 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp2_gty_3_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp2_gty_3_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp2_gty_3_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp2_gty_3_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp2_gty_3_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp2_gty_3_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp2_gty_3_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp2_gty_3_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp2_gty_3_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp2_gty_3_up_tuser),
    .gty_drp_addr(qsfp2_gty_drp_addr_3),
    .gty_drp_do(qsfp2_gty_drp_di_3),
    .gty_drp_di(qsfp2_gty_drp_do_3),
    .gty_drp_en(qsfp2_gty_drp_en_3),
    .gty_drp_we(qsfp2_gty_drp_we_3),
    .gty_drp_rdy(qsfp2_gty_drp_rdy_3),
    .gty_reset(qsfp2_gty_reset_3),
    .gty_tx_reset(qsfp2_gty_tx_reset_3),
    .gty_rx_reset(qsfp2_gty_rx_reset_3),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(qsfp2_gty_txprbssel_3),
    .gty_txprbsforceerr(qsfp2_gty_txprbsforceerr_3),
    .gty_txpolarity(qsfp2_gty_txpolarity_3),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(qsfp2_gty_rxpolarity_3),
    .gty_rxprbscntreset(qsfp2_gty_rxprbscntreset_3),
    .gty_rxprbssel(qsfp2_gty_rxprbssel_3),
    .gty_rxprbserr(qsfp2_gty_rxprbserr_3),
    .gty_rxprbslocked(qsfp2_gty_rxprbslocked_3)
);

xfcp_mod_gty #(
    .XFCP_ID_TYPE(16'h8A8B),
    .XFCP_ID_STR("QSFP2 4 X1Y55"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_gty_qsfp2_inst_4 (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp2_gty_4_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp2_gty_4_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp2_gty_4_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp2_gty_4_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp2_gty_4_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp2_gty_4_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp2_gty_4_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp2_gty_4_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp2_gty_4_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp2_gty_4_up_tuser),
    .gty_drp_addr(qsfp2_gty_drp_addr_4),
    .gty_drp_do(qsfp2_gty_drp_di_4),
    .gty_drp_di(qsfp2_gty_drp_do_4),
    .gty_drp_en(qsfp2_gty_drp_en_4),
    .gty_drp_we(qsfp2_gty_drp_we_4),
    .gty_drp_rdy(qsfp2_gty_drp_rdy_4),
    .gty_reset(qsfp2_gty_reset_4),
    .gty_tx_reset(qsfp2_gty_tx_reset_4),
    .gty_rx_reset(qsfp2_gty_rx_reset_4),
    .gty_txusrclk2(gty_txusrclk2),
    .gty_txprbssel(qsfp2_gty_txprbssel_4),
    .gty_txprbsforceerr(qsfp2_gty_txprbsforceerr_4),
    .gty_txpolarity(qsfp2_gty_txpolarity_4),
    .gty_rxusrclk2(gty_rxusrclk2),
    .gty_rxpolarity(qsfp2_gty_rxpolarity_4),
    .gty_rxprbscntreset(qsfp2_gty_rxprbscntreset_4),
    .gty_rxprbssel(qsfp2_gty_rxprbssel_4),
    .gty_rxprbserr(qsfp2_gty_rxprbserr_4),
    .gty_rxprbslocked(qsfp2_gty_rxprbslocked_4)
);

xfcp_mod_drp #(
    .XFCP_ID_TYPE(16'h8A8A),
    .XFCP_ID_STR("QSFP2 COM X1Y13"),
    .XFCP_EXT_ID(0),
    .XFCP_EXT_ID_STR(""),
    .ADDR_WIDTH(10)
)
xfcp_mod_drp_qsfp2_inst (
    .clk(gty_drp_clk),
    .rst(gty_drp_rst),
    .up_xfcp_in_tdata(xfcp_qsfp2_gty_5_down_tdata),
    .up_xfcp_in_tvalid(xfcp_qsfp2_gty_5_down_tvalid),
    .up_xfcp_in_tready(xfcp_qsfp2_gty_5_down_tready),
    .up_xfcp_in_tlast(xfcp_qsfp2_gty_5_down_tlast),
    .up_xfcp_in_tuser(xfcp_qsfp2_gty_5_down_tuser),
    .up_xfcp_out_tdata(xfcp_qsfp2_gty_5_up_tdata),
    .up_xfcp_out_tvalid(xfcp_qsfp2_gty_5_up_tvalid),
    .up_xfcp_out_tready(xfcp_qsfp2_gty_5_up_tready),
    .up_xfcp_out_tlast(xfcp_qsfp2_gty_5_up_tlast),
    .up_xfcp_out_tuser(xfcp_qsfp2_gty_5_up_tuser),
    .drp_addr(qsfp2_gty_drp_addr_5),
    .drp_do(qsfp2_gty_drp_di_5),
    .drp_di(qsfp2_gty_drp_do_5),
    .drp_en(qsfp2_gty_drp_en_5),
    .drp_we(qsfp2_gty_drp_we_5),
    .drp_rdy(qsfp2_gty_drp_rdy_5)
);

wire qsfp1_mgt_refclk_0;

IBUFDS_GTE4 ibufds_gte4_qsfp1_mgt_refclk_0_inst (
    .I             (qsfp1_mgt_refclk_0_p),
    .IB            (qsfp1_mgt_refclk_0_n),
    .CEB           (1'b0),
    .O             (qsfp1_mgt_refclk_0),
    .ODIV2         ()
);

gtwizard_ultrascale_0 gtwizard_ultrascale_0_inst (
    .gtyrxn_in                           ({qsfp2_rx4_n, qsfp2_rx3_n, qsfp2_rx2_n, qsfp2_rx1_n, qsfp1_rx4_n, qsfp1_rx3_n, qsfp1_rx2_n, qsfp1_rx1_n}),
    .gtyrxp_in                           ({qsfp2_rx4_p, qsfp2_rx3_p, qsfp2_rx2_p, qsfp2_rx1_p, qsfp1_rx4_p, qsfp1_rx3_p, qsfp1_rx2_p, qsfp1_rx1_p}),
    .gtytxn_out                          ({qsfp2_tx4_n, qsfp2_tx3_n, qsfp2_tx2_n, qsfp2_tx1_n, qsfp1_tx4_n, qsfp1_tx3_n, qsfp1_tx2_n, qsfp1_tx1_n}),
    .gtytxp_out                          ({qsfp2_tx4_p, qsfp2_tx3_p, qsfp2_tx2_p, qsfp2_tx1_p, qsfp1_tx4_p, qsfp1_tx3_p, qsfp1_tx2_p, qsfp1_tx1_p}),
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
    .gtwiz_reset_all_in                  (gty_drp_rst | qsfp2_gty_reset_1 | qsfp2_gty_reset_2 | qsfp2_gty_reset_3 | qsfp2_gty_reset_4 | qsfp1_gty_reset_1 | qsfp1_gty_reset_2 | qsfp1_gty_reset_3 | qsfp1_gty_reset_4),
    .gtwiz_reset_tx_pll_and_datapath_in  (qsfp2_gty_tx_reset_1 | qsfp2_gty_tx_reset_2 | qsfp2_gty_tx_reset_3 | qsfp2_gty_tx_reset_4 | qsfp1_gty_tx_reset_1 | qsfp1_gty_tx_reset_2 | qsfp1_gty_tx_reset_3 | qsfp1_gty_tx_reset_4),
    .gtwiz_reset_tx_datapath_in          (1'b0),
    .gtwiz_reset_rx_pll_and_datapath_in  (qsfp2_gty_rx_reset_1 | qsfp2_gty_rx_reset_2 | qsfp2_gty_rx_reset_3 | qsfp2_gty_rx_reset_4 | qsfp1_gty_rx_reset_1 | qsfp1_gty_rx_reset_2 | qsfp1_gty_rx_reset_3 | qsfp1_gty_rx_reset_4),
    .gtwiz_reset_rx_datapath_in          (1'b0),
    .gtwiz_reset_rx_cdr_stable_out       (),
    .gtwiz_reset_tx_done_out             (),
    .gtwiz_reset_rx_done_out             (),
    .gtwiz_userdata_tx_in                ({8{64'd0}}),
    .gtwiz_userdata_rx_out               (),
    .drpaddr_common_in                   ({qsfp2_gty_drp_addr_5, qsfp1_gty_drp_addr_5}),
    .drpclk_common_in                    ({2{gty_drp_clk}}),
    .drpdi_common_in                     ({qsfp2_gty_drp_di_5, qsfp1_gty_drp_di_5}),
    .drpen_common_in                     ({qsfp2_gty_drp_en_5, qsfp1_gty_drp_en_5}),
    .drpwe_common_in                     ({qsfp2_gty_drp_we_5, qsfp1_gty_drp_we_5}),
    .gtrefclk00_in                       ({2{qsfp1_mgt_refclk_0}}),
    .drpdo_common_out                    ({qsfp2_gty_drp_do_5, qsfp1_gty_drp_do_5}),
    .drprdy_common_out                   ({qsfp2_gty_drp_rdy_5, qsfp1_gty_drp_rdy_5}),
    .qpll0outclk_out                     (),
    .qpll0outrefclk_out                  (),
    .drpaddr_in                          ({qsfp2_gty_drp_addr_4, qsfp2_gty_drp_addr_3, qsfp2_gty_drp_addr_2, qsfp2_gty_drp_addr_1, qsfp1_gty_drp_addr_4, qsfp1_gty_drp_addr_3, qsfp1_gty_drp_addr_2, qsfp1_gty_drp_addr_1}),
    .drpclk_in                           ({8{gty_drp_clk}}),
    .drpdi_in                            ({qsfp2_gty_drp_di_4, qsfp2_gty_drp_di_3, qsfp2_gty_drp_di_2, qsfp2_gty_drp_di_1, qsfp1_gty_drp_di_4, qsfp1_gty_drp_di_3, qsfp1_gty_drp_di_2, qsfp1_gty_drp_di_1}),
    .drpen_in                            ({qsfp2_gty_drp_en_4, qsfp2_gty_drp_en_3, qsfp2_gty_drp_en_2, qsfp2_gty_drp_en_1, qsfp1_gty_drp_en_4, qsfp1_gty_drp_en_3, qsfp1_gty_drp_en_2, qsfp1_gty_drp_en_1}),
    .drpwe_in                            ({qsfp2_gty_drp_we_4, qsfp2_gty_drp_we_3, qsfp2_gty_drp_we_2, qsfp2_gty_drp_we_1, qsfp1_gty_drp_we_4, qsfp1_gty_drp_we_3, qsfp1_gty_drp_we_2, qsfp1_gty_drp_we_1}),
    .rxpolarity_in                       ({qsfp2_gty_rxpolarity_4, qsfp2_gty_rxpolarity_3, qsfp2_gty_rxpolarity_2, qsfp2_gty_rxpolarity_1, qsfp1_gty_rxpolarity_4, qsfp1_gty_rxpolarity_3, qsfp1_gty_rxpolarity_2, qsfp1_gty_rxpolarity_1}),
    .rxprbscntreset_in                   ({qsfp2_gty_rxprbscntreset_4, qsfp2_gty_rxprbscntreset_3, qsfp2_gty_rxprbscntreset_2, qsfp2_gty_rxprbscntreset_1, qsfp1_gty_rxprbscntreset_4, qsfp1_gty_rxprbscntreset_3, qsfp1_gty_rxprbscntreset_2, qsfp1_gty_rxprbscntreset_1}),
    .rxprbssel_in                        ({qsfp2_gty_rxprbssel_4, qsfp2_gty_rxprbssel_3, qsfp2_gty_rxprbssel_2, qsfp2_gty_rxprbssel_1, qsfp1_gty_rxprbssel_4, qsfp1_gty_rxprbssel_3, qsfp1_gty_rxprbssel_2, qsfp1_gty_rxprbssel_1}),
    .txpolarity_in                       ({qsfp2_gty_txpolarity_4, qsfp2_gty_txpolarity_3, qsfp2_gty_txpolarity_2, qsfp2_gty_txpolarity_1, qsfp1_gty_txpolarity_4, qsfp1_gty_txpolarity_3, qsfp1_gty_txpolarity_2, qsfp1_gty_txpolarity_1}),
    .txprbsforceerr_in                   ({qsfp2_gty_txprbsforceerr_4, qsfp2_gty_txprbsforceerr_3, qsfp2_gty_txprbsforceerr_2, qsfp2_gty_txprbsforceerr_1, qsfp1_gty_txprbsforceerr_4, qsfp1_gty_txprbsforceerr_3, qsfp1_gty_txprbsforceerr_2, qsfp1_gty_txprbsforceerr_1}),
    .txprbssel_in                        ({qsfp2_gty_txprbssel_4, qsfp2_gty_txprbssel_3, qsfp2_gty_txprbssel_2, qsfp2_gty_txprbssel_1, qsfp1_gty_txprbssel_4, qsfp1_gty_txprbssel_3, qsfp1_gty_txprbssel_2, qsfp1_gty_txprbssel_1}),
    .drpdo_out                           ({qsfp2_gty_drp_do_4, qsfp2_gty_drp_do_3, qsfp2_gty_drp_do_2, qsfp2_gty_drp_do_1, qsfp1_gty_drp_do_4, qsfp1_gty_drp_do_3, qsfp1_gty_drp_do_2, qsfp1_gty_drp_do_1}),
    .drprdy_out                          ({qsfp2_gty_drp_rdy_4, qsfp2_gty_drp_rdy_3, qsfp2_gty_drp_rdy_2, qsfp2_gty_drp_rdy_1, qsfp1_gty_drp_rdy_4, qsfp1_gty_drp_rdy_3, qsfp1_gty_drp_rdy_2, qsfp1_gty_drp_rdy_1}),
    .rxpmaresetdone_out                  (),
    .rxprbserr_out                       ({qsfp2_gty_rxprbserr_4, qsfp2_gty_rxprbserr_3, qsfp2_gty_rxprbserr_2, qsfp2_gty_rxprbserr_1, qsfp1_gty_rxprbserr_4, qsfp1_gty_rxprbserr_3, qsfp1_gty_rxprbserr_2, qsfp1_gty_rxprbserr_1}),
    .rxprbslocked_out                    ({qsfp2_gty_rxprbslocked_4, qsfp2_gty_rxprbslocked_3, qsfp2_gty_rxprbslocked_2, qsfp2_gty_rxprbslocked_1, qsfp1_gty_rxprbslocked_4, qsfp1_gty_rxprbslocked_3, qsfp1_gty_rxprbslocked_2, qsfp1_gty_rxprbslocked_1}),
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
eth_pcspma (
    // SGMII
    .txp_0                  (phy_sgmii_tx_p),
    .txn_0                  (phy_sgmii_tx_n),
    .rxp_0                  (phy_sgmii_rx_p),
    .rxn_0                  (phy_sgmii_rx_n),

    // Ref clock from PHY
    .refclk625_p            (phy_sgmii_clk_p),
    .refclk625_n            (phy_sgmii_clk_n),

    // async reset
    .reset                  (rst_125mhz_int),

    // clock and reset outputs
    .clk125_out             (phy_gmii_clk_int),
    .clk312_out             (),
    .rst_125_out            (phy_gmii_rst_int),
    .tx_logic_reset         (),
    .rx_logic_reset         (),
    .tx_locked              (),
    .rx_locked              (),
    .tx_pll_clk_out         (),
    .rx_pll_clk_out         (),

    // MAC clocking
    .sgmii_clk_r_0          (),
    .sgmii_clk_f_0          (),
    .sgmii_clk_en_0         (phy_gmii_clk_en_int),
    
    // Speed control
    .speed_is_10_100_0      (gig_eth_pcspma_status_speed != 2'b10),
    .speed_is_100_0         (gig_eth_pcspma_status_speed == 2'b01),

    // Internal GMII
    .gmii_txd_0             (phy_gmii_txd_int),
    .gmii_tx_en_0           (phy_gmii_tx_en_int),
    .gmii_tx_er_0           (phy_gmii_tx_er_int),
    .gmii_rxd_0             (phy_gmii_rxd_int),
    .gmii_rx_dv_0           (phy_gmii_rx_dv_int),
    .gmii_rx_er_0           (phy_gmii_rx_er_int),
    .gmii_isolate_0         (),

    // Configuration
    .configuration_vector_0 (gig_eth_pcspma_config_vector),

    .an_interrupt_0         (),
    .an_adv_config_vector_0 (gig_eth_pcspma_an_config_vector),
    .an_restart_config_0    (1'b0),

    // Status
    .status_vector_0        (gig_eth_pcspma_status_vector),
    .signal_detect_0        (1'b1),

    // Cascade
    .tx_bsc_rst_out         (),
    .rx_bsc_rst_out         (),
    .tx_bs_rst_out          (),
    .rx_bs_rst_out          (),
    .tx_rst_dly_out         (),
    .rx_rst_dly_out         (),
    .tx_bsc_en_vtc_out      (),
    .rx_bsc_en_vtc_out      (),
    .tx_bs_en_vtc_out       (),
    .rx_bs_en_vtc_out       (),
    .riu_clk_out            (),
    .riu_addr_out           (),
    .riu_wr_data_out        (),
    .riu_wr_en_out          (),
    .riu_nibble_sel_out     (),
    .riu_rddata_1           (16'b0),
    .riu_valid_1            (1'b0),
    .riu_prsnt_1            (1'b0),
    .riu_rddata_2           (16'b0),
    .riu_valid_2            (1'b0),
    .riu_prsnt_2            (1'b0),
    .riu_rddata_3           (16'b0),
    .riu_valid_3            (1'b0),
    .riu_prsnt_3            (1'b0),
    .rx_btval_1             (),
    .rx_btval_2             (),
    .rx_btval_3             (),
    .tx_dly_rdy_1           (1'b1),
    .rx_dly_rdy_1           (1'b1),
    .rx_vtc_rdy_1           (1'b1),
    .tx_vtc_rdy_1           (1'b1),
    .tx_dly_rdy_2           (1'b1),
    .rx_dly_rdy_2           (1'b1),
    .rx_vtc_rdy_2           (1'b1),
    .tx_vtc_rdy_2           (1'b1),
    .tx_dly_rdy_3           (1'b1),
    .rx_dly_rdy_3           (1'b1),
    .rx_vtc_rdy_3           (1'b1),
    .tx_vtc_rdy_3           (1'b1),
    .tx_rdclk_out           ()
);

reg [19:0] delay_reg = 20'hfffff;

reg [4:0] mdio_cmd_phy_addr = 5'h03;
reg [4:0] mdio_cmd_reg_addr = 5'h00;
reg [15:0] mdio_cmd_data = 16'd0;
reg [1:0] mdio_cmd_opcode = 2'b01;
reg mdio_cmd_valid = 1'b0;
wire mdio_cmd_ready;

reg [3:0] state_reg = 0;

always @(posedge clk_125mhz_int) begin
    if (rst_125mhz_int) begin
        state_reg <= 0;
        delay_reg <= 20'hfffff;
        mdio_cmd_reg_addr <= 5'h00;
        mdio_cmd_data <= 16'd0;
        mdio_cmd_valid <= 1'b0;
    end else begin
        mdio_cmd_valid <= mdio_cmd_valid & !mdio_cmd_ready;
        if (delay_reg > 0) begin
            delay_reg <= delay_reg - 1;
        end else if (!mdio_cmd_ready) begin
            // wait for ready
            state_reg <= state_reg;
        end else begin
            mdio_cmd_valid <= 1'b0;
            case (state_reg)
                // set SGMII autonegotiation timer to 11 ms
                // write 0x0070 to CFG4 (0x0031)
                4'd0: begin
                    // write to REGCR to load address
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h001F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd1;
                end
                4'd1: begin
                    // write address of CFG4 to ADDAR
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h0031;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd2;
                end
                4'd2: begin
                    // write to REGCR to load data
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h401F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd3;
                end
                4'd3: begin
                    // write data for CFG4 to ADDAR
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h0070;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd4;
                end
                // enable SGMII clock output
                // write 0x4000 to SGMIICTL1 (0x00D3)
                4'd4: begin
                    // write to REGCR to load address
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h001F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd5;
                end
                4'd5: begin
                    // write address of SGMIICTL1 to ADDAR
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h00D3;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd6;
                end
                4'd6: begin
                    // write to REGCR to load data
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h401F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd7;
                end
                4'd7: begin
                    // write data for SGMIICTL1 to ADDAR
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h4000;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd8;
                end
                // enable 10Mbps operation
                // write 0x0015 to 10M_SGMII_CFG (0x016F)
                4'd8: begin
                    // write to REGCR to load address
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h001F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd9;
                end
                4'd9: begin
                    // write address of 10M_SGMII_CFG to ADDAR
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h016F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd10;
                end
                4'd10: begin
                    // write to REGCR to load data
                    mdio_cmd_reg_addr <= 5'h0D;
                    mdio_cmd_data <= 16'h401F;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd11;
                end
                4'd11: begin
                    // write data for 10M_SGMII_CFG to ADDAR
                    mdio_cmd_reg_addr <= 5'h0E;
                    mdio_cmd_data <= 16'h0015;
                    mdio_cmd_valid <= 1'b1;
                    state_reg <= 4'd12;
                end
                4'd12: begin
                    // done
                    state_reg <= 4'd12;
                end
            endcase
        end
    end
end

wire mdc;
wire mdio_i;
wire mdio_o;
wire mdio_t;

mdio_master
mdio_master_inst (
    .clk(clk_125mhz_int),
    .rst(rst_125mhz_int),

    .cmd_phy_addr(mdio_cmd_phy_addr),
    .cmd_reg_addr(mdio_cmd_reg_addr),
    .cmd_data(mdio_cmd_data),
    .cmd_opcode(mdio_cmd_opcode),
    .cmd_valid(mdio_cmd_valid),
    .cmd_ready(mdio_cmd_ready),

    .data_out(),
    .data_out_valid(),
    .data_out_ready(1'b1),

    .mdc_o(mdc),
    .mdio_i(mdio_i),
    .mdio_o(mdio_o),
    .mdio_t(mdio_t),

    .busy(),

    .prescale(8'd3)
);

assign phy_mdc = mdc;
assign mdio_i = phy_mdio;
assign phy_mdio = mdio_t ? 1'bz : mdio_o;

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
