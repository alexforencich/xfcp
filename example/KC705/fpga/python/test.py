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

import argparse

import xfcp.interface
import xfcp.node
import xfcp.i2c_node


def main():
    #parser = argparse.ArgumentParser(description=__doc__.strip())
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--port', type=str, default='/dev/ttyUSB0', help="Port")
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

    print("Testing XFCP RAMs")
    n[0].write(0, b'RAM 0 test string!')
    n[1].write(0, b'RAM 1 test string!')
    n[2].write(0, b'RAM 2 test string!')
    print(n[0].read(0, 18))
    print(n[1].read(0, 18))
    print(n[2].read(0, 18))

    n[0].write(0, b'Another RAM 0 test string!')
    print(n[0].read(0, 26))

    n[1].write_dword(16, 0x12345678)

    print(hex(n[1].read_dword(16)))

    # enumerate i2c bus

    print("I2C bus slave addresses:")
    for k in range(128):
        n[3].read_i2c(k, 1)
        if n[3].get_i2c_status() == 0:
            print(hex(k))


if __name__ == "__main__":
    main()
