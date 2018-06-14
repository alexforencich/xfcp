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

import xfcp

module = 'xfcp_switch_2x1'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../lib/eth/lib/axis/rtl/arbiter.v")
srcs.append("../lib/eth/lib/axis/rtl/priority_encoder.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters


    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    up_xfcp_0_in_tdata = Signal(intbv(0)[8:])
    up_xfcp_0_in_tvalid = Signal(bool(0))
    up_xfcp_0_in_tlast = Signal(bool(0))
    up_xfcp_0_in_tuser = Signal(bool(0))
    up_xfcp_0_out_tready = Signal(bool(0))
    up_xfcp_1_in_tdata = Signal(intbv(0)[8:])
    up_xfcp_1_in_tvalid = Signal(bool(0))
    up_xfcp_1_in_tlast = Signal(bool(0))
    up_xfcp_1_in_tuser = Signal(bool(0))
    up_xfcp_1_out_tready = Signal(bool(0))
    down_xfcp_in_tdata = Signal(intbv(0)[8:])
    down_xfcp_in_tvalid = Signal(bool(0))
    down_xfcp_in_tlast = Signal(bool(0))
    down_xfcp_in_tuser = Signal(bool(0))
    down_xfcp_out_tready = Signal(bool(0))

    # Outputs
    up_xfcp_0_in_tready = Signal(bool(0))
    up_xfcp_0_out_tdata = Signal(intbv(0)[8:])
    up_xfcp_0_out_tvalid = Signal(bool(0))
    up_xfcp_0_out_tlast = Signal(bool(0))
    up_xfcp_0_out_tuser = Signal(bool(0))
    up_xfcp_1_in_tready = Signal(bool(0))
    up_xfcp_1_out_tdata = Signal(intbv(0)[8:])
    up_xfcp_1_out_tvalid = Signal(bool(0))
    up_xfcp_1_out_tlast = Signal(bool(0))
    up_xfcp_1_out_tuser = Signal(bool(0))
    down_xfcp_in_tready = Signal(bool(0))
    down_xfcp_out_tdata = Signal(intbv(0)[8:])
    down_xfcp_out_tvalid = Signal(bool(0))
    down_xfcp_out_tlast = Signal(bool(0))
    down_xfcp_out_tuser = Signal(bool(0))

    # XFCP ports
    up_xfcp_port_0_out_pause = Signal(bool(0))
    up_xfcp_port_0_in_pause = Signal(bool(0))

    up_xfcp_port_0 = xfcp.XFCPPort()

    up_xfcp_port_0_logic = up_xfcp_port_0.create_logic(
        clk=clk,
        rst=rst,
        xfcp_in_tdata=up_xfcp_0_out_tdata,
        xfcp_in_tvalid=up_xfcp_0_out_tvalid,
        xfcp_in_tready=up_xfcp_0_out_tready,
        xfcp_in_tlast=up_xfcp_0_out_tlast,
        xfcp_in_tuser=up_xfcp_0_out_tuser,
        xfcp_out_tdata=up_xfcp_0_in_tdata,
        xfcp_out_tvalid=up_xfcp_0_in_tvalid,
        xfcp_out_tready=up_xfcp_0_in_tready,
        xfcp_out_tlast=up_xfcp_0_in_tlast,
        xfcp_out_tuser=up_xfcp_0_in_tuser,
        pause_source=up_xfcp_port_0_in_pause,
        pause_sink=up_xfcp_port_0_out_pause,
        name='up_xfcp_port_0'
    )

    up_xfcp_port_1_out_pause = Signal(bool(0))
    up_xfcp_port_1_in_pause = Signal(bool(0))

    up_xfcp_port_1 = xfcp.XFCPPort()

    up_xfcp_port_1_logic = up_xfcp_port_1.create_logic(
        clk=clk,
        rst=rst,
        xfcp_in_tdata=up_xfcp_1_out_tdata,
        xfcp_in_tvalid=up_xfcp_1_out_tvalid,
        xfcp_in_tready=up_xfcp_1_out_tready,
        xfcp_in_tlast=up_xfcp_1_out_tlast,
        xfcp_in_tuser=up_xfcp_1_out_tuser,
        xfcp_out_tdata=up_xfcp_1_in_tdata,
        xfcp_out_tvalid=up_xfcp_1_in_tvalid,
        xfcp_out_tready=up_xfcp_1_in_tready,
        xfcp_out_tlast=up_xfcp_1_in_tlast,
        xfcp_out_tuser=up_xfcp_1_in_tuser,
        pause_source=up_xfcp_port_1_in_pause,
        pause_sink=up_xfcp_port_1_out_pause,
        name='up_xfcp_port_1'
    )

    down_xfcp_port_out_pause = Signal(bool(0))
    down_xfcp_port_in_pause = Signal(bool(0))

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
        pause_source=down_xfcp_port_in_pause,
        pause_sink=down_xfcp_port_out_pause,
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

        up_xfcp_0_in_tdata=up_xfcp_0_in_tdata,
        up_xfcp_0_in_tvalid=up_xfcp_0_in_tvalid,
        up_xfcp_0_in_tready=up_xfcp_0_in_tready,
        up_xfcp_0_in_tlast=up_xfcp_0_in_tlast,
        up_xfcp_0_in_tuser=up_xfcp_0_in_tuser,
        up_xfcp_0_out_tdata=up_xfcp_0_out_tdata,
        up_xfcp_0_out_tvalid=up_xfcp_0_out_tvalid,
        up_xfcp_0_out_tready=up_xfcp_0_out_tready,
        up_xfcp_0_out_tlast=up_xfcp_0_out_tlast,
        up_xfcp_0_out_tuser=up_xfcp_0_out_tuser,

        up_xfcp_1_in_tdata=up_xfcp_1_in_tdata,
        up_xfcp_1_in_tvalid=up_xfcp_1_in_tvalid,
        up_xfcp_1_in_tready=up_xfcp_1_in_tready,
        up_xfcp_1_in_tlast=up_xfcp_1_in_tlast,
        up_xfcp_1_in_tuser=up_xfcp_1_in_tuser,
        up_xfcp_1_out_tdata=up_xfcp_1_out_tdata,
        up_xfcp_1_out_tvalid=up_xfcp_1_out_tvalid,
        up_xfcp_1_out_tready=up_xfcp_1_out_tready,
        up_xfcp_1_out_tlast=up_xfcp_1_out_tlast,
        up_xfcp_1_out_tuser=up_xfcp_1_out_tuser,

        down_xfcp_in_tdata=down_xfcp_in_tdata,
        down_xfcp_in_tvalid=down_xfcp_in_tvalid,
        down_xfcp_in_tready=down_xfcp_in_tready,
        down_xfcp_in_tlast=down_xfcp_in_tlast,
        down_xfcp_in_tuser=down_xfcp_in_tuser,
        down_xfcp_out_tdata=down_xfcp_out_tdata,
        down_xfcp_out_tvalid=down_xfcp_out_tvalid,
        down_xfcp_out_tready=down_xfcp_out_tready,
        down_xfcp_out_tlast=down_xfcp_out_tlast,
        down_xfcp_out_tuser=down_xfcp_out_tuser
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    def wait_normal():
        i = 4
        while i > 0:
            i = max(0, i-1)
            if up_xfcp_0_in_tvalid or up_xfcp_1_in_tvalid or down_xfcp_in_tvalid:
                i = 4
            yield clk.posedge

    def wait_pause_source():
        i = 2
        while i > 0:
            i = max(0, i-1)
            if up_xfcp_0_in_tvalid or up_xfcp_1_in_tvalid or down_xfcp_in_tvalid:
                i = 2
            up_xfcp_port_0_in_pause.next = True
            up_xfcp_port_1_in_pause.next = True
            down_xfcp_port_in_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            up_xfcp_port_0_in_pause.next = False
            up_xfcp_port_1_in_pause.next = False
            down_xfcp_port_in_pause.next = False
            yield clk.posedge

    def wait_pause_sink():
        i = 2
        while i > 0:
            i = max(0, i-1)
            if up_xfcp_0_in_tvalid or up_xfcp_1_in_tvalid or down_xfcp_in_tvalid:
                i = 2
            up_xfcp_port_0_out_pause.next = True
            up_xfcp_port_1_out_pause.next = True
            down_xfcp_port_out_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            up_xfcp_port_0_out_pause.next = False
            up_xfcp_port_1_out_pause.next = False
            down_xfcp_port_out_pause.next = False
            yield clk.posedge

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

        yield clk.posedge
        print("test 1: downstream packets")
        current_test.next = 1

        pkt = xfcp.XFCPFrame()
        pkt.ptype = 1
        pkt.path = [1, 2, 3]
        pkt.payload = bytearray(range(8))

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port_0.send(pkt)
            yield clk.posedge
            up_xfcp_port_1.send(pkt)

            yield clk.posedge

            yield wait()
            yield clk.posedge

            rx_pkt = down_xfcp_port.recv()

            check_pkt = xfcp.XFCPFrame(pkt)
            check_pkt.rpath.insert(0, 0)

            print(rx_pkt)

            assert rx_pkt == check_pkt

            rx_pkt = down_xfcp_port.recv()

            check_pkt = xfcp.XFCPFrame(pkt)
            check_pkt.rpath.insert(0, 1)

            print(rx_pkt)

            assert rx_pkt == check_pkt

            yield delay(100)

        yield clk.posedge
        print("test 2: upstream packets")
        current_test.next = 2

        pkt0 = xfcp.XFCPFrame()
        pkt0.ptype = 1
        pkt0.path = [1, 2, 3]
        pkt0.rpath = [0]
        pkt0.payload = bytearray(range(8))

        pkt1 = xfcp.XFCPFrame(pkt0)
        pkt1.rpath = [1]

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            down_xfcp_port.send(pkt0)
            down_xfcp_port.send(pkt1)

            yield clk.posedge

            yield wait()
            yield clk.posedge

            rx_pkt = up_xfcp_port_0.recv()

            check_pkt = xfcp.XFCPFrame(pkt0)
            check_pkt.rpath = check_pkt.rpath[1:]

            print(rx_pkt)

            assert rx_pkt == check_pkt

            rx_pkt = up_xfcp_port_1.recv()

            check_pkt = xfcp.XFCPFrame(pkt1)
            check_pkt.rpath = check_pkt.rpath[1:]

            print(rx_pkt)

            assert rx_pkt == check_pkt

            yield delay(100)

        yield clk.posedge
        print("test 3: downstream packets, various path and rpath")
        current_test.next = 3

        for p in range(3):
            for rp in range(3):
                pkt = xfcp.XFCPFrame()
                pkt.ptype = 1
                pkt.path = list(range(1,p+1))
                pkt.rpath = list(range(1+p,rp+p+1))
                pkt.payload = bytearray(range(8))

                for wait in wait_normal, wait_pause_source, wait_pause_sink:
                    up_xfcp_port_0.send(pkt)
                    yield clk.posedge
                    up_xfcp_port_1.send(pkt)

                    yield clk.posedge

                    yield wait()
                    yield clk.posedge

                    rx_pkt = down_xfcp_port.recv()

                    check_pkt = xfcp.XFCPFrame(pkt)
                    check_pkt.rpath.insert(0, 0)

                    print(rx_pkt)

                    assert rx_pkt == check_pkt

                    rx_pkt = down_xfcp_port.recv()

                    check_pkt = xfcp.XFCPFrame(pkt)
                    check_pkt.rpath.insert(0, 1)

                    print(rx_pkt)

                    assert rx_pkt == check_pkt

                    yield delay(100)

        yield clk.posedge
        print("test 4: upstream packets, various path and rpath")
        current_test.next = 4

        for p in range(3):
            for rp in range(3):
                pkt0 = xfcp.XFCPFrame()
                pkt0.ptype = 1
                pkt0.path = list(range(1,p+1))
                pkt0.rpath = [0]+list(range(1+p,rp+p+1))
                pkt0.payload = bytearray(range(8))

                pkt1 = xfcp.XFCPFrame(pkt0)
                pkt1.rpath = [1]+list(range(1+p,rp+p+1))

                for wait in wait_normal, wait_pause_source, wait_pause_sink:
                    down_xfcp_port.send(pkt0)
                    down_xfcp_port.send(pkt1)

                    yield clk.posedge

                    yield wait()
                    yield clk.posedge

                    rx_pkt = up_xfcp_port_0.recv()

                    check_pkt = xfcp.XFCPFrame(pkt0)
                    check_pkt.rpath = check_pkt.rpath[1:]

                    print(rx_pkt)

                    assert rx_pkt == check_pkt

                    rx_pkt = up_xfcp_port_1.recv()

                    check_pkt = xfcp.XFCPFrame(pkt1)
                    check_pkt.rpath = check_pkt.rpath[1:]

                    print(rx_pkt)

                    assert rx_pkt == check_pkt

                    yield delay(100)

        yield clk.posedge
        print("test 5: test invalid packets")
        current_test.next = 5

        pkt1 = xfcp.XFCPFrame()
        pkt1.rpath = [10]
        pkt1.ptype = 1
        pkt1.payload = bytearray(range(8))

        pkt2 = xfcp.XFCPFrame()
        pkt2.path = [0]*40
        pkt2.rpath = [0]
        pkt2.ptype = 1
        pkt2.payload = bytearray(range(8))

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            down_xfcp_port.send(pkt1)
            down_xfcp_port.send(pkt2)
            yield clk.posedge

            yield wait()
            yield clk.posedge

            rx_pkt = up_xfcp_port_0.recv()

            assert rx_pkt is None

            rx_pkt = up_xfcp_port_1.recv()

            assert rx_pkt is None

            rx_pkt = down_xfcp_port.recv()

            assert rx_pkt is None

            yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
