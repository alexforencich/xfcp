# Copyright (c) 2019 Alex Forencich
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# XFCP GTY module timing constraints

foreach inst [get_cells -hier -filter {(ORIG_REF_NAME == xfcp_mod_gty || REF_NAME == xfcp_mod_gty)}] {
    puts "Inserting timing constraints for xfcp_mod_gty instance $inst"

    # reset synchronization
    set reset_ffs [get_cells -quiet -hier -regexp ".*/gty_(tx|rx)_reset_sync_\[12\]_reg_reg" -filter "PARENT == $inst"]

    if {[llength $reset_ffs]} {
        set_property ASYNC_REG TRUE $reset_ffs
        set_false_path -to [get_pins -of_objects $reset_ffs -filter {IS_PRESET || IS_RESET}]
    }

    # TX

    set sync_ffs [get_cells -hier -regexp ".*/gty_txprbsforceerr_(sync_\[12\])?_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_txprbsforceerr_reg_reg/C]]

        set_max_delay -from [get_cells $inst/gty_txprbsforceerr_reg_reg] -to [get_cells $inst/gty_txprbsforceerr_sync_1_reg_reg] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_txprbssel_(sync)?_reg_reg\\\[\\d+\\\]" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_txprbssel_reg_reg[*]/C]]

        set_max_delay -from [get_cells $inst/gty_txprbssel_reg_reg[*]] -to [get_cells $inst/gty_txprbssel_sync_reg_reg[*]] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_txpolarity_(sync)?_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_txpolarity_reg_reg/C]]

        set_max_delay -from [get_cells $inst/gty_txpolarity_reg_reg] -to [get_cells $inst/gty_txpolarity_sync_reg_reg] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_txelecidle_(sync)?_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_txelecidle_reg_reg/C]]

        set_max_delay -from [get_cells $inst/gty_txelecidle_reg_reg] -to [get_cells $inst/gty_txelecidle_sync_reg_reg] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_txinhibit_(sync)?_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_txinhibit_reg_reg/C]]

        set_max_delay -from [get_cells $inst/gty_txinhibit_reg_reg] -to [get_cells $inst/gty_txinhibit_sync_reg_reg] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_txdiffctrl_(sync)?_reg_reg\\\[\\d+\\\]" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_txdiffctrl_reg_reg[*]/C]]

        set_max_delay -from [get_cells $inst/gty_txdiffctrl_reg_reg[*]] -to [get_cells $inst/gty_txdiffctrl_sync_reg_reg[*]] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_txmaincursor_(sync)?_reg_reg\\\[\\d+\\\]" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_txmaincursor_reg_reg[*]/C]]

        set_max_delay -from [get_cells $inst/gty_txmaincursor_reg_reg[*]] -to [get_cells $inst/gty_txmaincursor_sync_reg_reg[*]] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_txpostcursor_(sync)?_reg_reg\\\[\\d+\\\]" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_txpostcursor_reg_reg[*]/C]]

        set_max_delay -from [get_cells $inst/gty_txpostcursor_reg_reg[*]] -to [get_cells $inst/gty_txpostcursor_sync_reg_reg[*]] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_txprecursor_(sync)?_reg_reg\\\[\\d+\\\]" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_txprecursor_reg_reg[*]/C]]

        set_max_delay -from [get_cells $inst/gty_txprecursor_reg_reg[*]] -to [get_cells $inst/gty_txprecursor_sync_reg_reg[*]] -datapath_only [get_property -min PERIOD $src_clk]
    }

    # RX

    set sync_ffs [get_cells -hier -regexp ".*/gty_rxpolarity_(sync)?_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_rxpolarity_reg_reg/C]]

        set_max_delay -from [get_cells $inst/gty_rxpolarity_reg_reg] -to [get_cells $inst/gty_rxpolarity_sync_reg_reg] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_rxprbscntreset_(sync_\[12\])?_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_rxprbscntreset_reg_reg/C]]

        set_max_delay -from [get_cells $inst/gty_rxprbscntreset_reg_reg] -to [get_cells $inst/gty_rxprbscntreset_sync_1_reg_reg] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_rxprbssel_(sync)?_reg_reg\\\[\\d+\\\]" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_rxprbssel_reg_reg[*]/C]]

        set_max_delay -from [get_cells $inst/gty_rxprbssel_reg_reg[*]] -to [get_cells $inst/gty_rxprbssel_sync_reg_reg[*]] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_rxprbserr_sync_\[123\]_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_rxprbserr_sync_1_reg_reg/C]]

        set_max_delay -from [get_cells $inst/gty_rxprbserr_sync_1_reg_reg] -to [get_cells $inst/gty_rxprbserr_sync_2_reg_reg] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_rxprbserr_sync_\[345\]_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_rxprbserr_sync_3_reg_reg/C]]

        set_max_delay -from [get_cells $inst/gty_rxprbserr_sync_3_reg_reg] -to [get_cells $inst/gty_rxprbserr_sync_4_reg_reg] -datapath_only [get_property -min PERIOD $src_clk]
    }

    set sync_ffs [get_cells -hier -regexp ".*/gty_rxprbslocked_(sync_\[12\])?_reg_reg" -filter "PARENT == $inst"]

    if {[llength $sync_ffs]} {
        set_property ASYNC_REG TRUE $sync_ffs

        set src_clk [get_clocks -of_objects [get_pins $inst/gty_rxprbslocked_reg_reg/C]]

        set_max_delay -from [get_cells $inst/gty_rxprbslocked_reg_reg] -to [get_cells $inst/gty_rxprbslocked_sync_1_reg_reg] -datapath_only [get_property -min PERIOD $src_clk]
    }
}
