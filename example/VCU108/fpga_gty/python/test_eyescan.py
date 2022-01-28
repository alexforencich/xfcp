#!/usr/bin/env python
"""

Copyright (c) 2022 Alex Forencich

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

import argparse
import datetime
import time

import xfcp.interface
import xfcp.node
import xfcp.i2c_node
import xfcp.gty_node


class EyeScanChannel:
    def __init__(self, xcvr):
        self.xcvr = xcvr

        self.file = None
        self.file_name = None

        self.prescale = 4
        self.horz_start = -32
        self.horz_stop = 32
        self.horz_step = 4
        self.vert_start = -32
        self.vert_stop = 32
        self.vert_step = 4
        self.vs_range = 0

        self.data_width = None
        self.int_data_width = None

        self.horz_offset = 0
        self.vert_offset = 0
        self.ut_sign = 0

        self.data = []
        self.running = False

    def start(self):
        self.running = False

        if self.file_name:
            self.file = open(self.file_name, 'w')

            self.file.write("# eyescan\n")
            self.file.write(f"# date: {datetime.datetime.now()}\n")
            self.file.write("# node path: %s\n" % '.'.join(str(x) for x in self.xcvr.path))
            self.file.write(f"# node name: {self.xcvr.name}\n")
            if self.xcvr.ext_str:
                self.file.write(f"# node extended ID: {self.xcvr.ext_str}\n")

        self.data_width = self.xcvr.get_rx_data_width()
        self.int_data_width = self.xcvr.get_rx_int_data_width()

        if self.file:
            self.file.write(f"# data width: {self.data_width}\n")
            self.file.write(f"# int data width: {self.int_data_width}\n")
            self.file.write(f"# ES prescale: {2**(self.prescale+1)} (raw {self.prescale})\n")
            self.file.write("horiz_offset,vert_offset,ut_sign,bit_count,error_count\n")

        # init and check for proper alignment
        self.xcvr.set_es_control(0x00)

        self.xcvr.set_es_prescale(4)
        self.xcvr.set_es_errdet_en(1)

        if self.xcvr.get_es_mask_width() == 80:
            self.xcvr.set_es_sdata_mask(0xffffffffff0000000000 | (0xffffffffff >> self.int_data_width))
            self.xcvr.set_es_qual_mask(0xffffffffffffffffffff)
        else:
            self.xcvr.set_es_sdata_mask(0xffffffffffffffffffff00000000000000000000 | (0xffffffffffffffffffff >> self.int_data_width))
            self.xcvr.set_es_qual_mask(0xffffffffffffffffffffffffffffffffffffffff)

        self.xcvr.set_rx_eyescan_vs_range(self.vs_range)

        self.xcvr.set_es_horz_offset(0x800)
        self.xcvr.set_rx_eyescan_vs_neg_dir(0)
        self.xcvr.set_rx_eyescan_vs_code(0)
        self.xcvr.set_rx_eyescan_vs_ut_sign(0)

        self.xcvr.set_es_eye_scan_en(1)

        self.xcvr.rx_pma_reset()
        time.sleep(0.5)

        for k in range(10):
            for k in range(30):
                if self.xcvr.get_tx_reset_done() and self.xcvr.get_rx_reset_done():
                    break
                time.sleep(0.1)

            if not self.xcvr.get_tx_reset_done() or not self.xcvr.get_rx_reset_done():
                print(f"[{self.xcvr.name}] Error: channel stuck in reset")
                return

            time.sleep(0.1)

            # check for lock
            self.xcvr.set_es_control(0x01)

            while not self.xcvr.get_es_control_status() & 1:
                pass

            self.xcvr.set_es_control(0x00)
            error_count = self.xcvr.get_es_error_count()
            sample_count = self.xcvr.get_es_sample_count()*2**(1+4)
            bit_count = sample_count*self.int_data_width

            ber = error_count/bit_count

            if ber < 0.01:
                break

            print(f"[{self.xcvr.name}] High BER ({ber:.02f}), resetting eye scan logic")

            self.xcvr.set_es_horz_offset(0x880)
            self.xcvr.set_eyescan_reset(1)
            self.xcvr.set_es_horz_offset(0x800)
            self.xcvr.set_eyescan_reset(0)

        if ber > 0.01:
            print(f"[{self.xcvr.name}] High BER, alignment failed")
            return

        # set up for measurement
        self.horz_offset = self.horz_start
        self.vert_offset = self.vert_start
        self.ut_sign = 0

        self.xcvr.set_es_control(0x00)
        self.xcvr.set_es_prescale(self.prescale)
        self.xcvr.set_es_errdet_en(1)
        self.xcvr.set_es_horz_offset((self.horz_offset & 0x7ff) | 0x800)
        self.xcvr.set_rx_eyescan_vs_neg_dir(self.vert_offset < 0)
        self.xcvr.set_rx_eyescan_vs_code(abs(self.vert_offset))
        self.xcvr.set_rx_eyescan_vs_ut_sign(self.ut_sign)

        # start
        self.xcvr.set_es_control(0x01)

        self.running = True

    def step(self):
        if not self.running:
            return False

        if not self.xcvr.get_es_control_status() & 1:
            return True

        self.xcvr.set_es_control(0x00)
        error_count = self.xcvr.get_es_error_count()
        sample_count = self.xcvr.get_es_sample_count()*2**(1+self.prescale)
        bit_count = sample_count*self.int_data_width

        data = (self.horz_offset, self.vert_offset, self.ut_sign, bit_count, error_count)
        self.data.append(data)

        line = f"{self.horz_offset},{self.vert_offset},{self.ut_sign},{bit_count},{error_count}"

        print(f"[{self.xcvr.name}] {line}")

        if self.file:
            self.file.write(f"{line}\n")
            self.file.flush()

        restart = False

        if not self.ut_sign:
            self.ut_sign = 1
            restart = True
        else:
            self.ut_sign = 0

        self.xcvr.set_rx_eyescan_vs_ut_sign(self.ut_sign)

        if restart:
            self.xcvr.set_es_control(0x01)
            return True

        if self.vert_offset < self.vert_stop:
            self.vert_offset += self.vert_step
            restart = True
        else:
            self.vert_offset = self.vert_start

        self.xcvr.set_rx_eyescan_vs_neg_dir(self.vert_offset < 0)
        self.xcvr.set_rx_eyescan_vs_code(abs(self.vert_offset))

        if restart:
            self.xcvr.set_es_control(0x01)
            return True

        if self.horz_offset < self.horz_stop:
            self.horz_offset += self.horz_step
            restart = True
        else:
            # done
            self.running = False

        self.xcvr.set_es_horz_offset((self.horz_offset & 0x7ff) | 0x800)

        if restart:
            self.xcvr.set_es_control(0x01)
            return True

        self.running = False
        return False

    def run(self):
        self.start()

        done = False
        while not done:
            done = True
            if self.step():
                done = False


def main():
    #parser = argparse.ArgumentParser(description=__doc__.strip())
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--port', type=str, default='/dev/ttyUSB1', help="Port")
    parser.add_argument('-b', '--baud', type=int, default=115200, help="Baud rate")
    parser.add_argument('-H', '--host', type=str, help="Host (i.e. 192.168.1.128:14000)")

    args = parser.parse_args()

    port = args.port
    baud = args.baud
    host = args.host

    intf = None

    if host is not None:
        # ethernet interface
        intf = xfcp.interface.UDPInterface(host)
    else:
        # serial interface
        intf = xfcp.interface.SerialInterface(port, baud)

    n = intf.enumerate()

    print("XFCP node tree:")
    n.print_tree()

    xcvr = n.find_by_type(xfcp.gty_node.GTYE3ChannelNode)

    print("Place transceivers in PRBS31 mode")
    for ch in xcvr:
        ch.set_tx_prbs_mode(xfcp.gty_node.PRBS_MODE_PRBS31)
        ch.set_rx_prbs_mode(xfcp.gty_node.PRBS_MODE_PRBS31)

    print("Reset transceivers")
    for ch in xcvr:
        ch.reset()

    print("Wait for transceiver reset done")
    for k in range(30):
        done = True
        for ch in xcvr:
            if not ch.get_tx_reset_done() or not ch.get_rx_reset_done():
                done = False
                break
        if done:
            break
        time.sleep(0.1)

    print("Check reset done status")
    for ch in xcvr:
        if not ch.get_tx_reset_done():
            print("[%s] [%s]%s TX reset not done!" % (
                '.'.join(str(x) for x in ch.path),
                ch.name,
                ' [{}]'.format(ch.ext_str) if ch.ext_str else ''))
        if not ch.get_rx_reset_done():
            print("[%s] [%s]%s RX reset not done!" % (
                '.'.join(str(x) for x in ch.path),
                ch.name,
                ' [{}]'.format(ch.ext_str) if ch.ext_str else ''))

    print("Done")

    print("Clear error counters")
    for ch in xcvr:
        ch.rx_err_count_reset()
        ch.is_rx_prbs_error()

    time.sleep(0.01)

    for ch in xcvr:
        print("[%s] [%s]%s locked: %d  errors: %d  error count: %d" % (
            '.'.join(str(x) for x in ch.path),
            ch.name,
            ' [{}]'.format(ch.ext_str) if ch.ext_str else '',
            ch.is_rx_prbs_locked(),
            ch.is_rx_prbs_error(),
            ch.get_rx_prbs_err_count()))

    time.sleep(0.01)

    print("Force errors")
    for ch in xcvr:
        ch.tx_prbs_force_error()

    time.sleep(0.01)

    for ch in xcvr:
        print("[%s] [%s]%s locked: %d  errors: %d  error count: %d" % (
            '.'.join(str(x) for x in ch.path),
            ch.name,
            ' [{}]'.format(ch.ext_str) if ch.ext_str else '',
            ch.is_rx_prbs_locked(),
            ch.is_rx_prbs_error(),
            ch.get_rx_prbs_err_count()))

    print("Collect eye diagrams via eye scan")

    print("Init eye scan")

    es_ch_list = []
    for ch in xcvr:
        es_ch = EyeScanChannel(ch)
        es_ch_list.append(es_ch)

        es_ch.prescale = 8
        es_ch.horz_start = -32
        es_ch.horz_stop = 32
        es_ch.horz_step = 4
        es_ch.vert_start = -120
        es_ch.vert_stop = 120
        es_ch.vert_step = 12
        es_ch.vs_range = 0

        es_ch.file_name = "eyescan-%s.csv" % '.'.join(str(x) for x in ch.path)

        es_ch.start()

    print("Running measurement")

    done = False
    while not done:
        done = True
        for ch in es_ch_list:
            if ch.step():
                done = False

    print("Done")


if __name__ == "__main__":
    main()
