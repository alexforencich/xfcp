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
import struct

import xfcp
import wb

module = 'xfcp_mod_wb'
testbench = 'test_%s_32' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    XFCP_ID_TYPE = 0x0001
    XFCP_ID_STR = "WB Master"
    XFCP_EXT_ID = b''
    XFCP_EXT_ID_STR = ""
    COUNT_SIZE = 16
    WB_DATA_WIDTH = 32
    WB_ADDR_WIDTH = 32
    WB_SELECT_WIDTH = (WB_DATA_WIDTH)/8

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    up_xfcp_in_tdata = Signal(intbv(0)[8:])
    up_xfcp_in_tvalid = Signal(bool(0))
    up_xfcp_in_tlast = Signal(bool(0))
    up_xfcp_in_tuser = Signal(bool(0))
    up_xfcp_out_tready = Signal(bool(0))
    wb_dat_i = Signal(intbv(0)[WB_DATA_WIDTH:])
    wb_ack_i = Signal(bool(0))
    wb_err_i = Signal(bool(0))

    # Outputs
    up_xfcp_in_tready = Signal(bool(0))
    up_xfcp_out_tdata = Signal(intbv(0)[8:])
    up_xfcp_out_tvalid = Signal(bool(0))
    up_xfcp_out_tlast = Signal(bool(0))
    up_xfcp_out_tuser = Signal(bool(0))
    wb_adr_o = Signal(intbv(0)[WB_ADDR_WIDTH:])
    wb_dat_o = Signal(intbv(0)[WB_DATA_WIDTH:])
    wb_we_o = Signal(bool(0))
    wb_sel_o = Signal(intbv(0)[WB_SELECT_WIDTH:])
    wb_stb_o = Signal(bool(0))
    wb_cyc_o = Signal(bool(0))

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

    # WB RAM model
    wb_ram = wb.WBRam(2**16)

    wb_ram_port0 = wb_ram.create_port(
        clk,
        adr_i=wb_adr_o,
        dat_i=wb_dat_o,
        dat_o=wb_dat_i,
        we_i=wb_we_o,
        sel_i=wb_sel_o,
        stb_i=wb_stb_o,
        ack_o=wb_ack_i,
        cyc_i=wb_cyc_o,
        latency=1,
        asynchronous=False,
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

        wb_adr_o=wb_adr_o,
        wb_dat_i=wb_dat_i,
        wb_dat_o=wb_dat_o,
        wb_we_o=wb_we_o,
        wb_sel_o=wb_sel_o,
        wb_stb_o=wb_stb_o,
        wb_ack_i=wb_ack_i,
        wb_err_i=wb_err_i,
        wb_cyc_o=wb_cyc_o
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    def wait_normal():
        i = 4
        while i > 0:
            i = max(0, i-1)
            if up_xfcp_in_tvalid or up_xfcp_out_tvalid or wb_cyc_o:
                i = 4
            yield clk.posedge

    def wait_pause_source():
        i = 2
        while i > 0:
            i = max(0, i-1)
            if up_xfcp_in_tvalid or up_xfcp_out_tvalid or wb_cyc_o:
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
            if up_xfcp_in_tvalid or up_xfcp_out_tvalid or wb_cyc_o:
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

            data = wb_ram.read_mem(0, 32)
            for i in range(0, len(data), 16):
                print(" ".join(("{:02x}".format(c) for c in bytearray(data[i:i+16]))))

            assert wb_ram.read_mem(0, 4) == b'\x11\x22\x33\x44'

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

                    data = wb_ram.read_mem(256*(16*offset+length), 32)
                    for i in range(0, len(data), 16):
                        print(" ".join(("{:02x}".format(c) for c in bytearray(data[i:i+16]))))

                    assert wb_ram.read_mem(256*(16*offset+length)+offset,length) == b'\x11\x22\x33\x44\x55\x66\x77\x88'[0:length]

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

            data = wb_ram.read_mem(0, 32)
            for i in range(0, len(data), 16):
                print(" ".join(("{:02x}".format(c) for c in bytearray(data[i:i+16]))))

            assert wb_ram.read_mem(7, 3) == b'\xAA\xBB\xCC'

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
