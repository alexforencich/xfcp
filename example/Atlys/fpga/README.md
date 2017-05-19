# XFCP Atlys Example Design

## Introduction

This example design targets the Digilent Atlys FPGA board.

The design by default listens on the serial port and on UDP port 14000 at IP address 192.168.1.128.

## How to build

Run make to build.  Ensure that the Xilinx ISE toolchain components are
in PATH.  

## How to test

Run make program to program the Atlys board with the Digilent command line
tools.  Then run test.py or xfcp_ctrl.py with the appropriate interface
selected.


