b = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,150,0,0,0,0,0,0,0,0,0,0] # ROM bytes 0xA0 to 0xBC (game title to software version inclusive)

c = 0
for i in range(len(b)):
	c = c - b[i]

c = (c - 0x19) & 0x0FF

print(hex(c))

