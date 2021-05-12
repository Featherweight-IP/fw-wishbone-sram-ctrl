'''
Created on May 11, 2021

@author: mballance
'''
import cocotb
from assertpy import *
from fw_wishbone_sram_ctrl_tests.test_base import TestBase
from fw_wishbone_sram_ctrl_tests.atomic_op import AtomicOp

class TestAmoAdd(TestBase):
    
    async def run(self):
        
        # Initialize memory location with zero
        await self.wb_bfm.write(0x10, 0, 0xF)
        
        # Now, increment by one
        exp = 0
        for i in range(10):
            data = await self.wb_bfm.write_tagged(
                0x10, 
                0, 
                0x1, 
                0, 
                0xF, 
                AtomicOp.ADD)
            assert_that(data[0]).is_equal_to(exp+1)
            exp += 1
    

@cocotb.test()
async def entry(dut):
    t = TestAmoAdd()
    await t.init()
    await t.run()
    
    