# XFCP Arty Example Design

## Introduction

This example design targets the Digilent Arty FPGA board.

The design by default listens on the serial port and on UDP port 14000 at IP address 192.168.1.128.

## How to build

Run make to build.  Ensure that the Xilinx Vivado toolchain components are
in PATH.  

## How to test

Run make program to program the Arty board with Vivado.  Then run test.py or
xfcp_ctrl.py with the appropriate interface selected.


