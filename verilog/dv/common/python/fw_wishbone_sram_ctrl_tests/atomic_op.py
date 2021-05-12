'''
Created on May 11, 2021

@author: mballance
'''
from enum import IntEnum, auto


class AtomicOp(IntEnum):
    NOP = 0
    SWAP = auto()
    ADD = auto()
    AND = auto()
    OR = auto()
    XOR = auto()
    MAXS = auto()
    MAXU = auto()
    MINS = auto()
    MINU = auto()
    
    
    