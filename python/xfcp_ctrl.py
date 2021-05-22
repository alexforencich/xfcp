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

from __future__ import print_function

import argparse

import xfcp.interface
import xfcp.node


def main():
    #parser = argparse.ArgumentParser(description=__doc__.strip())
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--port', type=str, default='/dev/ttyUSB0', help="Port")
    parser.add_argument('-b', '--baud', type=int, default=115200, help="Baud rate")
    parser.add_argument('-H', '--host', type=str, help="Host (i.e. 192.168.1.128:14000)")
    parser.add_argument('--enum', action='store_true', help="Enumerate modules")
    parser.add_argument('--id', type=str, nargs=1, metavar=('PATH',), action='append', help="Identify module")
    parser.add_argument('--write', type=str, nargs=3, metavar=('PATH', 'ADDR', 'DATA'), action='append', help="Memory write")
    parser.add_argument('--read', type=str, nargs=3, metavar=('PATH', 'ADDR', 'LEN'), action='append', help="Memory read")
    parser.add_argument('--write_i2c', type=str, nargs=3, metavar=('PATH', 'ADDR', 'DATA'), action='append', help="I2C write")
    parser.add_argument('--read_i2c', type=str, nargs=3, metavar=('PATH', 'ADDR', 'LEN'), action='append', help="I2C read")
    parser.add_argument('--enum_i2c', type=str, nargs=1, metavar=('PATH'), action='append', help="I2C enumerate")

    args = parser.parse_args()

    port = args.port
    baud = args.baud
    host = args.host

    intf = None

    if host is not None:
        # Ethernet interface
        intf = xfcp.interface.UDPInterface(host)
    else:
        # serial interface
        intf = xfcp.interface.SerialInterface(port, baud)

    n = intf.enumerate()

    do_enumerate = args.enum

    if do_enumerate:
        do_enumerate = False
        n.print_tree()
    else:
        do_enumerate = True

    if args.id is not None:
        do_enumerate = False
        for item in args.id:
            path = item[0]
            n2 = n.get_by_path(path)
            if n2 is None:
                print("Error: invalid path (%s)" % path)
            else:
                print(' '.join(('{:02x}'.format(x) for x in n2.id_pkt.payload)))

    if args.write is not None:
        do_enumerate = False
        for item in args.write:
            path = item[0]
            n2 = n.get_by_path(path)
            if n2 is None:
                print("Error: invalid path (%s)" % path)
            elif isinstance(n2, xfcp.node.MemoryNode):
                i = n2.write(int(item[1], 0), bytearray.fromhex(item[2]))
                print("Wrote %d bytes to %s addr 0x%x" % (i, '.'.join(str(x) for x in n2.path), int(item[1], 0)))
            else:
                print("Error: not a MemoryNode (%s)" % path)

    if args.read is not None:
        do_enumerate = False
        for item in args.read:
            path = item[0]
            n2 = n.get_by_path(path)
            if n2 is None:
                print("Error: invalid path (%s)" % path)
            elif isinstance(n2, xfcp.node.MemoryNode):
                data = n2.read(int(item[1], 0), int(item[2], 0))
                print(' '.join(('{:02x}'.format(x) for x in data)))
            else:
                print("Error: not a MemoryNode (%s)" % path)

    if args.write_i2c is not None:
        do_enumerate = False
        for item in args.write_i2c:
            path = item[0]
            n2 = n.get_by_path(path)
            if n2 is None:
                print("Error: invalid path (%s)" % path)
            elif isinstance(n2, xfcp.node.I2CNode):
                i = n2.write_i2c(int(item[1], 0), bytearray.fromhex(item[2]))
                print("Wrote %d bytes to %s addr 0x%x" % (i, '.'.join(str(x) for x in n2.path), int(item[1], 0)))
            else:
                print("Error: not a I2CNode (%s)" % path)

    if args.read_i2c is not None:
        do_enumerate = False
        for item in args.read_i2c:
            path = item[0]
            n2 = n.get_by_path(path)
            if n2 is None:
                print("Error: invalid path (%s)" % path)
            elif isinstance(n2, xfcp.node.I2CNode):
                data = n2.read_i2c(int(item[1], 0), int(item[2], 0))
                print(' '.join(('{:02x}'.format(x) for x in data)))
            else:
                print("Error: not a I2CNode (%s)" % path)

    if args.enum_i2c is not None:
        do_enumerate = False
        for item in args.enum_i2c:
            path = item[0]
            n2 = n.get_by_path(path)
            if n2 is None:
                print("Error: invalid path (%s)" % path)
            elif isinstance(n2, xfcp.node.I2CNode):
                s = "%s I2C bus device addresses: " % path
                for k in range(128):
                    n2.read_i2c(k, 1)
                    if n2.get_i2c_status() == 0:
                        s += hex(k) + " "
                print(s)
            else:
                print("Error: not a I2CNode (%s)" % path)

    if do_enumerate:
        n.print_tree()


if __name__ == "__main__":
    main()
