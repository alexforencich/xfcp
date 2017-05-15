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
 * Testbench for xfcp_switch_2x1
 */
module test_xfcp_switch_2x1;

// Parameters

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [7:0] up_xfcp_0_in_tdata = 0;
reg up_xfcp_0_in_tvalid = 0;
reg up_xfcp_0_in_tlast = 0;
reg up_xfcp_0_in_tuser = 0;
reg up_xfcp_0_out_tready = 0;
reg [7:0] up_xfcp_1_in_tdata = 0;
reg up_xfcp_1_in_tvalid = 0;
reg up_xfcp_1_in_tlast = 0;
reg up_xfcp_1_in_tuser = 0;
reg up_xfcp_1_out_tready = 0;
reg [7:0] down_xfcp_in_tdata = 0;
reg down_xfcp_in_tvalid = 0;
reg down_xfcp_in_tlast = 0;
reg down_xfcp_in_tuser = 0;
reg down_xfcp_out_tready = 0;

// Outputs
wire up_xfcp_0_in_tready;
wire [7:0] up_xfcp_0_out_tdata;
wire up_xfcp_0_out_tvalid;
wire up_xfcp_0_out_tlast;
wire up_xfcp_0_out_tuser;
wire up_xfcp_1_in_tready;
wire [7:0] up_xfcp_1_out_tdata;
wire up_xfcp_1_out_tvalid;
wire up_xfcp_1_out_tlast;
wire up_xfcp_1_out_tuser;
wire down_xfcp_in_tready;
wire [7:0] down_xfcp_out_tdata;
wire down_xfcp_out_tvalid;
wire down_xfcp_out_tlast;
wire down_xfcp_out_tuser;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        up_xfcp_0_in_tdata,
        up_xfcp_0_in_tvalid,
        up_xfcp_0_in_tlast,
        up_xfcp_0_in_tuser,
        up_xfcp_0_out_tready,
        up_xfcp_1_in_tdata,
        up_xfcp_1_in_tvalid,
        up_xfcp_1_in_tlast,
        up_xfcp_1_in_tuser,
        up_xfcp_1_out_tready,
        down_xfcp_in_tdata,
        down_xfcp_in_tvalid,
        down_xfcp_in_tlast,
        down_xfcp_in_tuser,
        down_xfcp_out_tready
    );
    $to_myhdl(
        up_xfcp_0_in_tready,
        up_xfcp_0_out_tdata,
        up_xfcp_0_out_tvalid,
        up_xfcp_0_out_tlast,
        up_xfcp_0_out_tuser,
        up_xfcp_1_in_tready,
        up_xfcp_1_out_tdata,
        up_xfcp_1_out_tvalid,
        up_xfcp_1_out_tlast,
        up_xfcp_1_out_tuser,
        down_xfcp_in_tready,
        down_xfcp_out_tdata,
        down_xfcp_out_tvalid,
        down_xfcp_out_tlast,
        down_xfcp_out_tuser
    );

    // dump file
    $dumpfile("test_xfcp_switch_2x1.lxt");
    $dumpvars(0, test_xfcp_switch_2x1);
end

xfcp_switch_2x1
UUT (
    .clk(clk),
    .rst(rst),
    .up_xfcp_0_in_tdata(up_xfcp_0_in_tdata),
    .up_xfcp_0_in_tvalid(up_xfcp_0_in_tvalid),
    .up_xfcp_0_in_tready(up_xfcp_0_in_tready),
    .up_xfcp_0_in_tlast(up_xfcp_0_in_tlast),
    .up_xfcp_0_in_tuser(up_xfcp_0_in_tuser),
    .up_xfcp_0_out_tdata(up_xfcp_0_out_tdata),
    .up_xfcp_0_out_tvalid(up_xfcp_0_out_tvalid),
    .up_xfcp_0_out_tready(up_xfcp_0_out_tready),
    .up_xfcp_0_out_tlast(up_xfcp_0_out_tlast),
    .up_xfcp_0_out_tuser(up_xfcp_0_out_tuser),
    .up_xfcp_1_in_tdata(up_xfcp_1_in_tdata),
    .up_xfcp_1_in_tvalid(up_xfcp_1_in_tvalid),
    .up_xfcp_1_in_tready(up_xfcp_1_in_tready),
    .up_xfcp_1_in_tlast(up_xfcp_1_in_tlast),
    .up_xfcp_1_in_tuser(up_xfcp_1_in_tuser),
    .up_xfcp_1_out_tdata(up_xfcp_1_out_tdata),
    .up_xfcp_1_out_tvalid(up_xfcp_1_out_tvalid),
    .up_xfcp_1_out_tready(up_xfcp_1_out_tready),
    .up_xfcp_1_out_tlast(up_xfcp_1_out_tlast),
    .up_xfcp_1_out_tuser(up_xfcp_1_out_tuser),
    .down_xfcp_in_tdata(down_xfcp_in_tdata),
    .down_xfcp_in_tvalid(down_xfcp_in_tvalid),
    .down_xfcp_in_tready(down_xfcp_in_tready),
    .down_xfcp_in_tlast(down_xfcp_in_tlast),
    .down_xfcp_in_tuser(down_xfcp_in_tuser),
    .down_xfcp_out_tdata(down_xfcp_out_tdata),
    .down_xfcp_out_tvalid(down_xfcp_out_tvalid),
    .down_xfcp_out_tready(down_xfcp_out_tready),
    .down_xfcp_out_tlast(down_xfcp_out_tlast),
    .down_xfcp_out_tuser(down_xfcp_out_tuser)
);

endmodule
