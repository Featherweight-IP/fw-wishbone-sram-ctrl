'''
Created on May 11, 2021

@author: mballance
'''

from fw_wishbone_sram_ctrl_tests.test_base import TestBase
import cocotb
from assertpy import *

class SmokeWordRW(TestBase):
    
    async def run(self):
        exp = []
        for i in range(64):
            await self.wb_bfm.write(0x10+4*i, i, 0xF)
            exp.append(i)
            
        for i in range(64):
            data = await self.wb_bfm.read(0x10+4*i)
            assert_that(data).is_equal_to(exp[i])
        pass
    
@cocotb.test()
async def entry(dut):
    t = SmokeWordRW()
    await t.init()
    await t.run()
    