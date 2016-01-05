#!/usr/bin/env python
"""

Copyright (c) 2015-2016 Alex Forencich

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

try:
    from queue import Queue
except ImportError:
    from Queue import Queue

import axis_ep
import i2c

module = 'i2c_master'

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("test_%s.v" % module)

src = ' '.join(srcs)

build_cmd = "iverilog -o test_%s.vvp %s" % (module, src)

def dut_i2c_master(clk,
                   rst,
                   current_test,
                   cmd_address,
                   cmd_start,
                   cmd_read,
                   cmd_write,
                   cmd_write_multiple,
                   cmd_stop,
                   cmd_valid,
                   cmd_ready,
                   data_in,
                   data_in_valid,
                   data_in_ready,
                   data_in_last,
                   data_out,
                   data_out_valid,
                   data_out_ready,
                   data_out_last,
                   scl_i,
                   scl_o,
                   scl_t,
                   sda_i,
                   sda_o,
                   sda_t,
                   busy,
                   bus_control,
                   bus_active,
                   missed_ack,
                   prescale,
                   stop_on_idle):

    if os.system(build_cmd):
        raise Exception("Error running build command")
    return Cosimulation("vvp -m myhdl test_%s.vvp -lxt2" % module,
                clk=clk,
                rst=rst,
                current_test=current_test,
                cmd_address=cmd_address,
                cmd_start=cmd_start,
                cmd_read=cmd_read,
                cmd_write=cmd_write,
                cmd_write_multiple=cmd_write_multiple,
                cmd_stop=cmd_stop,
                cmd_valid=cmd_valid,
                cmd_ready=cmd_ready,
                data_in=data_in,
                data_in_valid=data_in_valid,
                data_in_ready=data_in_ready,
                data_in_last=data_in_last,
                data_out=data_out,
                data_out_valid=data_out_valid,
                data_out_ready=data_out_ready,
                data_out_last=data_out_last,
                scl_i=scl_i,
                scl_o=scl_o,
                scl_t=scl_t,
                sda_i=sda_i,
                sda_o=sda_o,
                sda_t=sda_t,
                busy=busy,
                bus_control=bus_control,
                bus_active=bus_active,
                missed_ack=missed_ack,
                prescale=prescale,
                stop_on_idle=stop_on_idle)

def bench():

    # Parameters


    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    cmd_address = Signal(intbv(0)[7:])
    cmd_start = Signal(bool(0))
    cmd_read = Signal(bool(0))
    cmd_write = Signal(bool(0))
    cmd_write_multiple = Signal(bool(0))
    cmd_stop = Signal(bool(0))
    cmd_valid = Signal(bool(0))
    data_in = Signal(intbv(0)[8:])
    data_in_valid = Signal(bool(0))
    data_in_last = Signal(bool(0))
    data_out_ready = Signal(bool(0))
    scl_i = Signal(bool(1))
    sda_i = Signal(bool(1))
    prescale = Signal(intbv(0)[16:])
    stop_on_idle = Signal(bool(0))

    s1_scl_i = Signal(bool(1))
    s1_sda_i = Signal(bool(1))

    s2_scl_i = Signal(bool(1))
    s2_sda_i = Signal(bool(1))

    # Outputs
    cmd_ready = Signal(bool(0))
    data_in_ready = Signal(bool(0))
    data_out = Signal(intbv(0)[8:])
    data_out_valid = Signal(bool(0))
    data_out_last = Signal(bool(0))
    scl_o = Signal(bool(1))
    scl_t = Signal(bool(1))
    sda_o = Signal(bool(1))
    sda_t = Signal(bool(1))
    busy = Signal(bool(0))
    bus_control = Signal(bool(0))
    bus_active = Signal(bool(0))
    missed_ack = Signal(bool(0))

    s1_scl_o = Signal(bool(1))
    s1_scl_t = Signal(bool(1))
    s1_sda_o = Signal(bool(1))
    s1_sda_t = Signal(bool(1))

    s2_scl_o = Signal(bool(1))
    s2_scl_t = Signal(bool(1))
    s2_sda_o = Signal(bool(1))
    s2_sda_t = Signal(bool(1))

    # sources and sinks
    cmd_source_queue = Queue()
    cmd_source_pause = Signal(bool(0))
    data_source_queue = Queue()
    data_source_pause = Signal(bool(0))
    data_sink_queue = Queue()
    data_sink_pause = Signal(bool(0))

    cmd_source = axis_ep.AXIStreamSource(clk,
                                     rst,
                                     tdata=(cmd_address, cmd_start, cmd_read, cmd_write, cmd_write_multiple, cmd_stop),
                                     tvalid=cmd_valid,
                                     tready=cmd_ready,
                                     fifo=cmd_source_queue,
                                     pause=cmd_source_pause,
                                     name='cmd_source')

    data_source = axis_ep.AXIStreamSource(clk,
                                     rst,
                                     tdata=data_in,
                                     tvalid=data_in_valid,
                                     tready=data_in_ready,
                                     tlast=data_in_last,
                                     fifo=data_source_queue,
                                     pause=data_source_pause,
                                     name='data_source')

    data_sink = axis_ep.AXIStreamSink(clk,
                                     rst,
                                     tdata=data_out,
                                     tvalid=data_out_valid,
                                     tready=data_out_ready,
                                     tlast=data_out_last,
                                     fifo=data_sink_queue,
                                     pause=data_sink_pause,
                                     name='data_sink')

    # I2C memory model 1
    i2c_mem_inst1 = i2c.I2CMem(1024)

    i2c_mem_logic1 = i2c_mem_inst1.create_logic(scl_i=s1_scl_i,
                                                scl_o=s1_scl_o,
                                                scl_t=s1_scl_t,
                                                sda_i=s1_sda_i,
                                                sda_o=s1_sda_o,
                                                sda_t=s1_sda_t,
                                                abw=2,
                                                address=0x50,
                                                latency=0,
                                                name='slave1')

    # I2C memory model 2
    i2c_mem_inst2 = i2c.I2CMem(1024)

    i2c_mem_logic2 = i2c_mem_inst2.create_logic(scl_i=s2_scl_i,
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
    dut = dut_i2c_master(clk,
                         rst,
                         current_test,
                         cmd_address,
                         cmd_start,
                         cmd_read,
                         cmd_write,
                         cmd_write_multiple,
                         cmd_stop,
                         cmd_valid,
                         cmd_ready,
                         data_in,
                         data_in_valid,
                         data_in_ready,
                         data_in_last,
                         data_out,
                         data_out_valid,
                         data_out_ready,
                         data_out_last,
                         scl_i,
                         scl_o,
                         scl_t,
                         sda_i,
                         sda_o,
                         sda_t,
                         busy,
                         bus_control,
                         bus_active,
                         missed_ack,
                         prescale,
                         stop_on_idle)

    @always_comb
    def bus():
        # emulate I2C wired AND
        scl_i.next = scl_o & s1_scl_o & s2_scl_o;
        sda_i.next = sda_o & s1_sda_o & s2_sda_o;

        s1_scl_i.next = scl_o & s1_scl_o & s2_scl_o;
        s1_sda_i.next = sda_o & s1_sda_o & s2_sda_o;

        s2_scl_i.next = scl_o & s1_scl_o & s2_scl_o;
        s2_sda_i.next = sda_o & s1_sda_o & s2_sda_o;

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

        prescale.next = 2

        yield clk.posedge

        # testbench stimulus

        yield clk.posedge
        print("test 1: write")
        current_test.next = 1

        cmd_source_queue.put([(
            0x50, # address
            0,    # start
            0,    # read
            0,    # write
            1,    # write_multiple
            1     # stop
        )])
        data_source_queue.put((b'\x00\x04'+b'\x11\x22\x33\x44'))

        yield clk.posedge
        yield clk.posedge
        yield clk.posedge
        while busy or bus_active or not cmd_source_queue.empty():
            yield clk.posedge
        yield clk.posedge

        data = i2c_mem_inst1.read_mem(0, 32)
        for i in range(0, len(data), 16):
            print(" ".join(("{:02x}".format(c) for c in bytearray(data[i:i+16]))))

        assert i2c_mem_inst1.read_mem(4,4) == b'\x11\x22\x33\x44'

        yield delay(100)

        yield clk.posedge
        print("test 2: read")
        current_test.next = 2

        cmd_source_queue.put([(
            0x50, # address
            0,    # start
            0,    # read
            0,    # write
            1,    # write_multiple
            0     # stop
        )])
        data_source_queue.put((b'\x00\x04'))

        for i in range(3):
            cmd_source_queue.put([(
                0x50, # address
                0,    # start
                1,    # read
                0,    # write
                0,    # write_multiple
                0     # stop
            )])

        cmd_source_queue.put([(
            0x50, # address
            0,    # start
            1,    # read
            0,    # write
            0,    # write_multiple
            1     # stop
        )])

        yield clk.posedge
        yield clk.posedge
        yield clk.posedge
        while busy or bus_active or not cmd_source_queue.empty():
            yield clk.posedge
        yield clk.posedge

        data = data_sink_queue.get(False)
        assert data.data == b'\x11\x22\x33\x44'

        yield delay(100)

        yield clk.posedge
        print("test 3: write to slave 2")
        current_test.next = 3

        cmd_source_queue.put([(
            0x51, # address
            0,    # start
            0,    # read
            0,    # write
            1,    # write_multiple
            1     # stop
        )])
        data_source_queue.put((b'\x00\x04'+b'\x11\x22\x33\x44'))

        yield clk.posedge
        yield clk.posedge
        yield clk.posedge
        while busy or bus_active or not cmd_source_queue.empty():
            yield clk.posedge
        yield clk.posedge

        data = i2c_mem_inst1.read_mem(0, 32)
        for i in range(0, len(data), 16):
            print(" ".join(("{:02x}".format(c) for c in bytearray(data[i:i+16]))))

        assert i2c_mem_inst1.read_mem(4,4) == b'\x11\x22\x33\x44'

        yield delay(100)

        yield clk.posedge
        print("test 4: read from slave 2")
        current_test.next = 4

        cmd_source_queue.put([(
            0x51, # address
            0,    # start
            0,    # read
            0,    # write
            1,    # write_multiple
            0     # stop
        )])
        data_source_queue.put((b'\x00\x04'))

        for i in range(3):
            cmd_source_queue.put([(
                0x51, # address
                0,    # start
                1,    # read
                0,    # write
                0,    # write_multiple
                0     # stop
            )])

        cmd_source_queue.put([(
            0x51, # address
            0,    # start
            1,    # read
            0,    # write
            0,    # write_multiple
            1     # stop
        )])

        yield clk.posedge
        yield clk.posedge
        yield clk.posedge
        while busy or bus_active or not cmd_source_queue.empty():
            yield clk.posedge
        yield clk.posedge

        data = data_sink_queue.get(False)
        assert data.data == b'\x11\x22\x33\x44'

        yield delay(100)

        raise StopSimulation

    return dut, cmd_source, data_source, data_sink, i2c_mem_logic1, i2c_mem_logic2, bus, clkgen, check

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
