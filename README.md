# Extensible FPGA Control Platform

For more information and updates: http://alexforencich.com/wiki/en/verilog/xfcp/start

GitHub repository: https://github.com/alexforencich/xfcp

## Introduction

The Extensible FPGA control platform (XFCP) is a framework that enables simple interfacing between an FPGA design in verilog and control software.  XFCP uses a source-routed packet switched bus over AXI stream to interconnect components in an FPGA design, eliminating the need to assign and manage addresses, enabling simple bus enumeration, and vastly reducing dependencies between the FPGA design and the control software.  XFCP currently supports operation over serial or UDP.  XFCP includes interface modules for serial and UDP, a parametrizable arbiter to enable simultaneous use of multiple interfaces, a parametrizable switch to connect multiple on-FPGA components, bridges for interfacing with various devices, and a Python framework for enumerating XFCP buses and controlling connected devices.

