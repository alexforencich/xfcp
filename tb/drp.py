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
import mmap

try:
    from queue import Queue
except ImportError:
    from Queue import Queue

class DRPRam(object):
    def __init__(self, size = 1024):
        self.size = size
        self.mem = mmap.mmap(-1, size)

    def read_mem(self, address, length):
        self.mem.seek(address)
        return self.mem.read(length)

    def write_mem(self, address, data):
        self.mem.seek(address)
        self.mem.write(data)

    def read_words(self, address, length, ws=2):
        assert ws in (1, 2, 4, 8)
        self.mem.seek(int(address*ws))
        d = []
        for i in range(length):
            w = 0
            data = bytearray(self.mem.read(ws))
            for j in range(ws-1,-1,-1):
                w <<= 8
                w += data[j]
            d.append(w)
        return d

    def read_dwords(self, address, length):
        return self.read_words(address, length, 4)

    def read_qwords(self, address, length):
        return self.read_words(address, length, 8)

    def write_words(self, address, data, ws=2):
        assert ws in (1, 2, 4, 8)
        self.mem.seek(int(address*ws))
        for w in data:
            d = []
            for j in range(ws):
                d.append(w&0xff)
                w >>= 8
            self.mem.write(bytearray(d))

    def write_dwords(self, address, length):
        return self.write_words(address, length, 4)

    def write_qwords(self, address, length):
        return self.write_words(address, length, 8)

    def create_port(self,
                    clk,
                    addr=Signal(intbv(0)[8:]),
                    di=None,
                    do=None,
                    we=Signal(bool(0)),
                    en=Signal(bool(0)),
                    rdy=Signal(bool(0)),
                    latency=1,
                    name=None):

        @instance
        def logic():
            if di is not None:
                assert len(di) == 16
            if do is not None:
                assert len(do) == 16

            while True:
                yield clk.posedge

                rdy.next = False

                if en & ~rdy:
                    self.mem.seek(addr*2 % self.size)

                    if we:
                        for i in range(latency):
                            yield clk.posedge
                        rdy.next = True

                        # write
                        data = []
                        val = int(di)
                        for i in range(2):
                            data += [val & 0xff]
                            val >>= 8
                        data = bytearray(data)
                        for i in range(2):
                            self.mem.write(data[i:i+1])
                        if name is not None:
                            print("[%s] Write word a:0x%08x d:%s" % (name, addr, " ".join(("{:02x}".format(c) for c in bytearray(data)))))
                    else:
                        for i in range(latency):
                            yield clk.posedge
                        rdy.next = True

                        # read
                        data = bytearray(self.mem.read(2))
                        val = 0
                        for i in range(1,-1,-1):
                            val <<= 8
                            val += data[i]
                        do.next = val
                        if name is not None:
                            print("[%s] Read word a:0x%08x d:%s" % (name, addr, " ".join(("{:02x}".format(c) for c in bytearray(data)))))

        return logic

