#!/usr/bin/env python
"""

Copyright (c) 2019 Alex Forencich

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
import struct

import xfcp
import axil

module = 'xfcp_mod_axil'
testbench = 'test_%s_32' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    XFCP_ID_TYPE = 0x0001
    XFCP_ID_STR = "AXIL Master"
    XFCP_EXT_ID = 0
    XFCP_EXT_ID_STR = ""
    COUNT_SIZE = 16
    DATA_WIDTH = 32
    ADDR_WIDTH = 32
    STRB_WIDTH = (DATA_WIDTH/8)

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    up_xfcp_in_tdata = Signal(intbv(0)[8:])
    up_xfcp_in_tvalid = Signal(bool(0))
    up_xfcp_in_tlast = Signal(bool(0))
    up_xfcp_in_tuser = Signal(bool(0))
    up_xfcp_out_tready = Signal(bool(0))
    m_axil_awready = Signal(bool(0))
    m_axil_wready = Signal(bool(0))
    m_axil_bresp = Signal(intbv(0)[2:])
    m_axil_bvalid = Signal(bool(0))
    m_axil_arready = Signal(bool(0))
    m_axil_rdata = Signal(intbv(0)[DATA_WIDTH:])
    m_axil_rresp = Signal(intbv(0)[2:])
    m_axil_rvalid = Signal(bool(0))

    # Outputs
    up_xfcp_in_tready = Signal(bool(0))
    up_xfcp_out_tdata = Signal(intbv(0)[8:])
    up_xfcp_out_tvalid = Signal(bool(0))
    up_xfcp_out_tlast = Signal(bool(0))
    up_xfcp_out_tuser = Signal(bool(0))
    m_axil_awaddr = Signal(intbv(0)[ADDR_WIDTH:])
    m_axil_awprot = Signal(intbv(0)[3:])
    m_axil_awvalid = Signal(bool(0))
    m_axil_wdata = Signal(intbv(0)[DATA_WIDTH:])
    m_axil_wstrb = Signal(intbv(0)[STRB_WIDTH:])
    m_axil_wvalid = Signal(bool(0))
    m_axil_bready = Signal(bool(0))
    m_axil_araddr = Signal(intbv(0)[ADDR_WIDTH:])
    m_axil_arprot = Signal(intbv(0)[3:])
    m_axil_arvalid = Signal(bool(0))
    m_axil_rready = Signal(bool(0))

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

    # AXI4-Lite RAM model
    axil_ram_inst = axil.AXILiteRam(2**16)
    axil_ram_pause = Signal(bool(False))

    axil_ram_port0 = axil_ram_inst.create_port(
        clk,
        s_axil_awaddr=m_axil_awaddr,
        s_axil_awprot=m_axil_awprot,
        s_axil_awvalid=m_axil_awvalid,
        s_axil_awready=m_axil_awready,
        s_axil_wdata=m_axil_wdata,
        s_axil_wstrb=m_axil_wstrb,
        s_axil_wvalid=m_axil_wvalid,
        s_axil_wready=m_axil_wready,
        s_axil_bresp=m_axil_bresp,
        s_axil_bvalid=m_axil_bvalid,
        s_axil_bready=m_axil_bready,
        s_axil_araddr=m_axil_araddr,
        s_axil_arprot=m_axil_arprot,
        s_axil_arvalid=m_axil_arvalid,
        s_axil_arready=m_axil_arready,
        s_axil_rdata=m_axil_rdata,
        s_axil_rresp=m_axil_rresp,
        s_axil_rvalid=m_axil_rvalid,
        s_axil_rready=m_axil_rready,
        pause=axil_ram_pause,
        name='port0'
    )

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
        m_axil_awaddr=m_axil_awaddr,
        m_axil_awprot=m_axil_awprot,
        m_axil_awvalid=m_axil_awvalid,
        m_axil_awready=m_axil_awready,
        m_axil_wdata=m_axil_wdata,
        m_axil_wstrb=m_axil_wstrb,
        m_axil_wvalid=m_axil_wvalid,
        m_axil_wready=m_axil_wready,
        m_axil_bresp=m_axil_bresp,
        m_axil_bvalid=m_axil_bvalid,
        m_axil_bready=m_axil_bready,
        m_axil_araddr=m_axil_araddr,
        m_axil_arprot=m_axil_arprot,
        m_axil_arvalid=m_axil_arvalid,
        m_axil_arready=m_axil_arready,
        m_axil_rdata=m_axil_rdata,
        m_axil_rresp=m_axil_rresp,
        m_axil_rvalid=m_axil_rvalid,
        m_axil_rready=m_axil_rready
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    def wait_normal():
        i = 4
        while i > 0:
            i = max(0, i-1)
            if not up_xfcp_port.idle() or m_axil_awvalid or m_axil_wvalid or m_axil_bvalid or m_axil_arvalid or m_axil_rvalid:
                i = 4
            yield clk.posedge

    def wait_pause_source():
        i = 2
        while i > 0:
            i = max(0, i-1)
            if not up_xfcp_port.idle() or m_axil_awvalid or m_axil_wvalid or m_axil_bvalid or m_axil_arvalid or m_axil_rvalid:
                i = 2
            up_xfcp_port_in_pause.next = True
            yield clk.posedge
            yield clk.posedge
            yield clk.posedge
            up_xfcp_port_in_pause.next = False
            yield clk.posedge

    def wait_pause_sink():
        i = 2
        while i > 0:
            i = max(0, i-1)
            if not up_xfcp_port.idle() or m_axil_awvalid or m_axil_wvalid or m_axil_bvalid or m_axil_arvalid or m_axil_rvalid:
                i = 2
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
        print("test 1: test write")
        current_test.next = 1

        pkt = xfcp.XFCPFrame()
        pkt.ptype = 0x12
        pkt.payload = bytearray(struct.pack('<IH', 0, 4)+b'\x11\x22\x33\x44')

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt)
            yield clk.posedge

            yield wait()
            yield clk.posedge

            data = axil_ram_inst.read_mem(0, 32)
            for i in range(0, len(data), 16):
                print(" ".join(("{:02x}".format(c) for c in bytearray(data[i:i+16]))))

            assert axil_ram_inst.read_mem(0, 4) == b'\x11\x22\x33\x44'

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x13
            assert rx_pkt.payload.data == struct.pack('<IH', 0, 4)

            yield delay(100)

        yield clk.posedge
        print("test 2: test read")
        current_test.next = 2

        pkt = xfcp.XFCPFrame()
        pkt.ptype = 0x10
        pkt.payload = bytearray(struct.pack('<IH', 0, 4))

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt)
            yield clk.posedge

            yield wait()
            yield clk.posedge

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x11
            assert rx_pkt.payload.data == struct.pack('<IH', 0, 4)+b'\x11\x22\x33\x44'

            yield delay(100)

        yield clk.posedge
        print("test 3: various writes")
        current_test.next = 3

        for length in range(1,8):
            for offset in range(4):

                pkt = xfcp.XFCPFrame()
                pkt.ptype = 0x12
                pkt.payload = bytearray(struct.pack('<IH', 256*(16*offset+length)+offset, length)+b'\x11\x22\x33\x44\x55\x66\x77\x88'[0:length])

                for wait in wait_normal, wait_pause_source, wait_pause_sink:
                    up_xfcp_port.send(pkt)
                    yield clk.posedge

                    yield wait()

                    yield clk.posedge

                    data = axil_ram_inst.read_mem(256*(16*offset+length), 32)
                    for i in range(0, len(data), 16):
                        print(" ".join(("{:02x}".format(c) for c in bytearray(data[i:i+16]))))

                    assert axil_ram_inst.read_mem(256*(16*offset+length)+offset,length) == b'\x11\x22\x33\x44\x55\x66\x77\x88'[0:length]

                    rx_pkt = up_xfcp_port.recv()

                    print(rx_pkt)
                    assert rx_pkt.ptype == 0x13
                    assert rx_pkt.payload.data == struct.pack('<IH', 256*(16*offset+length)+offset, length)

                    yield delay(100)

        yield clk.posedge
        print("test 4: various reads")
        current_test.next = 4

        for length in range(1,8):
            for offset in range(4):

                pkt = xfcp.XFCPFrame()
                pkt.ptype = 0x10
                pkt.payload = bytearray(struct.pack('<IH', 256*(16*offset+length)+offset, length))

                for wait in wait_normal, wait_pause_source, wait_pause_sink:
                    up_xfcp_port.send(pkt)
                    yield clk.posedge

                    yield wait()

                    yield clk.posedge

                    rx_pkt = up_xfcp_port.recv()

                    print(rx_pkt)
                    assert rx_pkt.ptype == 0x11
                    assert rx_pkt.payload.data == struct.pack('<IH', 256*(16*offset+length)+offset, length)+b'\x11\x22\x33\x44\x55\x66\x77\x88'[0:length]

                    yield delay(100)

        yield clk.posedge
        print("test 5: test trailing padding")
        current_test.next = 5

        pkt1 = xfcp.XFCPFrame()
        pkt1.ptype = 0x12
        pkt1.payload = bytearray(struct.pack('<IH', 7, 1)+b'\xAA')

        pkt2 = xfcp.XFCPFrame()
        pkt2.ptype = 0x12
        pkt2.payload = bytearray(struct.pack('<IH', 8, 1)+b'\xBB'+b'\x00'*8)

        pkt3 = xfcp.XFCPFrame()
        pkt3.ptype = 0x10
        pkt3.payload = bytearray(struct.pack('<IH', 7, 1)+b'\x00'*8)

        pkt4 = xfcp.XFCPFrame()
        pkt4.ptype = 0x10
        pkt4.payload = bytearray(struct.pack('<IH', 7, 1)+b'\x00'*1)

        pkt5 = xfcp.XFCPFrame()
        pkt5.ptype = 0x12
        pkt5.payload = bytearray(struct.pack('<IH', 9, 1)+b'\xCC')

        for wait in wait_normal, wait_pause_source, wait_pause_sink:
            up_xfcp_port.send(pkt1)
            up_xfcp_port.send(pkt2)
            up_xfcp_port.send(pkt3)
            up_xfcp_port.send(pkt4)
            up_xfcp_port.send(pkt5)
            
            yield clk.posedge

            yield wait()
            yield clk.posedge

            data = axil_ram_inst.read_mem(0, 32)
            for i in range(0, len(data), 16):
                print(" ".join(("{:02x}".format(c) for c in bytearray(data[i:i+16]))))

            assert axil_ram_inst.read_mem(7, 3) == b'\xAA\xBB\xCC'

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x13
            assert rx_pkt.payload.data == struct.pack('<IH', 7, 1)

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x13
            assert rx_pkt.payload.data == struct.pack('<IH', 8, 1)

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x11
            assert rx_pkt.payload.data == struct.pack('<IH', 7, 1)+b'\xAA'

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x11
            assert rx_pkt.payload.data == struct.pack('<IH', 7, 1)+b'\xAA'

            rx_pkt = up_xfcp_port.recv()

            print(rx_pkt)
            assert rx_pkt.ptype == 0x13
            assert rx_pkt.payload.data == struct.pack('<IH', 9, 1)

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
        pkt2.ptype = 0x10
        pkt2.payload = bytearray(struct.pack('<IH', 0, 4))

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
            assert rx_pkt.ptype == 0x11
            assert rx_pkt.payload.data == struct.pack('<IH', 0, 4)+b'\x11\x22\x33\x44'

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
