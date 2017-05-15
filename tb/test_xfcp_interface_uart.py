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

import uart_ep
import xfcp

module = 'xfcp_interface_uart'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../lib/uart/rtl/uart.v")
srcs.append("../lib/uart/rtl/uart_rx.v")
srcs.append("../lib/uart/rtl/uart_tx.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_cobs_encode.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_cobs_decode.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_fifo.v")
srcs.append("../lib/eth/lib/axis/rtl/axis_frame_fifo.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters


    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    uart_rxd = Signal(bool(1))
    down_xfcp_in_tdata = Signal(intbv(0)[8:])
    down_xfcp_in_tvalid = Signal(bool(0))
    down_xfcp_in_tlast = Signal(bool(0))
    down_xfcp_in_tuser = Signal(bool(0))
    down_xfcp_out_tready = Signal(bool(0))
    prescale = Signal(intbv(0)[16:])

    # Outputs
    uart_txd = Signal(bool(1))
    down_xfcp_in_tready = Signal(bool(0))
    down_xfcp_out_tdata = Signal(intbv(0)[8:])
    down_xfcp_out_tvalid = Signal(bool(0))
    down_xfcp_out_tlast = Signal(bool(0))
    down_xfcp_out_tuser = Signal(bool(0))

    # sources and sinks
    uart_source = uart_ep.UARTSource()

    uart_source_logic = uart_source.create_logic(
        clk,
        rst,
        txd=uart_rxd,
        prescale=prescale,
        name='uart_source'
    )

    uart_sink = uart_ep.UARTSink()

    uart_sink_logic = uart_sink.create_logic(
        clk,
        rst,
        rxd=uart_txd,
        prescale=prescale,
        name='uart_sink'
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

        uart_rxd=uart_rxd,
        uart_txd=uart_txd,

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

        prescale=prescale
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

        prescale.next = 1;

        # testbench stimulus

        yield clk.posedge
        print("test 1: receive")
        current_test.next = 1

        pkt = xfcp.XFCPFrame()
        pkt.path = [1,2,3]
        pkt.rpath = [4]
        pkt.ptype = 1
        pkt.payload = bytearray(range(32))

        uart_source.write(pkt.build_axis_cobs().data+b'\x00')

        rx_pkt = None
        while rx_pkt is None:
            yield clk.posedge
            rx_pkt = down_xfcp_port.recv()

        print(rx_pkt)

        assert rx_pkt == pkt

        yield delay(100)

        yield clk.posedge
        print("test 2: transmit")
        current_test.next = 2

        pkt = xfcp.XFCPFrame()
        pkt.path = [1,2,3]
        pkt.rpath = [4]
        pkt.ptype = 1
        pkt.payload = bytearray(range(32))

        down_xfcp_port.send(pkt)

        yield clk.posedge

        rx_data = b''
        while True:
            if not uart_sink.empty():
                b = bytearray(uart_sink.read(1))
                rx_data += b
                if b[0] == 0:
                    break
            yield clk.posedge

        rx_pkt = xfcp.XFCPFrame()
        rx_pkt.parse_axis_cobs(rx_data[:-1])

        print(rx_pkt)

        assert rx_pkt == pkt

        yield delay(100)

        raise StopSimulation

    return dut, uart_source_logic, uart_sink_logic, down_xfcp_port_logic, clkgen, check

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
