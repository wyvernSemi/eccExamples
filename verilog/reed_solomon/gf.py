

GF= 1;
poly = 0x1d # x^8 + x^4 + x^3 + x^2 + 1

for  i in range(0, 256):
  print("%3d: %s (%02x)" % (i, bin(GF)[2:].zfill(8), GF))
  if ((GF & 0x80)) :
    GF = ((GF << 1)^poly) & 0xff
  else:
    GF = (GF << 1) & 0xff
    