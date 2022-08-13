from PIL import Image

im = Image.open("pic.png")
pix = im.load()
print(im.size)
for i in range(4):
    print(pix[i, 0])
