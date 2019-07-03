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

import math
import struct

from . import packet

node_types = []


def register(cls, ntype, prefix=16):
    prefix = min(max(int(prefix), 1), 16)
    ntype = ntype & (0xffff0000 >> prefix)
    if any(ntype == nt[1] and prefix == nt[2] for nt in node_types):
        raise Exception("ntype with same prefix already registered")
    assert issubclass(cls, Node)
    node_types.append((cls, ntype, prefix))


def enumerate_interface(interface, path=(), parent=None):
    node = Node()
    node.interface = interface
    node.path = path
    node.parent = parent
    node.init()

    match_cls = None
    match_prefix = 0

    for nt in node_types:
        if node.ntype & (0xffff0000 >> nt[2]) == nt[1] and nt[2] > match_prefix:
            match_cls = nt[0]
            match_prefix = nt[2]

    if match_cls is not None:
        return match_cls(node).init()

    return node


class Node(object):
    def __init__(self, obj=None):
        self.interface = None
        self.path = ()
        self.ntype = 0
        self.name = ''
        self.ext_str = ''
        self.parent = None
        self.children = []
        self.id_pkt = None

        if isinstance(obj, Node):
            self.interface = obj.interface
            self.path = obj.path
            self.ntype = obj.ntype
            self.name = obj.name
            self.ext_str = obj.ext_str
            self.parent = obj.parent
            self.children = obj.children
            self.id_pkt = obj.id_pkt

    def init(self, id_pkt=None):
        if id_pkt is not None:
            self.id_pkt = id_pkt

        if self.id_pkt is None:
            self.interface.send(packet.IDRequestPacket(path=self.path))
            self.id_pkt = self.interface.receive()

        self.ntype = struct.unpack_from('<H', self.id_pkt.payload, 0)[0]
        self.name = struct.unpack_from('16s', self.id_pkt.payload, 16)[0].rstrip(b'\0').decode('utf-8')

        if len(self.id_pkt.payload) > 32:
            self.ext_str = struct.unpack_from('16s', self.id_pkt.payload, 48)[0].rstrip(b'\0').decode('utf-8')

        return self

    def get_by_path(self, path):
        if type(path) is str:
            if len(path.strip()) == 0:
                path = []
            else:
                path = [int(x) for x in path.split('.')]

        n = self

        for part in path:
            if part < len(n):
                n = n[part]
            else:
                return None

        return n

    def find_by_type(self, t, prefix=16):
        l = []

        for n in self.children:
            if type(t) is int:
                if t & (0xffff0000 >> prefix) == n.ntype & (0xffff0000 >> prefix):
                    l.append(n)
            else:
                if isinstance(n, t):
                    l.append(n)

            l.extend(n.find_by_type(t, prefix))

        return l

    def __repr__(self):
        return '%s(interface=%s, path=%s, ntype=%d, name="%s", ext_str="%s", children=%s)' % (type(self).__name__, repr(self.interface), repr(self.path), self.ntype, self.name, self.ext_str, repr(self.children))

    def __getitem__(self, key):
        if type(key) is slice:
            return self.children[key]
        return self.children[key]

    def __iter__(self):
        return self.children.__iter__()
    
    def __len__(self):
        return len(self.children)
        
    def count(self):
        return len(self.children)


class SwitchNode(Node):
    def __init__(self, obj=None):
        super(SwitchNode, self).__init__(obj)

        self.up_ports = 0
        self.down_ports = 0

        if isinstance(obj, SwitchNode):
            self.up_ports = obj.up_ports
            self.down_ports = obj.down_ports

    def init(self, id_pkt=None):
        super(SwitchNode, self).init(id_pkt)

        self.up_ports, self.down_ports = struct.unpack_from('BB', self.id_pkt.payload, 2)

        for p in range(self.down_ports):
            self.children.append(enumerate_interface(self.interface, self.path+(p,), self))

        return self

register(SwitchNode, 0x0100, 8)


