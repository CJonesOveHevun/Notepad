from asyncio.windows_events import NULL
from cgitb import text
from distutils.cmd import Command
from fileinput import close
from html.entities import name2codepoint
from msilib.schema import tables
from operator import index
from os import waitstatus_to_exitcode
from textwrap import fill, wrap
from tkinter import *
from tkinter import ttk
from tkinter import font
from tkinter.filedialog import askopenfilename, asksaveasfile
from tkinter.tix import NoteBook
from tokenize import Name
from turtle import bgcolor, color, width
from unicodedata import name # imports tkinter lib
import os
import TextManager as TM

#size of window
root = Tk()
root.geometry('600x600') # initial size window of the notepad
root.title('Not A Notepad') # this is self explanatory
root.minsize(width=300,height=200)
root.configure(bg="#101010",background='gray17')
root.bind('<Motion>', TM.motion)

#panel for files
file_panel = Frame(root,bg='gray10',
                   height=600,
                   width=70,
                   )
file_panel.pack(side=LEFT,fill=BOTH,expand=False)

s = ttk.Style()
s.configure('TNotebook', background='gray17')
s.map('TNotebook.Tab', background=[("active", 'gray10')], foreground=[("active", 'gray17')])
s.configure('TNotebook.Tab', background='gray17', foreground= 'white' )

tabcontrol = ttk.Notebook(root, width=600,height=600, style='TNotebook')
ttk.Notebook(master=root)
tabcontrol.pack(expand=True,fill=BOTH)

s.theme_create('lunar', settings={
    "." :{ 
        "configure": {
            "background": 'black',
            "font": 'white',
            "border": 0
        }
    },
    "TNotebook":{
        "configure": {
            "background": 'gray17',
            "border": 0,
            "tabmargins": [1,5,0,0]
        }
    },
    "TNotebook.Tab" : {
        "configure": {
            "background": 'gray10',
            "padding": [1, 2],
            "foreground": 'white',
            "font" : ('normal', 10),
            "border": 0
        },
        "map" : {
            "background": [("selected", 'gray20')],
            "expand": [("selected",[0.5,0.5,0.5,0])]
        }
    }
})
s.theme_use('lunar')

class Tab:
    def __init__(self, notebook:ttk.Notebook, title, text) -> None:
        self.filename = None
        self.notebook = notebook
        self.frame = Frame(self.notebook, background='gray10')
        
        self.text_widget = Text(self.frame,font=('normal',15),
                                bg="#202020",
                                fg="white",
                                border=0,
                                insertbackground='white', padx=5)
        re = Scrollbar(self.frame, command=self.text_widget.yview)
        re.pack(fill=Y,side = RIGHT)
        self.text_widget.pack(fill=BOTH,expand=True)
        self.notebook.add(self.frame,text=f"{title}")
        self.notebook.configure(padding=15,width=600)
        self.text_widget.configure(yscrollcommand= re.set )
        self.text_widget.insert(1.0, text)
        self.text_widget.bind('<Button-3>', TM.copypaste)

def add_new_tab(title, text):
    tab = Tab(tabcontrol,title, text)



def save():
    filepath = asksaveasfile(defaultextension='txt',
                             confirmoverwrite=True,
                             filetypes=[("Text File","*.txt"),("Json File","*.json"),("All Files", "*.*")])
    if not filepath and tabcontrol.winfo_children != NULL:
        print("not valid filepath")
        return
    with open(f"{filepath.name}", 'w') as output_file:
        for i in tabcontrol.winfo_children():
            if str(i) == tabcontrol.select():
                text = i.get(1.0, 'end-1c')
                output_file.write(text)
                print('file save Success!')
                root.title(f"Entitled - {filepath.name}")
                output_file.close()

def load():
    filetypes = (
        ('text files', '*.txt'),
        ('Json files', '*.json'),
        ('All files', '*.*')
    )
    filepath = askopenfilename(defaultextension='txt',filetypes=filetypes)
    if not filepath:
        print("ERR: not valid filepath or corrupted!")
        return
    print(filepath)
    with open(f"{filepath}", 'r') as opened_file:
        s = os
        text = opened_file.read()
        add_new_tab(s.path.split(filepath)[1], text)
        root.title(f"Entitled -  {filepath}")
        opened_file.close()
        for i in tabcontrol.winfo_children():
            i.focus_set()
            return

def close_file():
    for tab in tabcontrol.winfo_children():
        if str(tab)==tabcontrol.select():
            tab.destroy()       
            return  #Necessary to break or the "for loop" will destroy all the tabs when first tab is deleted

def close_all_files():
    for tabs in tabcontrol.winfo_children():
        tabs.destroy()

def load_bttns():
    bgbutton = "#404040"
    fgbutton = "white"

    save_button = Button(root, text='Save file',
                        font=('times 14',10),
                        border=0,
                        command = save,
                        bg = bgbutton,
                        fg=fgbutton,
                        activebackground=bgbutton,
                        activeforeground=fgbutton)
    load_button = Button(root, text='Load file',
                        font=('times 14', 10),
                        border=0,
                        command = load,
                        bg = bgbutton,
                        fg=fgbutton,
                        activebackground=bgbutton,
                        activeforeground=fgbutton)
    close_button = Button(root, text="Close file",
                        font=('times 14', 10),
                        border=0,
                        command = close_file,
                        bg=bgbutton,
                        fg=fgbutton,
                        activebackground=bgbutton,
                        activeforeground=fgbutton)
    close_all_button = Button(root, text="Close All",
                              border=0,
                              command=close_all_files,
                              bg=bgbutton,
                              fg=fgbutton,
                              activebackground=bgbutton,
                              activeforeground=fgbutton)
    #add buttons
    save_button.place(x=5,y=40)
    load_button.place(x=5,y=80)
    close_button.place(x=5,y=120)
    close_all_button.place(x=5,y=160)
load_bttns()

#run a window
root.mainloop()
