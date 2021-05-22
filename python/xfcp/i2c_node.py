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

import struct

from . import packet
from . import node


class I2CPacket(packet.Packet):
    def __init__(self, payload=b'', path=(), rpath=(), ptype=0x2C):
        super().__init__(payload, path, rpath, ptype)

    def pack_status_query_req(self):
        self.payload += struct.pack("B", 0x40)

    def unpack_status_query_req(self):
        if len(self.payload) < 1:
            return None
        if self.payload[0] == 0x40:
            self.payload = self.payload[1:]
            return True
        else:
            return None

    def pack_status_query_resp(self, status):
        self.payload += struct.pack("BB", 0x40, status)

    def unpack_status_query_resp(self):
        if len(self.payload) < 2:
            return None
        if self.payload[0] == 0x40:
            status = self.payload[1]
            self.payload = self.payload[2:]
            return status
        else:
            return None

    def pack_set_prescale(self, prescale):
        self.payload += struct.pack("<BH", 0x60, prescale)

    def unpack_set_prescale(self):
        if len(self.payload) < 3:
            return None
        if self.payload[0] == 0x60:
            prescale = struct.unpack_from("<BH", self.payload)[1]
            self.payload = self.payload[3:]
            return prescale
        else:
            return None

    def pack_set_addr(self, addr):
        self.payload += struct.pack('B', 0x80 | addr)

    def unpack_set_addr(self):
        if len(self.payload) < 1:
            return None
        if self.payload[0] & 0x80 == 0x80:
            addr = self.payload[0] & 0x7F
            self.payload = self.payload[1:]
            return addr
        else:
            return None

    def pack_read_req(self, count=1, start=False, stop=False):
        cmd = 0x02
        if start:
            cmd |= 0x01
        if stop:
            cmd |= 0x08
        if count == 1:
            self.payload += struct.pack('B', cmd)
        else:
            self.payload += struct.pack('BB', cmd | 0x10, count)

    def unpack_read_req(self):
        if len(self.payload) < 1:
            return None
        if self.payload[0] & 0x02 == 0x02:
            start = self.payload[0] & 0x01 != 0
            stop = self.payload[0] & 0x08 != 0
            count = 1
            if self.payload[0] & 0x10 == 0x10:
                count = self.payload[1]
                self.payload = self.payload[2:]
            else:
                self.payload = self.payload[1:]
            return (count, start, stop)
        else:
            return None

    def pack_read_resp(self, data, start=False, stop=False):
        cmd = 0x02
        if start:
            cmd |= 0x01
        if stop:
            cmd |= 0x08
        if len(data) == 1:
            self.payload += struct.pack('B', cmd) + data
        else:
            self.payload += struct.pack('BB', cmd | 0x10, len(data)) + data

    def unpack_read_resp(self):
        if len(self.payload) < 2:
            return None
        if self.payload[0] & 0x02 == 0x02:
            start = self.payload[0] & 0x01 != 0
            stop = self.payload[0] & 0x08 != 0
            data = bytearray([self.payload[1]])
            if self.payload[0] & 0x10 == 0x10:
                count = self.payload[1]
                data = self.payload[2:count+2]
                self.payload = self.payload[2+count:]
            else:
                self.payload = self.payload[2:]
            return (data, start, stop)
        else:
            return None

    def pack_write_req(self, data, start=False, stop=False):
        cmd = 0x04
        if start:
            cmd |= 0x01
        if stop:
            cmd |= 0x08
        if len(data) == 1:
            self.payload += struct.pack('B', cmd) + data
        else:
            self.payload += struct.pack('BB', cmd | 0x10, len(data)) + data

    def unpack_write_req(self):
        if len(self.payload) < 2:
            return None
        if self.payload[0] & 0x04 == 0x04:
            start = self.payload[0] & 0x01 != 0
            stop = self.payload[0] & 0x08 != 0
            data = bytearray([self.payload[1]])
            if self.payload[0] & 0x10 == 0x10:
                count = self.payload[1]
                data = self.payload[2:count+2]
                self.payload = self.payload[2+count:]
            else:
                self.payload = self.payload[2:]
            return (data, start, stop)
        else:
            return None

    def pack_write_resp(self, data, start=False, stop=False):
        self.pack_write_req(data, start, stop)

    def unpack_write_resp(self):
        return self.unpack_write_req()


class I2CRequestPacket(I2CPacket):
    def __init__(self, payload=b'', path=(), rpath=(), ptype=0x2C):
        super().__init__(payload, path, rpath, ptype)

    def pack_status_query(self):
        self.pack_status_query_req()

    def unpack_status_query(self):
        return self.unpack_status_query_req()

    def pack_read(self, count=1, start=False, stop=False):
        self.pack_read_req(count, start, stop)

    def unpack_read(self):
        return self.unpack_read_req()

    def pack_write(self, data, start=False, stop=False):
        self.pack_write_req(data, start, stop)

    def unpack_write(self):
        return self.unpack_write_req()

packet.register(I2CRequestPacket, 0x2C)


class I2CResponsePacket(I2CPacket):
    def __init__(self, payload=b'', path=(), rpath=(), ptype=0x2D):
        super().__init__(payload, path, rpath, ptype)

    def pack_status_query(self, status):
        self.pack_status_query_resp(status)

    def unpack_status_query(self):
        return self.unpack_status_query_resp()

    def pack_read(self, data, start=False, stop=False):
        self.pack_read_resp(data, start, stop)

    def unpack_read(self):
        return self.unpack_read_resp()

    def pack_write(self, data, start=False, stop=False):
        self.pack_write_resp(data, start, stop)

    def unpack_write(self):
        return self.unpack_write_resp()

packet.register(I2CResponsePacket, 0x2D)


class I2CNode(node.Node):
    def __init__(self, obj=None):
        super(I2CNode, self).__init__(obj)

    def read_i2c(self, addr, count):
        pkt = I2CRequestPacket()
        pkt.path = self.path
        pkt.pack_set_addr(addr)
        pkt.pack_read(count, stop=True)
        self.interface.send(pkt)
        pkt = self.interface.receive()
        pkt.unpack_set_addr()
        read = pkt.unpack_read()
        return read[0]

    def write_i2c(self, addr, data):
        pkt = I2CRequestPacket()
        pkt.path = self.path
        pkt.pack_set_addr(addr)
        pkt.pack_write(data, stop=True)
        self.interface.send(pkt)
        pkt = self.interface.receive()
        pkt.unpack_set_addr()
        write = pkt.unpack_write()
        return len(write[0])

    def write_read_i2c(self, addr, data, count):
        pkt = I2CRequestPacket()
        pkt.path = self.path
        pkt.pack_set_addr(addr)
        pkt.pack_write(data)
        pkt.pack_read(count, stop=True)
        self.interface.send(pkt)
        pkt = self.interface.receive()
        pkt.unpack_set_addr()
        write = pkt.unpack_write()
        read = pkt.unpack_read()
        return read[0]

    def get_i2c_status(self):
        pkt = I2CRequestPacket()
        pkt.path = self.path
        pkt.pack_status_query()
        self.interface.send(pkt)
        pkt = self.interface.receive()
        return pkt.unpack_status_query()

    def set_i2c_prescale(self, prescale):
        pkt = I2CRequestPacket()
        pkt.path = self.path
        pkt.pack_set_prescale(prescale)
        self.interface.send(pkt)
        pkt = self.interface.receive()
        return pkt.unpack_set_prescale()

node.register(I2CNode, 0x2C00, 8)
