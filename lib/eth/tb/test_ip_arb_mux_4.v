/*

Copyright (c) 2014-2018 Alex Forencich

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
 * Testbench for ip_arb_mux
 */
module test_ip_arb_mux_4;

// Parameters
parameter S_COUNT = 4;
parameter DATA_WIDTH = 8;
parameter KEEP_ENABLE = (DATA_WIDTH>8);
parameter KEEP_WIDTH = (DATA_WIDTH/8);
parameter ID_ENABLE = 1;
parameter ID_WIDTH = 8;
parameter DEST_ENABLE = 1;
parameter DEST_WIDTH = 8;
parameter USER_ENABLE = 1;
parameter USER_WIDTH = 1;
parameter ARB_TYPE_ROUND_ROBIN = 0;
parameter ARB_LSB_HIGH_PRIORITY = 1;

// Inputs
reg clk = 0;
reg rst = 0;
reg [7:0] current_test = 0;

reg [S_COUNT-1:0] s_ip_hdr_valid = 0;
reg [S_COUNT*48-1:0] s_eth_dest_mac = 0;
reg [S_COUNT*48-1:0] s_eth_src_mac = 0;
reg [S_COUNT*16-1:0] s_eth_type = 0;
reg [S_COUNT*4-1:0] s_ip_version = 0;
reg [S_COUNT*4-1:0] s_ip_ihl = 0;
reg [S_COUNT*6-1:0] s_ip_dscp = 0;
reg [S_COUNT*2-1:0] s_ip_ecn = 0;
reg [S_COUNT*16-1:0] s_ip_length = 0;
reg [S_COUNT*16-1:0] s_ip_identification = 0;
reg [S_COUNT*3-1:0] s_ip_flags = 0;
reg [S_COUNT*13-1:0] s_ip_fragment_offset = 0;
reg [S_COUNT*8-1:0] s_ip_ttl = 0;
reg [S_COUNT*8-1:0] s_ip_protocol = 0;
reg [S_COUNT*16-1:0] s_ip_header_checksum = 0;
reg [S_COUNT*32-1:0] s_ip_source_ip = 0;
reg [S_COUNT*32-1:0] s_ip_dest_ip = 0;
reg [S_COUNT*DATA_WIDTH-1:0] s_ip_payload_axis_tdata = 0;
reg [S_COUNT*KEEP_WIDTH-1:0] s_ip_payload_axis_tkeep = 0;
reg [S_COUNT-1:0] s_ip_payload_axis_tvalid = 0;
reg [S_COUNT-1:0] s_ip_payload_axis_tlast = 0;
reg [S_COUNT*ID_WIDTH-1:0] s_ip_payload_axis_tid = 0;
reg [S_COUNT*DEST_WIDTH-1:0] s_ip_payload_axis_tdest = 0;
reg [S_COUNT*USER_WIDTH-1:0] s_ip_payload_axis_tuser = 0;

reg m_ip_hdr_ready = 0;
reg m_ip_payload_axis_tready = 0;

// Outputs
wire [S_COUNT-1:0] s_ip_hdr_ready;
wire [S_COUNT-1:0] s_ip_payload_axis_tready;

wire m_ip_hdr_valid;
wire [47:0] m_eth_dest_mac;
wire [47:0] m_eth_src_mac;
wire [15:0] m_eth_type;
wire [3:0] m_ip_version;
wire [3:0] m_ip_ihl;
wire [5:0] m_ip_dscp;
wire [1:0] m_ip_ecn;
wire [15:0] m_ip_length;
wire [15:0] m_ip_identification;
wire [2:0] m_ip_flags;
wire [12:0] m_ip_fragment_offset;
wire [7:0] m_ip_ttl;
wire [7:0] m_ip_protocol;
wire [15:0] m_ip_header_checksum;
wire [31:0] m_ip_source_ip;
wire [31:0] m_ip_dest_ip;
wire [DATA_WIDTH-1:0] m_ip_payload_axis_tdata;
wire [KEEP_WIDTH-1:0] m_ip_payload_axis_tkeep;
wire m_ip_payload_axis_tvalid;
wire m_ip_payload_axis_tlast;
wire [ID_WIDTH-1:0] m_ip_payload_axis_tid;
wire [DEST_WIDTH-1:0] m_ip_payload_axis_tdest;
wire [USER_WIDTH-1:0] m_ip_payload_axis_tuser;

