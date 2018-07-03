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
import axis_ep
import struct

def cobs_encode(block):
    block = bytearray(block)
    enc = bytearray()

    seg = bytearray()
    code = 1

    new_data = True

    for b in block:
        if b == 0:
            enc.append(code)
            enc.extend(seg)
            code = 1
            seg = bytearray()
            new_data = True
        else:
            code += 1
            seg.append(b)
            new_data = True
            if code == 255:
                enc.append(code)
                enc.extend(seg)
                code = 1
                seg = bytearray()
                new_data = False

    if new_data:
        enc.append(code)
        enc.extend(seg)

    return bytes(enc)

def cobs_decode(block):
    block = bytearray(block)
    dec = bytearray()

    it = iter(bytearray(block))
    code = 0

    i = 0

    if 0 in block:
        return None

    while i < len(block):
        code = block[i]
        i += 1
        if i+code-1 > len(block):
            return None
        dec.extend(block[i:i+code-1])
        i += code-1
        if code < 255 and i < len(block):
            dec.append(0)

    return bytes(dec)


class XFCPFrame(object):
    def __init__(self, payload=b'', path=[], rpath=[], ptype=0):
        self._payload = b''
        self.path = path
        self.rpath = rpath
        self.ptype = ptype

        if type(payload) is dict:
            self.payload = axis_ep.AXIStreamFrame(payload['xfcp_payload'])
            self.path = list(payload['xfcp_path'])
            self.rpath = list(payload['xfcp_rpath'])
            self.ptype = payload['xfcp_ptype']
        if type(payload) is bytes:
            payload = bytearray(payload)
        if type(payload) is bytearray or type(payload) is axis_ep.AXIStreamFrame:
            self.payload = payload
        if type(payload) is XFCPFrame:
            self.payload = payload.payload
            self.path = list(payload.path)
            self.rpath = list(payload.rpath)
            self.ptype = payload.ptype

    @property
    def payload(self):
        return self._payload

    @payload.setter
    def payload(self, value):
        self._payload = axis_ep.AXIStreamFrame(value)

    def build_axis(self):
        data = b''

        for p in self.path:
            data += struct.pack('B', p)

        if len(self.rpath) > 0:
            data += struct.pack('B', 0xFE)
            for p in self.rpath:
                data += struct.pack('B', p)

        data += struct.pack('B', 0xFF)

        data += struct.pack('B', self.ptype)

        data += self.payload.data

        return axis_ep.AXIStreamFrame(data)

    def build_axis_cobs(self):
        return axis_ep.AXIStreamFrame(cobs_encode(self.build_axis().data))

    def parse_axis(self, data):
        data = axis_ep.AXIStreamFrame(data).data

        i = 0

        self.path = []
        self.rpath = []

        while i < len(data) and data[i] < 0xFE:
            self.path.append(data[i])
            i += 1

        if data[i] == 0xFE:
            i += 1
            while i < len(data) and data[i] < 0xFE:
                self.rpath.append(data[i])
                i += 1

        assert data[i] == 0xFF
        i += 1

        self.ptype = data[i]
        i += 1

        self.payload = axis_ep.AXIStreamFrame(data[i:])

    def parse_axis_cobs(self, data):
        self.parse_axis(cobs_decode(axis_ep.AXIStreamFrame(data).data))

    def __eq__(self, other):
        if type(other) is XFCPFrame:
            return (self.path == other.path and
                self.rpath == other.rpath and
                self.ptype == other.ptype and
                self.payload == other.payload)
        return False

    def __repr__(self):
        return 'XFCPFrame(payload=%s, path=%s, rpath=%s, ptype=%d)' % (repr(self.payload), repr(self.path), repr(self.rpath), self.ptype)


class XFCPPort(object):
    def __init__(self):
        self.source = axis_ep.AXIStreamSource()
        self.sink = axis_ep.AXIStreamSink()
        self.has_logic = False
        self.clk = None

    def send(self, pkt):
        self.source.send(XFCPFrame(pkt).build_axis())

    def send_raw(self, pkt):
        self.source.send(axis_ep.AXIStreamFrame(pkt))

    def recv(self):
        while not self.sink.empty():
            frame = XFCPFrame()
            pkt = self.sink.recv()
            if pkt.user[-1]:
                return None
            frame.parse_axis(pkt)
            return frame
        return None

    def wait(self, timeout=0):
        yield self.sink.wait(timeout)

    def create_logic(self,
                clk,
                rst,
                xfcp_in_tdata=None,
                xfcp_in_tvalid=Signal(bool(False)),
                xfcp_in_tready=Signal(bool(True)),
                xfcp_in_tlast=Signal(bool(False)),
                xfcp_in_tuser=Signal(bool(False)),
                xfcp_out_tdata=None,
                xfcp_out_tvalid=Signal(bool(False)),
                xfcp_out_tready=Signal(bool(True)),
                xfcp_out_tlast=Signal(bool(False)),
                xfcp_out_tuser=Signal(bool(False)),
                pause_source=0,
                pause_sink=0,
                name=None
            ):

        if self.has_logic:
            raise Exception("Logic already instantiated!")

        self.has_logic = True
        self.clk = clk

        source = self.source.create_logic(
            clk,
            rst,
            tdata=xfcp_out_tdata,
            tvalid=xfcp_out_tvalid,
            tready=xfcp_out_tready,
            tlast=xfcp_out_tlast,
            tuser=xfcp_out_tuser,
            pause=pause_source,
            name=None if name is None else name+"_source"
        )

        sink = self.sink.create_logic(
            clk,
            rst,
            tdata=xfcp_in_tdata,
            tvalid=xfcp_in_tvalid,
            tready=xfcp_in_tready,
            tlast=xfcp_in_tlast,
            tuser=xfcp_in_tuser,
            pause=pause_sink,
            name=None if name is None else name+"_sink"
        )

        return instances()

