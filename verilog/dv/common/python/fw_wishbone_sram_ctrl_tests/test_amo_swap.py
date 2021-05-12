'''
Created on May 11, 2021

@author: mballance
'''
import cocotb
from assertpy import *
from fw_wishbone_sram_ctrl_tests.test_base import TestBase
from fw_wishbone_sram_ctrl_tests.atomic_op import AtomicOp

class TestAmoSwap(TestBase):
    
    async def run(self):
        
        # Initialize memory location with zero
        await self.wb_bfm.write(0x10, 0, 0xF)
        
        for i in range(10):
            data = await self.wb_bfm.write_tagged(
                0x10, 
                0, 
                (i+1), 
                0, 
                0xF, 
                AtomicOp.SWAP)
            assert_that(data[0]).is_equal_to(i)
    

@cocotb.test()
async def entry(dut):
    t = TestAmoSwap()
    await t.init()
    await t.run()
    
    