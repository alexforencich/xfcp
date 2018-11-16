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
import i2c

module = 'xfcp_mod_i2c_master'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../lib/i2c/rtl/i2c_master.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    XFCP_ID_TYPE = 0x2C00
    XFCP_ID_STR = "I2C Master"
    XFCP_EXT_ID = 0
    XFCP_EXT_ID_STR = ""
    DEFAULT_PRESCALE = 1

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    up_xfcp_in_tdata = Signal(intbv(0)[8:])
    up_xfcp_in_tvalid = Signal(bool(0))
    up_xfcp_in_tlast = Signal(bool(0))
    up_xfcp_in_tuser = Signal(bool(0))
    up_xfcp_out_tready = Signal(bool(0))
    i2c_scl_i = Signal(bool(1))
    i2c_sda_i = Signal(bool(1))

    s1_scl_i = Signal(bool(1))
    s1_sda_i = Signal(bool(1))

    s2_scl_i = Signal(bool(1))
    s2_sda_i = Signal(bool(1))

    # Outputs
    up_xfcp_in_tready = Signal(bool(0))
    up_xfcp_out_tdata = Signal(intbv(0)[8:])
    up_xfcp_out_tvalid = Signal(bool(0))
    up_xfcp_out_tlast = Signal(bool(0))
    up_xfcp_out_tuser = Signal(bool(0))
    i2c_scl_o = Signal(bool(1))
    i2c_scl_t = Signal(bool(1))
    i2c_sda_o = Signal(bool(1))
    i2c_sda_t = Signal(bool(1))

    s1_scl_o = Signal(bool(1))
    s1_scl_t = Signal(bool(1))
    s1_sda_o = Signal(bool(1))
    s1_sda_t = Signal(bool(1))

    s2_scl_o = Signal(bool(1))
    s2_scl_t = Signal(bool(1))
    s2_sda_o = Signal(bool(1))
    s2_sda_t = Signal(bool(1))

    # XFCP ports
    up_xfcp_port_out_pause = Signal(bool(0))
    up_xfcp_port_in_pause = Signal(bool(0))

    up_xfcp_port = xfcp.XFCPPort()

    up_xfcp_port_logic = up_xfcp_port.create_logic(
        clk=clk,
        rst=rst,
        xfcp_in_tdata=up_xfcp_out_tdata,
        xfcp_in_tvalid=up_xfcp_out_tvalid,
        xfcp_in_tready=up_xfcp_out_tready,
        xfcp_in_tlast=up_xfcp_out_tlast,
        xfcp_in_tuser=up_xfcp_out_tuser,
        xfcp_out_tdata=up_xfcp_in_tdata,
        xfcp_out_tvalid=up_xfcp_in_tvalid,
        xfcp_out_tready=up_xfcp_in_tready,
        xfcp_out_tlast=up_xfcp_in_tlast,
        xfcp_out_tuser=up_xfcp_in_tuser,
        pause_source=up_xfcp_port_in_pause,
        pause_sink=up_xfcp_port_out_pause,
        name='up_xfcp_port'
    )

    # I2C memory model 1
    i2c_mem1 = i2c.I2CMem(1024)

    i2c_mem_logic1 = i2c_mem1.create_logic(
        scl_i=s1_scl_i,
        scl_o=s1_scl_o,
        scl_t=s1_scl_t,
        sda_i=s1_sda_i,
        sda_o=s1_sda_o,
        sda_t=s1_sda_t,
        abw=2,
        address=0x50,
        latency=0,
        name='slave1'
    )

    # I2C memory model 2
    i2c_mem2 = i2c.I2CMem(1024)

    i2c_mem_logic2 = i2c_mem2.create_logic(
        scl_i=s2_scl_i,
        scl_o=s2_scl_o,
        scl_t=s2_scl_t,
        sda_i=s2_sda_i,
        sda_o=s2_sda_o,
        sda_t=s2_sda_t,
        abw=2,
        address=0x51,
        latency=1000,
        name='slave2')

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        up_xfcp_in_tdata=up_xfcp_in_tdata,
        up_xfcp_in_tvalid=up_xfcp_in_tvalid,
        up_xfcp_in_tready=up_xfcp_in_tready,
        up_xfcp_in_tlast=up_xfcp_in_tlast,
        up_xfcp_in_tuser=up_xfcp_in_tuser,
        up_xfcp_out_tdata=up_xfcp_out_tdata,
        up_xfcp_out_tvalid=up_xfcp_out_tvalid,
        up_xfcp_out_tready=up_xfcp_out_tready,
        up_xfcp_out_tlast=up_xfcp_out_tlast,
        up_xfcp_out_tuser=up_xfcp_out_tuser,

        i2c_scl_i=i2c_scl_i,
        i2c_scl_o=i2c_scl_o,
        i2c_scl_t=i2c_scl_t,
        i2c_sda_i=i2c_sda_i,
        i2c_sda_o=i2c_sda_o,
        i2c_sda_t=i2c_sda_t
    )

    @always_comb
    def bus():
        # emulate I2C wired AND
        i2c_scl_i.next = i2c_scl_o & s1_scl_o & s2_scl_o;
        i2c_sda_i.next = i2c_sda_o & s1_sda_o & s2_sda_o;

        s1_scl_i.next = i2c_scl_o & s1_scl_o & s2_scl_o;
        s1_sda_i.next = i2c_sda_o & s1_sda_o & s2_sda_o;

        s2_scl_i.next = i2c_scl_o & s1_scl_o & s2_scl_o;
        s2_sda_i.next = i2c_sda_o & s1_sda_o & s2_sda_o;

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    def wait_normal():
        i = 8
        while i > 0:
            i = max(0, i-1)
            if not up_xfcp_port.idle() or not i2c_scl_i or not i2c_sda_i:
                i = 8
            yield clk.posedge

    def wait_pause_source():
        i = 4
        while i > 0:
            i = max(0, i-1)
            if not up_xfcp_port.idle() or not i2c_scl_i or not i2c_sda_i:
                i = 4
            up_xfcp_port_in_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            up_xfcp_port_in_pause.next = False
            yield clk.posedge

    def wait_pause_sink():
        i = 4
        while i > 0:
            i = max(0, i-1)
            if not up_xfcp_port.idle() or not i2c_scl_i or not i2c_sda_i:
                i = 4
            up_xfcp_port_out_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            up_xfcp_port_out_pause.next = False
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
        print("test 1: write")
        current_test.next = 1

        pkt = xfcp.XFCPFrame()
        pkt.ptype = 0x2C
        pkt.payload = b'\xD0\x1C\x06\x00\x04\x11\x22\x33\x44'

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt)

            yield clk.posedge

            yield wait()
            yield clk.posedge

            data = i2c_mem1.read_mem(0, 32)
            for i in range(0, len(data), 16):
                print(" ".join(("{:02x}".format(c) for c in bytearray(data[i:i+16]))))

            assert i2c_mem1.read_mem(4,4) == b'\x11\x22\x33\x44'

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x2D
            assert rx_pkt.payload.data == b'\xD0\x1C\x06\x00\x04\x11\x22\x33\x44'

            yield delay(100)

        yield clk.posedge
        print("test 2: read")
        current_test.next = 2

        pkt = xfcp.XFCPFrame()
        pkt.ptype = 0x2C
        pkt.payload = b'\xD0\x14\x02\x00\x04\x1A\x04'

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt)

            yield clk.posedge

            yield wait()
            yield clk.posedge

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x2D
            assert rx_pkt.payload.data == b'\xD0\x14\x02\x00\x04\x1A\x04\x11\x22\x33\x44'

            yield delay(100)

        yield clk.posedge
        print("test 3: write to slave 2")
        current_test.next = 3

        pkt = xfcp.XFCPFrame()
        pkt.ptype = 0x2C
        pkt.payload = b'\xD1\x04\x00\x04\x04\x04\x44\x04\x33\x04\x22\x0C\x11'

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt)

            yield clk.posedge

            yield wait()
            yield clk.posedge

            data = i2c_mem2.read_mem(0, 32)
            for i in range(0, len(data), 16):
                print(" ".join(("{:02x}".format(c) for c in bytearray(data[i:i+16]))))

            assert i2c_mem2.read_mem(4,4) == b'\x44\x33\x22\x11'

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x2D
            assert rx_pkt.payload.data == b'\xD1\x04\x00\x04\x04\x04\x44\x04\x33\x04\x22\x0C\x11'

            yield delay(100)

        yield clk.posedge
        print("test 4: read from slave 2")
        current_test.next = 4

        pkt = xfcp.XFCPFrame()
        pkt.ptype = 0x2C
        pkt.payload = b'\xD1\x04\x00\x04\x04\x02\x02\x02\x0A'

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt)

            yield clk.posedge

            yield wait()
            yield clk.posedge

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x2D
            assert rx_pkt.payload.data == b'\xD1\x04\x00\x04\x04\x02\x44\x02\x33\x02\x22\x0A\x11'

            yield delay(100)

        yield clk.posedge
        print("test 5: test configuration and status")
        current_test.next = 5

        pkt = xfcp.XFCPFrame()
        pkt.ptype = 0x2C
        pkt.payload = b'\x60\x04\x00\x60\x01\x00\x40'

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt)
            yield clk.posedge

            yield wait()
            yield clk.posedge

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x2D
            assert rx_pkt.payload.data == b'\x60\x04\x00\x60\x01\x00\x40\x00'

            yield delay(100)

        yield clk.posedge
        print("test 6: test id")
        current_test.next = 6

        pkt = xfcp.XFCPFrame()
        pkt.ptype = 0xFE
        pkt.payload = b''

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt)
            yield clk.posedge

            yield wait()
            yield clk.posedge

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0xff
            assert len(rx_pkt.payload.data) == 32

            yield delay(100)

        yield clk.posedge
        print("test 7: test id with trailing bytes")
        current_test.next = 7

        pkt1 = xfcp.XFCPFrame()
        pkt1.ptype = 0xFE
        pkt1.payload = b'\0'*256

        pkt2 = xfcp.XFCPFrame()
        pkt2.ptype = 0xFE
        pkt2.payload = b'\0'*8

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt1)
            up_xfcp_port.send(pkt2)
            yield clk.posedge

            yield wait()
            yield clk.posedge

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0xff
            assert len(rx_pkt.payload.data) == 32

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0xff
            assert len(rx_pkt.payload.data) == 32

            yield delay(100)

        yield clk.posedge
        print("test 8: test with rpath")
        current_test.next = 8

        pkt1 = xfcp.XFCPFrame()
        pkt1.rpath = [1, 2, 3]
        pkt1.ptype = 0xFE
        pkt1.payload = b'\0'*8

        pkt2 = xfcp.XFCPFrame()
        pkt2.rpath = [4, 5, 6]
        pkt2.ptype = 0x2C
        pkt2.payload = b'\xD0\x04\x00\x04\x04\x02\x02\x02\x0A'

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt1)
            up_xfcp_port.send(pkt2)

            yield clk.posedge

            yield wait()
            yield clk.posedge

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.rpath == [1, 2, 3]
            assert rx_pkt.ptype == 0xff
            assert len(rx_pkt.payload.data) == 32

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.rpath == [4, 5, 6]
            assert rx_pkt.ptype == 0x2D
            assert rx_pkt.payload.data == b'\xD0\x04\x00\x04\x04\x02\x11\x02\x22\x02\x33\x0A\x44'

            yield delay(100)

        yield clk.posedge
        print("test 9: test invalid packets")
        current_test.next = 9

        pkt1 = xfcp.XFCPFrame()
        pkt1.ptype = 0x99
        pkt1.payload = b'\x00'*8

        pkt2 = xfcp.XFCPFrame()
        pkt2.path = [0]
        pkt2.ptype = 0xFE
        pkt2.payload = b''

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt1)
            up_xfcp_port.send(pkt2)
            yield clk.posedge

            yield wait()
            yield clk.posedge

            rx_pkt = up_xfcp_port.recv()

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
