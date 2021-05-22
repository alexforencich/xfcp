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

packet_types = {}


def register(cls, ptype):
    if ptype in packet_types:
        raise Exception("ptype already registered")
    assert issubclass(cls, Packet)
    packet_types[ptype] = cls


def parse(data):
    pkt = Packet()
    pkt.parse(data)

    if pkt.ptype in packet_types:
        return packet_types[pkt.ptype](pkt)

    return pkt


class Packet(object):
    def __init__(self, payload=b'', path=(), rpath=(), ptype=0):
        self.payload = payload
        self.path = path
        self.rpath = rpath
        self.ptype = ptype

        if isinstance(payload, Packet):
            self.payload = bytes(payload.payload)
            self.path = tuple(payload.path)
            self.rpath = tuple(payload.rpath)
            self.ptype = payload.ptype

    def build(self):
        data = bytearray()

        for p in self.path:
            data.append(p)

        if len(self.rpath) > 0:
            data.append(0xFE)
            for p in self.rpath:
                data.append(p)

        data.append(0xFF)
        data.append(self.ptype)

        data.extend(self.payload)

        return bytes(data)

    def parse(self, data):
        i = 0

        data = bytearray(data)

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

        self.payload = bytes(data[i:])

    def __eq__(self, other):
        if isinstance(other, Packet):
            return (self.path == other.path and
                self.rpath == other.rpath and
                self.ptype == other.ptype and
                self.payload == other.payload)
        return False

    def __repr__(self):
        return (
            f"{type(self).__name__}(payload={self.payload}, "
            f"path={self.path}, "
            f"rpath={self.rpath}, "
            f"ptype={self.ptype:#x})"
        )


class IDRequestPacket(Packet):
    def __init__(self, payload=b'', path=(), rpath=(), ptype=0xfe):
        super().__init__(payload, path, rpath, ptype)

register(IDRequestPacket, 0xfe)


class IDResponsePacket(Packet):
    def __init__(self, payload=b'', path=(), rpath=(), ptype=0xff):
        super().__init__(payload, path, rpath, ptype)

register(IDResponsePacket, 0xff)


class MemoryAccessPacket(Packet):
    def __init__(self, payload=b'', path=(), rpath=(), ptype=0):
        super().__init__(payload, path, rpath, ptype)

        self.addr = 0
        self.count = 0
        self.data = b''
        self.addr_width = 32
        self.count_width = 16

        if isinstance(payload, MemoryAccessPacket):
            self.addr = payload.addr
            self.count = payload.count
            self.data = payload.data
            self.addr_width = payload.addr_width
            self.count_width = payload.count_width

    def build(self):
        aw = (self.addr_width+7)//8
        cw = (self.count_width+7)//8
        self.payload = self.addr.to_bytes(aw, 'little')
        self.payload += self.count.to_bytes(cw, 'little')
        self.payload += self.data

        return super().build()

    def parse(self, data=None):
        if data is not None:
            super().parse(data)

        aw = (self.addr_width+7)//8
        cw = (self.count_width+7)//8
        self.addr = int.from_bytes(self.payload[0:aw], 'little')
        self.count = int.from_bytes(self.payload[aw:aw+cw], 'little')
        self.data = self.payload[aw+cw:]

    def __repr__(self):
        return (
            f"{type(self).__name__}(payload={self.payload}, "
            f"path={self.path}, "
            f"rpath={self.rpath}, "
            f"ptype={self.ptype:#x}, "
            f"addr={self.addr:#x}, "
            f"count={self.count}, "
            f"data={self.data}, "
            f"addr_width={self.addr_width}, "
            f"count_width={self.count_width})"
        )


class ReadRequestPacket(MemoryAccessPacket):
    def __init__(self, payload=b'', path=(), rpath=(), ptype=0x10):
        super().__init__(payload, path, rpath, ptype)

register(ReadRequestPacket, 0x10)


class ReadResponsePacket(MemoryAccessPacket):
    def __init__(self, payload=b'', path=(), rpath=(), ptype=0x11):
        super().__init__(payload, path, rpath, ptype)

register(ReadResponsePacket, 0x11)


class WriteRequestPacket(MemoryAccessPacket):
    def __init__(self, payload=b'', path=(), rpath=(), ptype=0x12):
        super().__init__(payload, path, rpath, ptype)

    def build(self):
        self.count = len(self.data)
        return super().build()

register(WriteRequestPacket, 0x12)


class WriteResponsePacket(MemoryAccessPacket):
    def __init__(self, payload=b'', path=(), rpath=(), ptype=0x13):
        super().__init__(payload, path, rpath, ptype)

register(WriteResponsePacket, 0x13)


class I2CPacket(Packet):
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

register(I2CRequestPacket, 0x2C)


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

register(I2CResponsePacket, 0x2D)
