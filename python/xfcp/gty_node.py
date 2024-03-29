"""

Copyright (c) 2017-2022 Alex Forencich

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

from . import node

PRBS_MODE_OFF = 0x0
PRBS_MODE_PRBS7 = 0x1
PRBS_MODE_PRBS9 = 0x2
PRBS_MODE_PRBS15 = 0x3
PRBS_MODE_PRBS23 = 0x4
PRBS_MODE_PRBS31 = 0x5
PRBS_MODE_PCIE = 0x8
PRBS_MODE_SQ_2UI = 0x9
PRBS_MODE_SQ = 0xA

prbs_mode_mapping = {
    'off': PRBS_MODE_OFF,
    'prbs7': PRBS_MODE_PRBS7,
    'prbs9': PRBS_MODE_PRBS9,
    'prbs15': PRBS_MODE_PRBS15,
    'prbs23': PRBS_MODE_PRBS23,
    'prbs31': PRBS_MODE_PRBS31,
    'pcie': PRBS_MODE_PCIE,
    'sq_2ui': PRBS_MODE_SQ_2UI,
    'sq': PRBS_MODE_SQ
}


class GTHE3CommonNode(node.MemoryNode):
    def masked_read(self, addr, mask):
        return self.read_word(addr) & mask

    def masked_write(self, addr, mask, val):
        return self.write_word(addr, (self.read_word(addr) & ~mask) | (val & mask))

    # common registers
    def get_common_cfg0(self):
        return self.read_word(0x0009*2)

    def set_common_cfg0(self, val):
        self.write_word(0x0009*2, val)

    def get_common_cfg1(self):
        return self.read_word(0x0089*2)

    def set_common_cfg1(self, val):
        self.write_word(0x0089*2, val)

    # QPLL0 registers
    def get_qpll0_cfg0(self):
        return self.read_word(0x0008*2)

    def set_qpll0_cfg0(self, val):
        self.write_word(0x0008*2, val)

    def get_qpll0_cfg1(self):
        return self.read_word(0x0010*2)

    def set_qpll0_cfg1(self, val):
        self.write_word(0x0010*2, val)

    def get_qpll0_cfg2(self):
        return self.read_word(0x0011*2)

    def set_qpll0_cfg2(self, val):
        self.write_word(0x0011*2, val)

    def get_qpll0_cfg3(self):
        return self.read_word(0x0015*2)

    def set_qpll0_cfg3(self, val):
        self.write_word(0x0015*2, val)

    def get_qpll0_cfg4(self):
        return self.read_word(0x0030*2)

    def set_qpll0_cfg4(self, val):
        self.write_word(0x0030*2, val)

    def get_qpll0_lock_cfg(self):
        return self.read_word(0x0012*2)

    def set_qpll0_lock_cfg(self, val):
        self.write_word(0x0012*2, val)

    def get_qpll0_init_cfg0(self):
        return self.read_word(0x0013*2)

    def set_qpll0_init_cfg0(self, val):
        self.write_word(0x0013*2, val)

    def get_qpll0_init_cfg1(self):
        return self.masked_read(0x0014*2, 0xff00) >> 8

    def set_qpll0_init_cfg1(self, val):
        self.masked_write(0x0014*2, 0xff00, val << 8)

    def get_qpll0_fbdiv(self):
        return self.masked_read(0x0014*2, 0x00ff)+2

    def set_qpll0_fbdiv(self, val):
        self.masked_write(0x0014*2, 0x00ff, val-2)

    def get_qpll0_cp(self):
        return self.masked_read(0x0016*2, 0x03ff)

    def set_qpll0_cp(self, val):
        self.masked_write(0x0016*2, 0x03ff, val)

    def get_qpll0_refclk_div(self):
        return self.masked_read(0x0018*2, 0x0780) >> 7

    def set_qpll0_refclk_div(self, val):
        self.masked_write(0x0018*2, 0x00780, val << 7)

    def get_qpll0_lpf(self):
        return self.masked_read(0x0019*2, 0x03ff)

    def set_qpll0_lpf(self, val):
        self.masked_write(0x0019*2, 0x03ff, val)

    def get_qpll0_cfg1_g3(self):
        return self.read_word(0x001a*2)

    def set_qpll0_cfg1_g3(self, val):
        self.write_word(0x001a*2, val)

    def get_qpll0_cfg2_g3(self):
        return self.read_word(0x001b*2)

    def set_qpll0_cfg2_g3(self, val):
        self.write_word(0x001b*2, val)

    def get_qpll0_lpf_g3(self):
        return self.masked_read(0x001c*2, 0x03ff)

    def set_qpll0_lpf_g3(self, val):
        self.masked_write(0x001c*2, 0x03ff, val)

    def get_qpll0_lock_cfg_g3(self):
        return self.read_word(0x001d*2)

    def set_qpll0_lock_cfg_g3(self, val):
        self.write_word(0x001d*2, val)

    def get_qpll0_fbdiv_g3(self):
        return self.masked_read(0x001f*2, 0x00ff)+2

    def set_qpll0_fbdiv_g3(self, val):
        self.masked_write(0x001f*2, 0x00ff, val-2)

    def get_rx_rec_clk_out0_sel(self):
        return self.masked_read(0x001f*2, 0x0003)

    def set_rx_rec_clk_out0_sel(self, val):
        self.masked_write(0x001f*2, 0x0003, val)

    def get_qpll0_sdm_cfg0(self):
        return self.read_word(0x0020*2)

    def set_qpll0_sdm_cfg0(self, val):
        self.write_word(0x0020*2, val)

    def get_qpll0_sdm_cfg1(self):
        return self.read_word(0x0021*2)

    def set_qpll0_sdm_cfg1(self, val):
        self.write_word(0x0021*2, val)

    def get_qpll0_sdm_cfg2(self):
        return self.read_word(0x0024*2)

    def set_qpll0_sdm_cfg2(self, val):
        self.write_word(0x0024*2, val)

    def get_qpll0_cp_g3(self):
        return self.masked_read(0x0025*2, 0x03ff)

    def set_qpll0_cp_g3(self, val):
        self.masked_write(0x0025*2, 0x03ff, val)

    # QPLL1 registers
    def get_qpll1_cfg0(self):
        return self.read_word(0x0088*2)

    def set_qpll1_cfg0(self, val):
        self.write_word(0x0088*2, val)

    def get_qpll1_cfg1(self):
        return self.read_word(0x0090*2)

    def set_qpll1_cfg1(self, val):
        self.write_word(0x0090*2, val)

    def get_qpll1_cfg2(self):
        return self.read_word(0x0091*2)

    def set_qpll1_cfg2(self, val):
        self.write_word(0x0091*2, val)

    def get_qpll1_cfg3(self):
        return self.read_word(0x0095*2)

    def set_qpll1_cfg3(self, val):
        self.write_word(0x0095*2, val)

    def get_qpll1_cfg4(self):
        return self.read_word(0x00b0*2)

    def set_qpll1_cfg4(self, val):
        self.write_word(0x00b0*2, val)

    def get_qpll1_lock_cfg(self):
        return self.read_word(0x0092*2)

    def set_qpll1_lock_cfg(self, val):
        self.write_word(0x0092*2, val)

    def get_qpll1_init_cfg0(self):
        return self.read_word(0x0093*2)

    def set_qpll1_init_cfg0(self, val):
        self.write_word(0x0093*2, val)

    def get_qpll1_init_cfg1(self):
        return self.masked_read(0x0094*2, 0xff00) >> 8

    def set_qpll1_init_cfg1(self, val):
        self.masked_write(0x0094*2, 0xff00, val << 8)

    def get_qpll1_fbdiv(self):
        return self.masked_read(0x0094*2, 0x00ff)+2

    def set_qpll1_fbdiv(self, val):
        self.masked_write(0x0094*2, 0x00ff, val-2)

    def get_qpll1_cp(self):
        return self.masked_read(0x0096*2, 0x03ff)

    def set_qpll1_cp(self, val):
        self.masked_write(0x0096*2, 0x03ff, val)

    def get_qpll1_refclk_div(self):
        return self.masked_read(0x0098*2, 0x0780) >> 7

    def set_qpll1_refclk_div(self, val):
        self.masked_write(0x0098*2, 0x00780, val << 7)

    def get_qpll1_lpf(self):
        return self.masked_read(0x0099*2, 0x03ff)

    def set_qpll1_lpf(self, val):
        self.masked_write(0x0099*2, 0x03ff, val)

    def get_qpll1_cfg1_g3(self):
        return self.read_word(0x009a*2)

    def set_qpll1_cfg1_g3(self, val):
        self.write_word(0x009a*2, val)

    def get_qpll1_cfg2_g3(self):
        return self.read_word(0x009b*2)

    def set_qpll1_cfg2_g3(self, val):
        self.write_word(0x009b*2, val)

    def get_qpll1_lpf_g3(self):
        return self.masked_read(0x009c*2, 0x03ff)

    def set_qpll1_lpf_g3(self, val):
        self.masked_write(0x009c*2, 0x03ff, val)

    def get_qpll1_lock_cfg_g3(self):
        return self.read_word(0x009d*2)

    def set_qpll1_lock_cfg_g3(self, val):
        self.write_word(0x009d*2, val)

    def get_qpll1_fbdiv_g3(self):
        return self.masked_read(0x009f*2, 0x00ff)+2

    def set_qpll1_fbdiv_g3(self, val):
        self.masked_write(0x009f*2, 0x00ff, val-2)

    def get_rx_rec_clk_out1_sel(self):
        return self.masked_read(0x009f*2, 0x0003)

    def set_rx_rec_clk_out1_sel(self, val):
        self.masked_write(0x009f*2, 0x0003, val)

    def get_qpll1_sdm_cfg0(self):
        return self.read_word(0x00a0*2)

    def set_qpll1_sdm_cfg0(self, val):
        self.write_word(0x00a0*2, val)

    def get_qpll1_sdm_cfg1(self):
        return self.read_word(0x00a1*2)

    def set_qpll1_sdm_cfg1(self, val):
        self.write_word(0x00a1*2, val)

    def get_qpll1_sdm_cfg2(self):
        return self.read_word(0x00a4*2)

    def set_qpll1_sdm_cfg2(self, val):
        self.write_word(0x00a4*2, val)

    def get_qpll1_cp_g3(self):
        return self.masked_read(0x00a5*2, 0x03ff)

    def set_qpll1_cp_g3(self, val):
        self.masked_write(0x00a5*2, 0x03ff, val)

node.register(GTHE3CommonNode, 0x8A80)


class GTHE4CommonNode(GTHE3CommonNode):
    # QPLL0 registers
    def get_qpll0_clkout_rate(self):
        return bool(self.masked_read(0x000e*2, 0x0001))

    def set_qpll0_clkout_rate(self, val):
        self.masked_write(0x000e*2, 0x0001, 0x0001 if val else 0x0000)

    # QPLL 1 registers
    def get_qpll1_clkout_rate(self):
        return bool(self.masked_read(0x008e*2, 0x0001))

    def set_qpll1_clkout_rate(self, val):
        self.masked_write(0x008e*2, 0x0001, 0x0001 if val else 0x0000)

node.register(GTHE4CommonNode, 0x8A90)


class GTYE3CommonNode(GTHE3CommonNode):
    # QPLL0 registers
    def get_qpll0_clkout_rate(self):
        return bool(self.masked_read(0x000e*2, 0x0001))

    def set_qpll0_clkout_rate(self, val):
        self.masked_write(0x000e*2, 0x0001, 0x0001 if val else 0x0000)

    def get_qpll0_ips_refclk_sel(self):
        return self.masked_read(0x0018*2, 0x0038) >> 3

    def set_qpll0_ips_refclk_sel(self, val):
        self.masked_write(0x0018*2, 0x00038, val << 3)

    def get_qpll0_ips_en(self):
        return bool(self.masked_read(0x0018*2, 0x0001))

    def set_qpll0_ips_en(self, val):
        self.masked_write(0x0018*2, 0x0001, 0x0001 if val else 0x0000)

    # QPLL 1 registers
    def get_qpll1_clkout_rate(self):
        return bool(self.masked_read(0x008e*2, 0x0001))

    def set_qpll1_clkout_rate(self, val):
        self.masked_write(0x008e*2, 0x0001, 0x0001 if val else 0x0000)

    def get_qpll1_ips_refclk_sel(self):
        return self.masked_read(0x0098*2, 0x0038) >> 3

    def set_qpll1_ips_refclk_sel(self, val):
        self.masked_write(0x0098*2, 0x00038, val << 3)

    def get_qpll1_ips_en(self):
        return bool(self.masked_read(0x0098*2, 0x0040))

    def set_qpll1_ips_en(self, val):
        self.masked_write(0x0098*2, 0x0040, 0x0040 if val else 0x0000)

node.register(GTYE3CommonNode, 0x8A82)


class GTYE4CommonNode(GTYE3CommonNode):
    pass

node.register(GTYE4CommonNode, 0x8A92)


class GTHE3ChannelNode(node.MemoryNode):
    def __init__(self, obj=None):
        self.rx_prbs_error = False
        super().__init__(obj)

    def masked_read(self, addr, mask):
        return self.read_word(addr) & mask

    def masked_write(self, addr, mask, val):
        return self.write_word(addr, (self.read_word(addr) & ~mask) | (val & mask))

    # IO to channel
    def get_reset(self):
        return bool(self.masked_read(0xfe00, 0x0001))

    def set_reset(self, val):
        self.masked_write(0xfe00, 0x0001, 0x0001 if val else 0x0000)

    def reset(self):
        self.set_reset(1)
        self.set_reset(0)

    def get_tx_pcs_reset(self):
        return bool(self.masked_read(0xfe00, 0x0002))

    def set_tx_pcs_reset(self, val):
        self.masked_write(0xfe00, 0x0002, 0x0002 if val else 0x0000)

    def tx_pcs_reset(self):
        self.set_tx_pcs_reset(1)
        self.set_tx_pcs_reset(0)

    def get_tx_pma_reset(self):
        return bool(self.masked_read(0xfe00, 0x0004))

    def set_tx_pma_reset(self, val):
        self.masked_write(0xfe00, 0x0004, 0x0004 if val else 0x0000)

    def tx_pma_reset(self):
        self.set_tx_pma_reset(1)
        self.set_tx_pma_reset(0)

    def get_rx_pcs_reset(self):
        return bool(self.masked_read(0xfe00, 0x0008))

    def set_rx_pcs_reset(self, val):
        self.masked_write(0xfe00, 0x0008, 0x0008 if val else 0x0000)

    def rx_pcs_reset(self):
        self.set_rx_pcs_reset(1)
        self.set_rx_pcs_reset(0)

    def get_rx_pma_reset(self):
        return bool(self.masked_read(0xfe00, 0x0010))

    def set_rx_pma_reset(self, val):
        self.masked_write(0xfe00, 0x0010, 0x0010 if val else 0x0000)

    def rx_pma_reset(self):
        self.set_rx_pma_reset(1)
        self.set_rx_pma_reset(0)

    def get_rx_dfe_lpm_reset(self):
        return bool(self.masked_read(0xfe00, 0x0020))

    def set_rx_dfe_lpm_reset(self, val):
        self.masked_write(0xfe00, 0x0020, 0x0020 if val else 0x0000)

    def rx_dfe_lpm_reset(self):
        self.set_rx_dfe_lpm_reset(1)
        self.set_rx_dfe_lpm_reset(0)

    def get_eyescan_reset(self):
        return bool(self.masked_read(0xfe00, 0x0040))

    def set_eyescan_reset(self, val):
        self.masked_write(0xfe00, 0x0040, 0x0040 if val else 0x0000)

    def eyescan_reset(self):
        self.set_eyescan_reset(1)
        self.set_eyescan_reset(0)

    def get_tx_reset_done(self):
        return bool(self.masked_read(0xfe00, 0x0100))

    def get_tx_pma_reset_done(self):
        return bool(self.masked_read(0xfe00, 0x0200))

    def get_rx_reset_done(self):
        return bool(self.masked_read(0xfe00, 0x0400))

    def get_rx_pma_reset_done(self):
        return bool(self.masked_read(0xfe00, 0x0800))

    def get_tx_polarity(self):
        return bool(self.masked_read(0xfe02, 0x0001))

    def set_tx_polarity(self, val):
        self.masked_write(0xfe02, 0x0001, 0x0001 if val else 0x0000)

    def get_rx_polarity(self):
        return bool(self.masked_read(0xfe02, 0x0002))

    def set_rx_polarity(self, val):
        self.masked_write(0xfe02, 0x0002, 0x0002 if val else 0x0000)

    def get_tx_prbs_mode(self):
        return self.masked_read(0xfe04, 0x000f)

    def set_tx_prbs_mode(self, val):
        if type(val) is str:
            val = prbs_mode_mapping[val]
        self.masked_write(0xfe04, 0x000f, val)

    def get_rx_prbs_mode(self):
        return self.masked_read(0xfe04, 0x00f0) >> 4

    def set_rx_prbs_mode(self, val):
        if type(val) is str:
            val = prbs_mode_mapping[val]
        self.masked_write(0xfe04, 0x00f0, val << 4)

    def tx_prbs_force_error(self):
        self.masked_write(0xfe06, 0x0001, 0x0001)

    def rx_err_count_reset(self):
        self.masked_write(0xfe06, 0x0002, 0x0002)

    def is_rx_prbs_error(self):
        val = self.rx_prbs_error
        self.rx_prbs_error = False
        return val | bool(self.masked_read(0xfe06, 0x0004))

    def is_rx_prbs_locked(self):
        w = self.masked_read(0xfe06, 0x000c)
        self.rx_prbs_error |= bool(w & 0x0004)
        return bool(w & 0x0008)

    def get_tx_elecidle(self):
        return bool(self.masked_read(0xfe08, 0x0001))

    def set_tx_elecidle(self, val):
        self.masked_write(0xfe08, 0x0001, 0x0001 if val else 0x0000)

    def get_tx_inhibit(self):
        return bool(self.masked_read(0xfe08, 0x0002))

    def set_tx_inhibit(self, val):
        self.masked_write(0xfe08, 0x0002, 0x0002 if val else 0x0000)

    def get_tx_diffctrl(self):
        return self.masked_read(0xfe0a, 0x001f)

    def set_tx_diffctrl(self, val):
        self.masked_write(0xfe0a, 0x001f, val)

    def get_tx_maincursor(self):
        return self.masked_read(0xfe0c, 0x007f)

    def set_tx_maincursor(self, val):
        self.masked_write(0xfe0c, 0x007f, val)

    def get_tx_postcursor(self):
        return self.masked_read(0xfe0c, 0x001f)

    def set_tx_postcursor(self, val):
        self.masked_write(0xfe0c, 0x001f, val)

    def get_tx_precursor(self):
        return self.masked_read(0xfe0e, 0x001f)

    def set_tx_precursor(self, val):
        self.masked_write(0xfe0e, 0x001f, val)

    # channel registers

    # RX
    def get_rx_data_width_raw(self):
        return self.masked_read(0x0003*2, 0x01e0) >> 5

    def set_rx_data_width_raw(self, val):
        self.masked_write(0x0003*2, 0x01e0, val << 5)

    def get_rx_data_width(self):
        dw = self.get_rx_data_width_raw()
        return (8*2**(dw >> 1) * (4 + (dw & 1))) >> 2

    def get_rx_int_data_width_raw(self):
        return self.masked_read(0x0066*2, 0x0003)

    def set_rx_int_data_width_raw(self, val):
        self.masked_write(0x0066*2, 0x0003, val)

    def get_rx_int_data_width(self):
        dw = self.get_rx_data_width_raw()
        idw = self.get_rx_int_data_width_raw()
        return (16*2**idw * (4 + (dw & 1))) >> 2

    def get_rx_prbs_err_count(self):
        return self.read_dword(0x015e*2)

    # eye scan
    def get_es_prescale(self):
        return self.masked_read(0x003c*2, 0x001f)

    def set_es_prescale(self, val):
        self.masked_write(0x003c*2, 0x001f, val)

    def get_es_eye_scan_en(self):
        return bool(self.masked_read(0x003c*2, 0x0100))

    def set_es_eye_scan_en(self, val):
        self.masked_write(0x003c*2, 0x0100, 0x0100 if val else 0x0000)

    def get_es_errdet_en(self):
        return bool(self.masked_read(0x003c*2, 0x0200))

    def set_es_errdet_en(self, val):
        self.masked_write(0x003c*2, 0x0200, 0x0200 if val else 0x0000)

    def get_es_control(self):
        return self.masked_read(0x003c*2, 0xfc00) >> 10

    def set_es_control(self, val):
        self.masked_write(0x003c*2, 0xfc00, val << 10)

    def get_es_qualifier(self):
        val  = self.masked_read(0x003f*2, 0xffff) << 16*0
        val |= self.masked_read(0x0040*2, 0xffff) << 16*1
        val |= self.masked_read(0x0041*2, 0xffff) << 16*2
        val |= self.masked_read(0x0042*2, 0xffff) << 16*3
        val |= self.masked_read(0x0043*2, 0xffff) << 16*4
        return val

    def set_es_qualifier(self, val):
        self.masked_write(0x003f*2, 0xffff, (val >> 64*0))
        self.masked_write(0x0040*2, 0xffff, (val >> 48*1))
        self.masked_write(0x0041*2, 0xffff, (val >> 32*2))
        self.masked_write(0x0042*2, 0xffff, (val >> 16*3))
        self.masked_write(0x0043*2, 0xffff, (val >> 16*4))

    def get_es_qual_mask(self):
        val  = self.masked_read(0x0044*2, 0xffff) << 16*0
        val |= self.masked_read(0x0045*2, 0xffff) << 16*1
        val |= self.masked_read(0x0046*2, 0xffff) << 16*2
        val |= self.masked_read(0x0047*2, 0xffff) << 16*3
        val |= self.masked_read(0x0048*2, 0xffff) << 16*4
        return val

    def set_es_qual_mask(self, val):
        self.masked_write(0x0044*2, 0xffff, (val >> 16*0))
        self.masked_write(0x0045*2, 0xffff, (val >> 16*1))
        self.masked_write(0x0046*2, 0xffff, (val >> 16*2))
        self.masked_write(0x0047*2, 0xffff, (val >> 16*3))
        self.masked_write(0x0048*2, 0xffff, (val >> 16*4))

    def get_es_sdata_mask(self):
        val  = self.masked_read(0x0049*2, 0xffff) << 16*0
        val |= self.masked_read(0x004a*2, 0xffff) << 16*1
        val |= self.masked_read(0x004b*2, 0xffff) << 16*2
        val |= self.masked_read(0x004c*2, 0xffff) << 16*3
        val |= self.masked_read(0x004d*2, 0xffff) << 16*4
        return val

    def set_es_sdata_mask(self, val):
        self.masked_write(0x0049*2, 0xffff, (val >> 16*0))
        self.masked_write(0x004a*2, 0xffff, (val >> 16*1))
        self.masked_write(0x004b*2, 0xffff, (val >> 16*2))
        self.masked_write(0x004c*2, 0xffff, (val >> 16*3))
        self.masked_write(0x004d*2, 0xffff, (val >> 16*4))

    def get_es_mask_width(self):
        return 80

    def get_es_horz_offset(self):
        return self.masked_read(0x004f*2, 0xfff0) >> 4

    def set_es_horz_offset(self, val):
        self.masked_write(0x004f*2, 0xfff0, val << 4)

    def get_rx_eyescan_vs_range(self):
        return self.masked_read(0x0097*2, 0x0003)

    def set_rx_eyescan_vs_range(self, val):
        self.masked_write(0x0097*2, 0x0003, val)

    def get_rx_eyescan_vs_code(self):
        return self.masked_read(0x0097*2, 0x01fc) >> 2

    def set_rx_eyescan_vs_code(self, val):
        self.masked_write(0x0097*2, 0x01fc, val << 2)

    def get_rx_eyescan_vs_ut_sign(self):
        return bool(self.masked_read(0x0097*2, 0x0200))

    def set_rx_eyescan_vs_ut_sign(self, val):
        self.masked_write(0x0097*2, 0x0200, 0x0200 if val else 0x0000)

    def get_rx_eyescan_vs_neg_dir(self):
        return bool(self.masked_read(0x0097*2, 0x0400))

    def set_rx_eyescan_vs_neg_dir(self, val):
        self.masked_write(0x0097*2, 0x0400, 0x0400 if val else 0x0000)

    def get_es_error_count(self):
        return self.masked_read(0x0151*2, 0xffff)

    def get_es_sample_count(self):
        return self.masked_read(0x0152*2, 0xffff)

    def get_es_control_status(self):
        return self.masked_read(0x0153*2, 0x000f)

    # TX
    def get_tx_data_width_raw(self):
        return self.masked_read(0x007a*2, 0x000f)

    def set_tx_data_width_raw(self, val):
        self.masked_write(0x007a*2, 0x000f, val)

    def get_tx_data_width(self):
        dw = self.get_tx_data_width_raw()
        return (8*2**(dw >> 1) * (4 + (dw & 1))) >> 2

    def get_tx_int_data_width_raw(self):
        return self.masked_read(0x0085*2, 0x0c00) >> 10

    def set_tx_int_data_width_raw(self, val):
        self.masked_write(0x0085*2, 0x0c00, val << 10)

    def get_tx_int_data_width(self):
        dw = self.get_tx_data_width_raw()
        idw = self.get_tx_int_data_width_raw()
        return (16*2**idw * (4 + (dw & 1))) >> 2

node.register(GTHE3ChannelNode, 0x8A81)


class GTHE4ChannelNode(GTHE3ChannelNode):
    # channel registers
    def get_rx_prbs_err_count(self):
        return self.read_dword(0x025e*2)

    # eye scan
    def get_es_qualifier(self):
        val  = self.masked_read(0x003f*2, 0xffff) << 16*0
        val |= self.masked_read(0x0040*2, 0xffff) << 16*1
        val |= self.masked_read(0x0041*2, 0xffff) << 16*2
        val |= self.masked_read(0x0042*2, 0xffff) << 16*3
        val |= self.masked_read(0x0043*2, 0xffff) << 16*4
        val |= self.masked_read(0x00e7*2, 0xffff) << 16*5
        val |= self.masked_read(0x00e8*2, 0xffff) << 16*6
        val |= self.masked_read(0x00e9*2, 0xffff) << 16*7
        val |= self.masked_read(0x00ea*2, 0xffff) << 16*8
        val |= self.masked_read(0x00eb*2, 0xffff) << 16*9
        return val

    def set_es_qualifier(self, val):
        self.masked_write(0x003f*2, 0xffff, (val >> 16*0))
        self.masked_write(0x0040*2, 0xffff, (val >> 16*1))
        self.masked_write(0x0041*2, 0xffff, (val >> 16*2))
        self.masked_write(0x0042*2, 0xffff, (val >> 16*3))
        self.masked_write(0x0043*2, 0xffff, (val >> 16*4))
        self.masked_write(0x00e7*2, 0xffff, (val >> 16*5))
        self.masked_write(0x00e8*2, 0xffff, (val >> 16*6))
        self.masked_write(0x00e9*2, 0xffff, (val >> 16*7))
        self.masked_write(0x00ea*2, 0xffff, (val >> 16*8))
        self.masked_write(0x00eb*2, 0xffff, (val >> 16*9))

    def get_es_qual_mask(self):
        val  = self.masked_read(0x0044*2, 0xffff) << 16*0
        val |= self.masked_read(0x0045*2, 0xffff) << 16*1
        val |= self.masked_read(0x0046*2, 0xffff) << 16*2
        val |= self.masked_read(0x0047*2, 0xffff) << 16*3
        val |= self.masked_read(0x0048*2, 0xffff) << 16*4
        val |= self.masked_read(0x00ec*2, 0xffff) << 16*5
        val |= self.masked_read(0x00ed*2, 0xffff) << 16*6
        val |= self.masked_read(0x00ee*2, 0xffff) << 16*7
        val |= self.masked_read(0x00ef*2, 0xffff) << 16*8
        val |= self.masked_read(0x00f0*2, 0xffff) << 16*9
        return val

    def set_es_qual_mask(self, val):
        self.masked_write(0x0044*2, 0xffff, (val >> 16*0))
        self.masked_write(0x0045*2, 0xffff, (val >> 16*1))
        self.masked_write(0x0046*2, 0xffff, (val >> 16*2))
        self.masked_write(0x0047*2, 0xffff, (val >> 16*3))
        self.masked_write(0x0048*2, 0xffff, (val >> 16*4))
        self.masked_write(0x00ec*2, 0xffff, (val >> 16*5))
        self.masked_write(0x00ed*2, 0xffff, (val >> 16*6))
        self.masked_write(0x00ee*2, 0xffff, (val >> 16*7))
        self.masked_write(0x00ef*2, 0xffff, (val >> 16*8))
        self.masked_write(0x00f0*2, 0xffff, (val >> 16*9))

    def get_es_sdata_mask(self):
        val  = self.masked_read(0x0049*2, 0xffff) << 16*0
        val |= self.masked_read(0x004a*2, 0xffff) << 16*1
        val |= self.masked_read(0x004b*2, 0xffff) << 16*2
        val |= self.masked_read(0x004c*2, 0xffff) << 16*3
        val |= self.masked_read(0x004d*2, 0xffff) << 16*4
        val |= self.masked_read(0x00f1*2, 0xffff) << 16*5
        val |= self.masked_read(0x00f2*2, 0xffff) << 16*6
        val |= self.masked_read(0x00f3*2, 0xffff) << 16*7
        val |= self.masked_read(0x00f4*2, 0xffff) << 16*8
        val |= self.masked_read(0x00f5*2, 0xffff) << 16*9
        return val

    def set_es_sdata_mask(self, val):
        self.masked_write(0x0049*2, 0xffff, (val >> 16*0))
        self.masked_write(0x004a*2, 0xffff, (val >> 16*1))
        self.masked_write(0x004b*2, 0xffff, (val >> 16*2))
        self.masked_write(0x004c*2, 0xffff, (val >> 16*3))
        self.masked_write(0x004d*2, 0xffff, (val >> 16*4))
        self.masked_write(0x00f1*2, 0xffff, (val >> 16*5))
        self.masked_write(0x00f2*2, 0xffff, (val >> 16*6))
        self.masked_write(0x00f3*2, 0xffff, (val >> 16*7))
        self.masked_write(0x00f4*2, 0xffff, (val >> 16*8))
        self.masked_write(0x00f5*2, 0xffff, (val >> 16*9))

    def get_es_mask_width(self):
        return 160

    def get_es_error_count(self):
        return self.masked_read(0x0251*2, 0xffff)

    def get_es_sample_count(self):
        return self.masked_read(0x0252*2, 0xffff)

    def get_es_control_status(self):
        return self.masked_read(0x0253*2, 0x000f)

node.register(GTHE4ChannelNode, 0x8A91)


class GTYE3ChannelNode(GTHE3ChannelNode):
    # channel registers
    def get_rx_prbs_err_count(self):
        return self.read_dword(0x025e*2)

    # eye scan
    def get_es_qualifier(self):
        val  = self.masked_read(0x003f*2, 0xffff) << 16*0
        val |= self.masked_read(0x0040*2, 0xffff) << 16*1
        val |= self.masked_read(0x0041*2, 0xffff) << 16*2
        val |= self.masked_read(0x0042*2, 0xffff) << 16*3
        val |= self.masked_read(0x0043*2, 0xffff) << 16*4
        val |= self.masked_read(0x00e7*2, 0xffff) << 16*5
        val |= self.masked_read(0x00e8*2, 0xffff) << 16*6
        val |= self.masked_read(0x00e9*2, 0xffff) << 16*7
        val |= self.masked_read(0x00ea*2, 0xffff) << 16*8
        val |= self.masked_read(0x00eb*2, 0xffff) << 16*9
        return val

    def set_es_qualifier(self, val):
        self.masked_write(0x003f*2, 0xffff, (val >> 16*0))
        self.masked_write(0x0040*2, 0xffff, (val >> 16*1))
        self.masked_write(0x0041*2, 0xffff, (val >> 16*2))
        self.masked_write(0x0042*2, 0xffff, (val >> 16*3))
        self.masked_write(0x0043*2, 0xffff, (val >> 16*4))
        self.masked_write(0x00e7*2, 0xffff, (val >> 16*5))
        self.masked_write(0x00e8*2, 0xffff, (val >> 16*6))
        self.masked_write(0x00e9*2, 0xffff, (val >> 16*7))
        self.masked_write(0x00ea*2, 0xffff, (val >> 16*8))
        self.masked_write(0x00eb*2, 0xffff, (val >> 16*9))

    def get_es_qual_mask(self):
        val  = self.masked_read(0x0044*2, 0xffff) << 16*0
        val |= self.masked_read(0x0045*2, 0xffff) << 16*1
        val |= self.masked_read(0x0046*2, 0xffff) << 16*2
        val |= self.masked_read(0x0047*2, 0xffff) << 16*3
        val |= self.masked_read(0x0048*2, 0xffff) << 16*4
        val |= self.masked_read(0x00ec*2, 0xffff) << 16*5
        val |= self.masked_read(0x00ed*2, 0xffff) << 16*6
        val |= self.masked_read(0x00ee*2, 0xffff) << 16*7
        val |= self.masked_read(0x00ef*2, 0xffff) << 16*8
        val |= self.masked_read(0x00f0*2, 0xffff) << 16*9
        return val

    def set_es_qual_mask(self, val):
        self.masked_write(0x0044*2, 0xffff, (val >> 16*0))
        self.masked_write(0x0045*2, 0xffff, (val >> 16*1))
        self.masked_write(0x0046*2, 0xffff, (val >> 16*2))
        self.masked_write(0x0047*2, 0xffff, (val >> 16*3))
        self.masked_write(0x0048*2, 0xffff, (val >> 16*4))
        self.masked_write(0x00ec*2, 0xffff, (val >> 16*5))
        self.masked_write(0x00ed*2, 0xffff, (val >> 16*6))
        self.masked_write(0x00ee*2, 0xffff, (val >> 16*7))
        self.masked_write(0x00ef*2, 0xffff, (val >> 16*8))
        self.masked_write(0x00f0*2, 0xffff, (val >> 16*9))

    def get_es_sdata_mask(self):
        val  = self.masked_read(0x0049*2, 0xffff) << 16*0
        val |= self.masked_read(0x004a*2, 0xffff) << 16*1
        val |= self.masked_read(0x004b*2, 0xffff) << 16*2
        val |= self.masked_read(0x004c*2, 0xffff) << 16*3
        val |= self.masked_read(0x004d*2, 0xffff) << 16*4
        val |= self.masked_read(0x00f1*2, 0xffff) << 16*5
        val |= self.masked_read(0x00f2*2, 0xffff) << 16*6
        val |= self.masked_read(0x00f3*2, 0xffff) << 16*7
        val |= self.masked_read(0x00f4*2, 0xffff) << 16*8
        val |= self.masked_read(0x00f5*2, 0xffff) << 16*9
        return val

    def set_es_sdata_mask(self, val):
        self.masked_write(0x0049*2, 0xffff, (val >> 16*0))
        self.masked_write(0x004a*2, 0xffff, (val >> 16*1))
        self.masked_write(0x004b*2, 0xffff, (val >> 16*2))
        self.masked_write(0x004c*2, 0xffff, (val >> 16*3))
        self.masked_write(0x004d*2, 0xffff, (val >> 16*4))
        self.masked_write(0x00f1*2, 0xffff, (val >> 16*5))
        self.masked_write(0x00f2*2, 0xffff, (val >> 16*6))
        self.masked_write(0x00f3*2, 0xffff, (val >> 16*7))
        self.masked_write(0x00f4*2, 0xffff, (val >> 16*8))
        self.masked_write(0x00f5*2, 0xffff, (val >> 16*9))

    def get_es_mask_width(self):
        return 160

    def get_es_error_count(self):
        return self.masked_read(0x0251*2, 0xffff)

    def get_es_sample_count(self):
        return self.masked_read(0x0252*2, 0xffff)

    def get_es_control_status(self):
        return self.masked_read(0x0253*2, 0x000f)

node.register(GTYE3ChannelNode, 0x8A83)


class GTYE4ChannelNode(GTYE3ChannelNode):
    pass

node.register(GTYE4ChannelNode, 0x8A93)
