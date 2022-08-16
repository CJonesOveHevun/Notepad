from tkinter import *
from tkinter import ttk
from turtle import back


clipboardtxt = ''

def motion(event):
    x, y = event.x, event.y
    return event

class copypaste:
    def __init__(self, frame:ttk.Frame) -> None:
        self.module = None
        self.frame = Frame(self.module, background='gray17')
        
        self.copy_b = Button(self.frame, text="Copy")
        self.frame.place(x=1,y = 1)
        print(motion)