class MemoryNode(Node):
    def __init__(self, obj=None):
        super(MemoryNode, self).__init__(obj)

        self.addr_width = 32
        self.data_width = 32
        self.word_size = 8
        self.count_width = 16

        if isinstance(obj, MemoryNode):
            self.addr_width = obj.addr_width
            self.data_width = obj.data_width
            self.word_size = obj.word_size
            self.count_width = obj.count_width

        self.byte_addr_width = int(self.addr_width+math.ceil(math.log(self.word_size/8, 2)))

    def init(self, id_pkt=None):
        super(MemoryNode, self).init(id_pkt)

        self.addr_width, self.data_width, self.word_size, self.count_width = struct.unpack_from('<HHHH', self.id_pkt.payload, 2)
        self.byte_addr_width = int(self.addr_width+math.ceil(math.log(self.word_size/8, 2)))

        return self

    def read(self, addr, count):
        pkt = packet.ReadRequestPacket()
        pkt.path = self.path
        pkt.addr = addr
        pkt.data = b''
        pkt.count = count
        pkt.addr_width = self.byte_addr_width
        pkt.count_width = self.count_width
        self.interface.send(pkt)
        pkt = self.interface.receive()
        pkt.addr_width = self.byte_addr_width
        pkt.count_width = self.count_width
        pkt.parse()
        return pkt.data

    def read_words(self, addr, count, ws=2):
        data = self.read(addr*ws, count*ws)
        words = []
        for k in range(count):
            words.append(int.from_bytes(data[ws*k:ws*(k+1)], 'little'))
        return words

    def read_dwords(self, addr, count):
        return self.read_words(addr, count, 4)

    def read_qwords(self, addr, count):
        return self.read_words(addr, count, 8)

    def read_byte(self, addr):
        return self.read(addr, 1)[0]

    def read_word(self, addr):
        return self.read_words(addr, 1)[0]

    def read_dword(self, addr):
        return self.read_dwords(addr, 1)[0]

    def read_qword(self, addr):
        return self.read_qwords(addr, 1)[0]

    def write(self, addr, data):
        pkt = packet.WriteRequestPacket()
        pkt.path = self.path
        pkt.addr = addr
        pkt.data = data
        pkt.count = len(data)
        pkt.addr_width = self.byte_addr_width
        pkt.count_width = self.count_width
        self.interface.send(pkt)
        pkt = self.interface.receive()
        pkt.addr_width = self.byte_addr_width
        pkt.count_width = self.count_width
        pkt.parse()
        return pkt.count

    def write_words(self, addr, data, ws=2):
        words = data
        data = b''
        for w in words:
            data += w.to_bytes(ws, 'little')
        return int(self.write(addr*ws, data)/ws)

    def write_dwords(self, addr, data):
        return self.write_words(addr, data, 4)

    def write_qwords(self, addr, data):
        return self.write_words(addr, data, 8)

    def write_byte(self, addr, data):
        return self.write(addr, [data])

    def write_word(self, addr, data):
        return self.write_words(addr, [data])

    def write_dword(self, addr, data):
        return self.write_dwords(addr, [data])

    def write_qword(self, addr, data):
        return self.write_qwords(addr, [data])

register(MemoryNode, 0x8000, 1)


class I2CNode(Node):
    def __init__(self, obj=None):
        super(I2CNode, self).__init__(obj)

    def read_i2c(self, addr, count):
        pkt = packet.I2CRequestPacket()
        pkt.path = self.path
        pkt.pack_set_addr(addr)
        pkt.pack_read(count, stop=True)
        self.interface.send(pkt)
        pkt = self.interface.receive()
        pkt.unpack_set_addr()
        read = pkt.unpack_read()
        return read[0]

    def write_i2c(self, addr, data):
        pkt = packet.I2CRequestPacket()
        pkt.path = self.path
        pkt.pack_set_addr(addr)
        pkt.pack_write(data, stop=True)
        self.interface.send(pkt)
        pkt = self.interface.receive()
        pkt.unpack_set_addr()
        write = pkt.unpack_write()
        return len(write[0])

    def write_read_i2c(self, addr, data, count):
        pkt = packet.I2CRequestPacket()
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
        pkt = packet.I2CRequestPacket()
        pkt.path = self.path
        pkt.pack_status_query()
        self.interface.send(pkt)
        pkt = self.interface.receive()
        return pkt.unpack_status_query()

    def set_i2c_prescale(self, prescale):
        pkt = packet.I2CRequestPacket()
        pkt.path = self.path
        pkt.pack_set_prescale(prescale)
        self.interface.send(pkt)
        pkt = self.interface.receive()
        return pkt.unpack_set_prescale()

register(I2CNode, 0x2C00, 8)

