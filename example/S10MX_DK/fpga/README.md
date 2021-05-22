# XFCP Stratix 10 MX Example Design

## Introduction

This example design targets the Intel Stratix 10 MX FPGA development board.

The design by default communicates on UDP port 14000 at IP address
192.168.1.128 via 10 Gbps Ethernet on QSFP0 channel 1.

## How to build

Run make to build.  Ensure that the Intel Quartus Prime Pro toolchain
components are in PATH.

## How to test

Run make program to program the Stratix 10 MX board with Quartus Prime Pro.
Then run test.py or xfcp_ctrl.py with the appropriate interface selected.
