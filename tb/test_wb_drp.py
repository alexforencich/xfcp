#!/usr/bin/env python
"""

Copyright (c) 2016 Alex Forencich

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

import wb
import drp

module = 'wb_drp'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    ADDR_WIDTH = 16

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    wb_adr_i = Signal(intbv(0)[ADDR_WIDTH:])
    wb_dat_i = Signal(intbv(0)[16:])
    wb_we_i = Signal(bool(0))
    wb_stb_i = Signal(bool(0))
    wb_cyc_i = Signal(bool(0))
    drp_di = Signal(intbv(0)[16:])
    drp_rdy = Signal(bool(0))

    # Outputs
    wb_dat_o = Signal(intbv(0)[16:])
    wb_ack_o = Signal(bool(0))
    drp_addr = Signal(intbv(0)[ADDR_WIDTH:])
    drp_do = Signal(intbv(0)[16:])
    drp_en = Signal(bool(0))
    drp_we = Signal(bool(0))

    # WB master
    wb_master_inst = wb.WBMaster()

    wb_master_logic = wb_master_inst.create_logic(
        clk,
        adr_o=wb_adr_i,
        dat_i=wb_dat_o,
        dat_o=wb_dat_i,
        we_o=wb_we_i,
        stb_o=wb_stb_i,
        ack_i=wb_ack_o,
        cyc_o=wb_cyc_i,
        name='master'
    )

    # DRP model
    drp_inst = drp.DRPRam(2**16)

    drp_logic = drp_inst.create_port(
        clk,
        addr=drp_addr,
        di=drp_do,
        do=drp_di,
        en=drp_en,
        we=drp_we,
        rdy=drp_rdy,
        latency=6,
        name='drp'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m myhdl %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,

        wb_adr_i=wb_adr_i,
        wb_dat_i=wb_dat_i,
        wb_dat_o=wb_dat_o,
        wb_we_i=wb_we_i,
        wb_stb_i=wb_stb_i,
        wb_ack_o=wb_ack_o,
        wb_cyc_i=wb_cyc_i,

        drp_addr=drp_addr,
        drp_do=drp_do,
        drp_di=drp_di,
        drp_en=drp_en,
        drp_we=drp_we,
        drp_rdy=drp_rdy
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

        yield clk.posedge
        print("test 1: write words")
        current_test.next = 1

        for offset in range(4):
            wb_master_inst.init_write_words((0x4000+offset*32+0)/2+offset, [0x1234])
            wb_master_inst.init_write_dwords((0x4000+offset*32+16)/4+offset, [0x12345678])

            yield wb_master_inst.wait()
            yield clk.posedge

            data = drp_inst.read_mem(0x4000+offset*32, 32)
            for i in range(0, len(data), 16):
                print(" ".join(("{:02x}".format(c) for c in bytearray(data[i:i+16]))))

            assert drp_inst.read_mem((0x4000+offset*32+0)+offset*2, 2) == b'\x34\x12'
            assert drp_inst.read_mem((0x4000+offset*32+16)+offset*4, 4) == b'\x78\x56\x34\x12'

            assert drp_inst.read_words((0x4000+offset*32+0)/2+offset, 1)[0] == 0x1234
            assert drp_inst.read_dwords((0x4000+offset*32+16)/4+offset, 1)[0] == 0x12345678

        yield delay(100)

        yield clk.posedge
        print("test 2: read words")
        current_test.next = 2

        for offset in range(4):
            wb_master_inst.init_read_words((0x4000+offset*32+0)/2+offset, 1)
            wb_master_inst.init_read_dwords((0x4000+offset*32+16)/4+offset, 1)

            yield wb_master_inst.wait()
            yield clk.posedge

            data = wb_master_inst.get_read_data_words()
            assert data[0] == (0x4000+offset*32+0)/2+offset
            assert data[1][0] == 0x1234

            data = wb_master_inst.get_read_data_dwords()
            assert data[0] == (0x4000+offset*32+16)/4+offset
            assert data[1][0] == 0x12345678

        yield delay(100)

        raise StopSimulation

    return dut, wb_master_logic, drp_logic, clkgen, check

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