initial begin
    // myhdl integration
    $from_myhdl(
        clk,
        rst,
        current_test,
        s_ip_hdr_valid,
        s_eth_dest_mac,
        s_eth_src_mac,
        s_eth_type,
        s_ip_version,
        s_ip_ihl,
        s_ip_dscp,
        s_ip_ecn,
        s_ip_length,
        s_ip_identification,
        s_ip_flags,
        s_ip_fragment_offset,
        s_ip_ttl,
        s_ip_protocol,
        s_ip_header_checksum,
        s_ip_source_ip,
        s_ip_dest_ip,
        s_ip_payload_axis_tdata,
        s_ip_payload_axis_tkeep,
        s_ip_payload_axis_tvalid,
        s_ip_payload_axis_tlast,
        s_ip_payload_axis_tid,
        s_ip_payload_axis_tdest,
        s_ip_payload_axis_tuser,
        m_ip_hdr_ready,
        m_ip_payload_axis_tready
    );
    $to_myhdl(
        s_ip_hdr_ready,
        s_ip_payload_axis_tready,
        m_ip_hdr_valid,
        m_eth_dest_mac,
        m_eth_src_mac,
        m_eth_type,
        m_ip_version,
        m_ip_ihl,
        m_ip_dscp,
        m_ip_ecn,
        m_ip_length,
        m_ip_identification,
        m_ip_flags,
        m_ip_fragment_offset,
        m_ip_ttl,
        m_ip_protocol,
        m_ip_header_checksum,
        m_ip_source_ip,
        m_ip_dest_ip,
        m_ip_payload_axis_tdata,
        m_ip_payload_axis_tkeep,
        m_ip_payload_axis_tvalid,
        m_ip_payload_axis_tlast,
        m_ip_payload_axis_tid,
        m_ip_payload_axis_tdest,
        m_ip_payload_axis_tuser
    );

    // dump file
    $dumpfile("test_ip_arb_mux_4.lxt");
    $dumpvars(0, test_ip_arb_mux_4);
end

ip_arb_mux #(
    .S_COUNT(S_COUNT),
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH),
    .ARB_TYPE_ROUND_ROBIN(ARB_TYPE_ROUND_ROBIN),
    .ARB_LSB_HIGH_PRIORITY(ARB_LSB_HIGH_PRIORITY)
)
UUT (
    .clk(clk),
    .rst(rst),
    // Ethernet frame inputs
    .s_ip_hdr_valid(s_ip_hdr_valid),
    .s_ip_hdr_ready(s_ip_hdr_ready),
    .s_eth_dest_mac(s_eth_dest_mac),
    .s_eth_src_mac(s_eth_src_mac),
    .s_eth_type(s_eth_type),
    .s_ip_version(s_ip_version),
    .s_ip_ihl(s_ip_ihl),
    .s_ip_dscp(s_ip_dscp),
    .s_ip_ecn(s_ip_ecn),
    .s_ip_length(s_ip_length),
    .s_ip_identification(s_ip_identification),
    .s_ip_flags(s_ip_flags),
    .s_ip_fragment_offset(s_ip_fragment_offset),
    .s_ip_ttl(s_ip_ttl),
    .s_ip_protocol(s_ip_protocol),
    .s_ip_header_checksum(s_ip_header_checksum),
    .s_ip_source_ip(s_ip_source_ip),
    .s_ip_dest_ip(s_ip_dest_ip),
    .s_ip_payload_axis_tdata(s_ip_payload_axis_tdata),
    .s_ip_payload_axis_tkeep(s_ip_payload_axis_tkeep),
    .s_ip_payload_axis_tvalid(s_ip_payload_axis_tvalid),
    .s_ip_payload_axis_tready(s_ip_payload_axis_tready),
    .s_ip_payload_axis_tlast(s_ip_payload_axis_tlast),
    .s_ip_payload_axis_tid(s_ip_payload_axis_tid),
    .s_ip_payload_axis_tdest(s_ip_payload_axis_tdest),
    .s_ip_payload_axis_tuser(s_ip_payload_axis_tuser),
    // Ethernet frame output
    .m_ip_hdr_valid(m_ip_hdr_valid),
    .m_ip_hdr_ready(m_ip_hdr_ready),
    .m_eth_dest_mac(m_eth_dest_mac),
    .m_eth_src_mac(m_eth_src_mac),
    .m_eth_type(m_eth_type),
    .m_ip_version(m_ip_version),
    .m_ip_ihl(m_ip_ihl),
    .m_ip_dscp(m_ip_dscp),
    .m_ip_ecn(m_ip_ecn),
    .m_ip_length(m_ip_length),
    .m_ip_identification(m_ip_identification),
    .m_ip_flags(m_ip_flags),
    .m_ip_fragment_offset(m_ip_fragment_offset),
    .m_ip_ttl(m_ip_ttl),
    .m_ip_protocol(m_ip_protocol),
    .m_ip_header_checksum(m_ip_header_checksum),
    .m_ip_source_ip(m_ip_source_ip),
    .m_ip_dest_ip(m_ip_dest_ip),
    .m_ip_payload_axis_tdata(m_ip_payload_axis_tdata),
    .m_ip_payload_axis_tkeep(m_ip_payload_axis_tkeep),
    .m_ip_payload_axis_tvalid(m_ip_payload_axis_tvalid),
    .m_ip_payload_axis_tready(m_ip_payload_axis_tready),
    .m_ip_payload_axis_tlast(m_ip_payload_axis_tlast),
    .m_ip_payload_axis_tid(m_ip_payload_axis_tid),
    .m_ip_payload_axis_tdest(m_ip_payload_axis_tdest),
    .m_ip_payload_axis_tuser(m_ip_payload_axis_tuser)
);

endmodule
