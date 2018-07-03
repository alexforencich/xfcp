#!/usr/bin/env python
"""

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

"""

from myhdl import *
import os

import axis_ep
import eth_ep
import arp_ep
import udp_ep
import xfcp

module = 'xfcp_interface_udp'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../lib/eth/rtl/eth_axis_rx.v")
srcs.append("../lib/eth/rtl/eth_axis_tx.v")
srcs.append("../lib/eth/rtl/udp_complete.v")
srcs.append("../lib/eth/rtl/udp_checksum_gen.v")
srcs.append("../lib/eth/rtl/udp.v")
srcs.append("../lib/eth/rtl/udp_ip_rx.v")
srcs.append("../lib/eth/rtl/udp_ip_tx.v")
srcs.append("../lib/eth/rtl/ip_complete.v")
srcs.append("../lib/eth/rtl/ip.v")
srcs.append("../lib/eth/rtl/ip_eth_rx.v")
srcs.append("../lib/eth/rtl/ip_eth_tx.v")
srcs.append("../lib/eth/rtl/ip_arb_mux_2.v")
srcs.append("../lib/eth/rtl/ip_mux_2.v")
srcs.append("../lib/eth/rtl/arp.v")
srcs.append("../lib/eth/rtl/arp_cache.v")
srcs.append("../lib/eth/rtl/arp_eth_rx.v")
srcs.append("../lib/eth/rtl/arp_eth_tx.v")
srcs.append("../lib/eth/rtl/eth_arb_mux_2.v")
srcs.append("../lib/eth/rtl/eth_mux_2.v")
srcs.append("../lib/eth/rtl/lfsr.v")
srcs.append("../lib/eth/lib/axis/rtl/arbiter.v")
srcs.append("../lib/eth/lib/axis/rtl/priority_encoder.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_fifo.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters


    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    input_eth_axis_tdata = Signal(intbv(0)[8:])
    input_eth_axis_tvalid = Signal(bool(0))
    input_eth_axis_tlast = Signal(bool(0))
    input_eth_axis_tuser = Signal(bool(0))
    output_eth_axis_tready = Signal(bool(0))
    down_xfcp_in_tdata = Signal(intbv(0)[8:])
    down_xfcp_in_tvalid = Signal(bool(0))
    down_xfcp_in_tlast = Signal(bool(0))
    down_xfcp_in_tuser = Signal(bool(0))
    down_xfcp_out_tready = Signal(bool(0))
    local_mac = Signal(intbv(0)[48:])
    local_ip = Signal(intbv(0)[32:])
    local_port = Signal(intbv(0)[16:])
    gateway_ip = Signal(intbv(0)[32:])
    subnet_mask = Signal(intbv(0)[32:])

    # Outputs
    input_eth_axis_tready = Signal(bool(0))
    output_eth_axis_tdata = Signal(intbv(0)[8:])
    output_eth_axis_tvalid = Signal(bool(0))
    output_eth_axis_tlast = Signal(bool(0))
    output_eth_axis_tuser = Signal(bool(0))
    down_xfcp_in_tready = Signal(bool(0))
    down_xfcp_out_tdata = Signal(intbv(0)[8:])
    down_xfcp_out_tvalid = Signal(bool(0))
    down_xfcp_out_tlast = Signal(bool(0))
    down_xfcp_out_tuser = Signal(bool(0))

    # sources and sinks
    eth_source_pause = Signal(bool(0))
    eth_sink_pause = Signal(bool(0))

    eth_source = axis_ep.AXIStreamSource()

    eth_source_logic = eth_source.create_logic(
        clk,
        rst,
        tdata=input_eth_axis_tdata,
        tvalid=input_eth_axis_tvalid,
        tready=input_eth_axis_tready,
        tlast=input_eth_axis_tlast,
        tuser=input_eth_axis_tuser,
        pause=eth_source_pause,
        name='eth_source'
    )

    eth_sink = axis_ep.AXIStreamSink()

    eth_sink_logic = eth_sink.create_logic(
        clk,
        rst,
        tdata=output_eth_axis_tdata,
        tvalid=output_eth_axis_tvalid,
        tready=output_eth_axis_tready,
        tlast=output_eth_axis_tlast,
        tuser=output_eth_axis_tuser,
        pause=eth_sink_pause,
        name='eth_sink'
    )

    # XFCP ports

    down_xfcp_port = xfcp.XFCPPort()

    down_xfcp_port_logic = down_xfcp_port.create_logic(
        clk=clk,
        rst=rst,
        xfcp_in_tdata=down_xfcp_out_tdata,
        xfcp_in_tvalid=down_xfcp_out_tvalid,
        xfcp_in_tready=down_xfcp_out_tready,
        xfcp_in_tlast=down_xfcp_out_tlast,
        xfcp_in_tuser=down_xfcp_out_tuser,
        xfcp_out_tdata=down_xfcp_in_tdata,
        xfcp_out_tvalid=down_xfcp_in_tvalid,
        xfcp_out_tready=down_xfcp_in_tready,
        xfcp_out_tlast=down_xfcp_in_tlast,
        xfcp_out_tuser=down_xfcp_in_tuser,
        name='down_xfcp_port'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,
        input_eth_axis_tdata=input_eth_axis_tdata,
        input_eth_axis_tvalid=input_eth_axis_tvalid,
        input_eth_axis_tready=input_eth_axis_tready,
        input_eth_axis_tlast=input_eth_axis_tlast,
        input_eth_axis_tuser=input_eth_axis_tuser,
        output_eth_axis_tdata=output_eth_axis_tdata,
        output_eth_axis_tvalid=output_eth_axis_tvalid,
        output_eth_axis_tready=output_eth_axis_tready,
        output_eth_axis_tlast=output_eth_axis_tlast,
        output_eth_axis_tuser=output_eth_axis_tuser,
        down_xfcp_in_tdata=down_xfcp_in_tdata,
        down_xfcp_in_tvalid=down_xfcp_in_tvalid,
        down_xfcp_in_tready=down_xfcp_in_tready,
        down_xfcp_in_tlast=down_xfcp_in_tlast,
        down_xfcp_in_tuser=down_xfcp_in_tuser,
        down_xfcp_out_tdata=down_xfcp_out_tdata,
        down_xfcp_out_tvalid=down_xfcp_out_tvalid,
        down_xfcp_out_tready=down_xfcp_out_tready,
        down_xfcp_out_tlast=down_xfcp_out_tlast,
        down_xfcp_out_tuser=down_xfcp_out_tuser,
        local_mac=local_mac,
        local_ip=local_ip,
        local_port=local_port,
        gateway_ip=gateway_ip,
        subnet_mask=subnet_mask
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        yield clk.posedge
        rst.next = 0
        yield clk.posedge
        yield delay(100)
        yield clk.posedge

        # testbench stimulus

        local_mac.next = 0x020000000000
        local_ip.next = 0xc0a80180
        local_port.next = 14000
        gateway_ip.next = 0xc0a80101
        subnet_mask.next = 0xffffff00

        yield clk.posedge
        print("test 1: test UDP RX packet")
        current_test.next = 1

        pkt = xfcp.XFCPFrame()
        pkt.path = [1,2,3]
        pkt.rpath = [4]
        pkt.ptype = 1
        pkt.payload = bytearray(range(32))

        test_frame = udp_ep.UDPFrame()
        test_frame.eth_dest_mac = 0x020000000000
        test_frame.eth_src_mac = 0xDAD1D2D3D4D5
        test_frame.eth_type = 0x0800
        test_frame.ip_version = 4
        test_frame.ip_ihl = 5
        test_frame.ip_dscp = 0
        test_frame.ip_ecn = 0
        test_frame.ip_length = None
        test_frame.ip_identification = 0
        test_frame.ip_flags = 2
        test_frame.ip_fragment_offset = 0
        test_frame.ip_ttl = 64
        test_frame.ip_protocol = 0x11
        test_frame.ip_header_checksum = None
        test_frame.ip_source_ip = 0xc0a80181
        test_frame.ip_dest_ip = 0xc0a80180
        test_frame.udp_source_port = 1234
        test_frame.udp_dest_port = 14000
        test_frame.payload = pkt.build_axis()
        test_frame.build()

        eth_source.send(test_frame.build_eth().build_axis())

        yield down_xfcp_port.wait()
        rx_pkt = down_xfcp_port.recv()

        print(rx_pkt)

        assert rx_pkt == pkt

        assert eth_source.empty()
        assert eth_sink.empty()

        yield delay(100)

        yield clk.posedge
        print("test 2: test UDP TX packet")
        current_test.next = 2

        pkt = xfcp.XFCPFrame()
        pkt.path = [1,2,3]
        pkt.rpath = [4]
        pkt.ptype = 1
        pkt.payload = bytearray(range(32))

        down_xfcp_port.send(pkt)

        # wait for ARP request packet
        yield eth_sink.wait()
        rx_frame = eth_sink.recv()

        check_eth_frame = eth_ep.EthFrame()
        check_eth_frame.parse_axis(rx_frame.data)
        check_frame = arp_ep.ARPFrame()
        check_frame.parse_eth(check_eth_frame)

        print(check_frame)

        assert check_frame.eth_dest_mac == 0xFFFFFFFFFFFF
        assert check_frame.eth_src_mac == 0x020000000000
        assert check_frame.eth_type == 0x0806
        assert check_frame.arp_htype == 0x0001
        assert check_frame.arp_ptype == 0x0800
        assert check_frame.arp_hlen == 6
        assert check_frame.arp_plen == 4
        assert check_frame.arp_oper == 1
        assert check_frame.arp_sha == 0x020000000000
        assert check_frame.arp_spa == 0xc0a80180
        assert check_frame.arp_tha == 0x000000000000
        assert check_frame.arp_tpa == 0xc0a80181

        # generate response
        arp_frame = arp_ep.ARPFrame()
        arp_frame.eth_dest_mac = 0x020000000000
        arp_frame.eth_src_mac = 0xDAD1D2D3D4D5
        arp_frame.eth_type = 0x0806
        arp_frame.arp_htype = 0x0001
        arp_frame.arp_ptype = 0x0800
        arp_frame.arp_hlen = 6
        arp_frame.arp_plen = 4
        arp_frame.arp_oper = 2
        arp_frame.arp_sha = 0xDAD1D2D3D4D5
        arp_frame.arp_spa = 0xc0a80181
        arp_frame.arp_tha = 0x020000000000
        arp_frame.arp_tpa = 0xc0a80180

        eth_source.send(arp_frame.build_eth().build_axis())

        yield eth_sink.wait()
        rx_frame = eth_sink.recv()

        check_eth_frame = eth_ep.EthFrame()
        check_eth_frame.parse_axis(rx_frame.data)
        check_frame = udp_ep.UDPFrame()
        check_frame.parse_eth(check_eth_frame)

        print(check_frame)

        assert check_frame.eth_dest_mac == 0xDAD1D2D3D4D5
        assert check_frame.eth_src_mac == 0x020000000000
        assert check_frame.eth_type == 0x0800
        assert check_frame.ip_version == 4
        assert check_frame.ip_ihl == 5
        assert check_frame.ip_dscp == 0
        assert check_frame.ip_ecn == 0
        assert check_frame.ip_identification == 0
        assert check_frame.ip_flags == 2
        assert check_frame.ip_fragment_offset == 0
        assert check_frame.ip_ttl == 64
        assert check_frame.ip_protocol == 0x11
        assert check_frame.ip_source_ip == 0xc0a80180
        assert check_frame.ip_dest_ip == 0xc0a80181
        assert check_frame.udp_source_port == 14000
        assert check_frame.udp_dest_port == 1234

        rx_pkt = xfcp.XFCPFrame()
        rx_pkt.parse_axis(check_frame.payload.data)

        print(rx_pkt)

        assert rx_pkt == pkt

        assert eth_source.empty()
        assert eth_sink.empty()

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
