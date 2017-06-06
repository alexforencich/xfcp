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

import xfcp.node

PRBS_MODE_OFF = 0x0
PRBS_MODE_PRBS7 = 0x1
PRBS_MODE_PRBS9 = 0x2
PRBS_MODE_PRBS15 = 0x3
PRBS_MODE_PRBS23 = 0x4
PRBS_MODE_PRBS31 = 0x5
PRBS_MODE_PCIE = 0x8
PRBS_MODE_SQ_2UI = 0x9
PRBS_MODE_SQ = 0xA

class GTYE3CommonNode(xfcp.node.MemoryNode):
    def __init__(self, obj=None):
        super(GTYE3CommonNode, self).__init__(obj)

xfcp.node.register(GTYE3CommonNode, 0x8A82)


class GTYE3ChannelNode(xfcp.node.MemoryNode):
    def __init__(self, obj=None):
        self.rx_prbs_error_valid = False
        self.rx_prbs_error = False
        super(GTYE3ChannelNode, self).__init__(obj)

    def masked_read(self, addr, mask):
        return self.read_word(addr) & mask

    def masked_write(self, addr, mask, val):
        return self.write_word(addr, (self.read_word(addr) & ~mask) | (val & mask))

    def reset(self):
        self.masked_write(0xff00, 0x0001, 0x0001)

    def tx_reset(self):
        self.masked_write(0xff00, 0x0002, 0x0002)

    def rx_reset(self):
        self.masked_write(0xff00, 0x0004, 0x0004)

    def get_tx_polarity(self):
        return bool(self.masked_read(0xff01, 0x0001))

    def set_tx_polarity(self, val):
        self.masked_write(0xff01, 0x0001, 0x0001 if val else 0x0000)

    def get_rx_polarity(self):
        return bool(self.masked_read(0xff01, 0x0002))

    def set_rx_polarity(self, val):
        self.masked_write(0xff01, 0x0002, 0x0002 if val else 0x0000)

    def get_tx_prbs_mode(self):
        return self.masked_read(0xff02, 0x000f)

    def set_tx_prbs_mode(self, val):
        self.masked_write(0xff02, 0x000f, val)

    def get_rx_prbs_mode(self):
        return self.masked_read(0xff02, 0x00f0) >> 4

    def set_rx_prbs_mode(self, val):
        self.masked_write(0xff02, 0x00f0, val << 4)

    def tx_prbs_force_error(self):
        self.masked_write(0xff03, 0x0001, 0x0001)

    def rx_err_count_reset(self):
        self.masked_write(0xff03, 0x0002, 0x0002)

    def is_rx_prbs_error(self):
        if self.rx_prbs_error_valid:
            self.rx_prbs_error_valid = False
            return self.rx_prbs_error
        else:
            return bool(self.masked_read(0xff03, 0x0004))

    def is_rx_prbs_locked(self):
        w = self.masked_read(0xff03, 0x000c)
        if w & 0x0004:
            self.rx_prbs_error = True
        self.rx_prbs_error_valid = True
        return bool(w & 0x0008)

    def get_rx_prbs_err_count(self):
        return self.read_dword(0x012f)

xfcp.node.register(GTYE3ChannelNode, 0x8A83)

