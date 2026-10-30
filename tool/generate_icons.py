"""Draws the Rep Flow logo and writes every platform's app icons.

Run from the repo root:  python tool/generate_icons.py   (needs Pillow)
"""
import glob, math, os
from PIL import Image, ImageDraw

INK=(17,17,17); PAPER=(250,250,250)
S=4  # supersample
def line(d,a,b,w,c):
    d.line([a,b],fill=c,width=w)
    for p in (a,b): d.ellipse([p[0]-w/2,p[1]-w/2,p[0]+w/2,p[1]+w/2],fill=c)

def render(size=1024, rounded=False, pad=0.0):
    N=1024*S
    img=Image.new('RGBA',(N,N),(0,0,0,0) if rounded else INK+(255,))
    d=ImageDraw.Draw(img)
    k=S*(1-2*pad); o=N*pad
    P=lambda x,y:(o+x*k,o+y*k)
    if rounded:
        d.rounded_rectangle([o,o,N-o,N-o],radius=230*k,fill=INK+(255,))
    # ring arc: gap at top-right
    cx,cy=P(512,512); r=330*k; w=int(52*k)
    start,end=-15,285  # degrees, PIL: 0=east, clockwise
    d.arc([cx-r,cy-r,cx+r,cy+r],start,end,fill=PAPER,width=w)
    for ang in (start,end):
        a=math.radians(ang); p=(cx+(r-w/2)*math.cos(a),cy+(r-w/2)*math.sin(a))
        d.ellipse([p[0]-w/2,p[1]-w/2,p[0]+w/2,p[1]+w/2],fill=PAPER)
    # stick figure, arms up
    sw=int(46*k)
    hx,hy=P(512,322); hr=54*k
    d.ellipse([hx-hr,hy-hr,hx+hr,hy+hr],fill=PAPER)
    neck=P(512,475); hip=P(512,600)
    line(d,neck,hip,sw,PAPER)
    line(d,P(512,475),P(398,350),sw,PAPER)
    line(d,P(512,475),P(626,350),sw,PAPER)
    line(d,hip,P(440,712),sw,PAPER)
    line(d,hip,P(584,712),sw,PAPER)
    return img.resize((size,size),Image.LANCZOS)

def write(path, img):
    os.makedirs(os.path.dirname(path) or '.', exist_ok=True)
    img.save(path)
    print(path)

def resize_all(pattern, **style):
    for path in glob.glob(pattern):
        size = Image.open(path).size[0]
        img = render(size, **style)
        write(path, img.convert('RGB') if not style else img)

if __name__ == '__main__':
    write('assets/logo.png', render(512, rounded=True, pad=0.02))
    # iOS: full-bleed, no alpha (the system applies the mask)
    resize_all('ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png')
    resize_all('android/app/src/main/res/mipmap-*/ic_launcher.png', rounded=True, pad=0.04)
    resize_all('macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png', rounded=True, pad=0.1)
    resize_all('web/icons/Icon-maskable-*.png')
    resize_all('web/icons/Icon-[0-9]*.png', rounded=True, pad=0.02)
    write('web/favicon.png', render(32, rounded=True))
    ico = render(256, rounded=True, pad=0.02)
    ico.save('windows/runner/resources/app_icon.ico', sizes=[(16, 16), (32, 32), (48, 48), (256, 256)])
