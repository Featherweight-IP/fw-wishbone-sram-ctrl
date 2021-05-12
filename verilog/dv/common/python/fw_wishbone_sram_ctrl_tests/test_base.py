'''
Created on May 11, 2021

@author: mballance
'''
import cocotb
import pybfms
from wishbone_bfms.wb_tag_initiator_bfm import WbTagInitiatorBfm
from generic_sram_bfms.generic_sram_byte_en_target_bfm import GenericSramByteEnTargetBFM

class TestBase(object):
    
    def __init__(self):
        self.wb_bfm = None
        self.sram_bfm = None
        pass
    
    async def init(self):
        print("--> init")
        await pybfms.init()
        self.wb_bfm : WbTagInitiatorBfm = pybfms.find_bfm(".*u_wb_bfm")
        self.sram_Bfm : GenericSramByteEnTargetBFM = pybfms.find_bfm(".u_sram_bfm")
        print("<-- init")
        
    async def run(self):
        print("--> run")
        print("<-- run")
        pass
    
