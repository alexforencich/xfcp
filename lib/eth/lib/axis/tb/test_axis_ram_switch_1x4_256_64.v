/*

Copyright (c) 2020 Alex Forencich

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
 * Testbench for axis_ram_switch
 */
module test_axis_ram_switch_1x4_256_64;

// Parameters
parameter FIFO_DEPTH = 512;
parameter SPEEDUP = 0;
parameter S_COUNT = 1;
parameter M_COUNT = 4;
parameter S_DATA_WIDTH = 256;
parameter S_KEEP_ENABLE = (S_DATA_WIDTH>8);
parameter S_KEEP_WIDTH = (S_DATA_WIDTH/8);
parameter M_DATA_WIDTH = 64;
parameter M_KEEP_ENABLE = (M_DATA_WIDTH>8);
parameter M_KEEP_WIDTH = (M_DATA_WIDTH/8);
parameter ID_ENABLE = 1;
parameter ID_WIDTH = 8;
parameter DEST_WIDTH = $clog2(M_COUNT+1);
parameter USER_ENABLE = 1;
parameter USER_WIDTH = 1;
parameter USER_BAD_FRAME_VALUE = 1'b1;
parameter USER_BAD_FRAME_MASK = 1'b1;
parameter DROP_BAD_FRAME = 1;
parameter DROP_WHEN_FULL = 0;
parameter M_BASE = {3'd3, 3'd2, 3'd1, 3'd0};
parameter M_TOP = {3'd3, 3'd2, 3'd1, 3'd0};
parameter M_CONNECT = {M_COUNT{{S_COUNT{1'b1}}}};
parameter ARB_TYPE = "ROUND_ROBIN";
parameter LSB_PRIORITY = "HIGH";
parameter RAM_PIPELINE = 2;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [S_COUNT*S_DATA_WIDTH-1:0] s_axis_tdata = 0;
reg [S_COUNT*S_KEEP_WIDTH-1:0] s_axis_tkeep = 0;
reg [S_COUNT-1:0] s_axis_tvalid = 0;
reg [S_COUNT-1:0] s_axis_tlast = 0;
reg [S_COUNT*ID_WIDTH-1:0] s_axis_tid = 0;
reg [S_COUNT*DEST_WIDTH-1:0] s_axis_tdest = 0;
reg [S_COUNT*USER_WIDTH-1:0] s_axis_tuser = 0;
reg [M_COUNT-1:0] m_axis_tready = 0;

// Outputs
wire [S_COUNT-1:0] s_axis_tready;
wire [M_COUNT*M_DATA_WIDTH-1:0] m_axis_tdata;
wire [M_COUNT*M_KEEP_WIDTH-1:0] m_axis_tkeep;
wire [M_COUNT-1:0] m_axis_tvalid;
wire [M_COUNT-1:0] m_axis_tlast;
wire [M_COUNT*ID_WIDTH-1:0] m_axis_tid;
wire [M_COUNT*DEST_WIDTH-1:0] m_axis_tdest;
wire [M_COUNT*USER_WIDTH-1:0] m_axis_tuser;
wire [S_COUNT-1:0] status_overflow;
wire [S_COUNT-1:0] status_bad_frame;
wire [S_COUNT-1:0] status_good_frame;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        s_axis_tdata,
        s_axis_tkeep,
        s_axis_tvalid,
        s_axis_tlast,
        s_axis_tid,
        s_axis_tdest,
        s_axis_tuser,
        m_axis_tready
    );
    $to_myhdl(
        s_axis_tready,
        m_axis_tdata,
        m_axis_tkeep,
        m_axis_tvalid,
        m_axis_tlast,
        m_axis_tid,
        m_axis_tdest,
        m_axis_tuser,
        status_overflow,
        status_bad_frame,
        status_good_frame
    );

    // dump file
    $dumpfile("test_axis_ram_switch_1x4_256_64.lxt");
    $dumpvars(0, test_axis_ram_switch_1x4_256_64);
end

axis_ram_switch #(
    .FIFO_DEPTH(FIFO_DEPTH),
    .SPEEDUP(SPEEDUP),
    .S_COUNT(S_COUNT),
    .M_COUNT(M_COUNT),
    .S_DATA_WIDTH(S_DATA_WIDTH),
    .S_KEEP_ENABLE(S_KEEP_ENABLE),
    .S_KEEP_WIDTH(S_KEEP_WIDTH),
    .M_DATA_WIDTH(M_DATA_WIDTH),
    .M_KEEP_ENABLE(M_KEEP_ENABLE),
    .M_KEEP_WIDTH(M_KEEP_WIDTH),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH),
    .USER_BAD_FRAME_VALUE(USER_BAD_FRAME_VALUE),
    .USER_BAD_FRAME_MASK(USER_BAD_FRAME_MASK),
    .DROP_BAD_FRAME(DROP_BAD_FRAME),
    .DROP_WHEN_FULL(DROP_WHEN_FULL),
    .M_BASE(M_BASE),
    .M_TOP(M_TOP),
    .M_CONNECT(M_CONNECT),
    .ARB_TYPE(ARB_TYPE),
    .LSB_PRIORITY(LSB_PRIORITY),
    .RAM_PIPELINE(RAM_PIPELINE)
)
UUT (
    .clk(clk),
    .rst(rst),
    // AXI inputs
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tid(s_axis_tid),
    .s_axis_tdest(s_axis_tdest),
    .s_axis_tuser(s_axis_tuser),
    // AXI output
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tid(m_axis_tid),
    .m_axis_tdest(m_axis_tdest),
    .m_axis_tuser(m_axis_tuser),
    // Status
    .status_overflow(status_overflow),
    .status_bad_frame(status_bad_frame),
    .status_good_frame(status_good_frame)
);

endmodule
