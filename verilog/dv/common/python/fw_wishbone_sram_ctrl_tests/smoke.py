'''
Created on May 11, 2021

@author: mballance
'''

import cocotb
from fw_wishbone_sram_ctrl_tests.test_base import TestBase

@cocotb.test()
async def entry(dut):
    print("Hello")
    
    test = TestBase()
    await test.init()
    await test.run()
    