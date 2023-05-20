import numpy as np
from colormap import rgb2hex, rgb2hls, hls2rgb
# pip install colormap
# pip install easydev

def hex_to_rgb(hex):
     hex = hex.lstrip('#')
     hlen = len(hex)
     return tuple(int(hex[i:i+hlen//3], 16) for i in range(0, hlen, hlen//3))

def adjust_color_lightness(r, g, b, factor):
    h, l, s = rgb2hls(r / 255.0, g / 255.0, b / 255.0)
    l = max(min(l * factor, 1.0), 0.0)
    r, g, b = hls2rgb(h, l, s)
    return rgb2hex(int(r * 255), int(g * 255), int(b * 255))

def darken_color(r, g, b, factor=0.1):
    return adjust_color_lightness(r, g, b, 1 - factor)

random_number = np.random.randint(0,16777215)
hex_number = str(hex(random_number))
hex_number ='#'+ hex_number[2:]

r, g, b = hex_to_rgb(hex_number) # hex to rgb format
print(darken_color(r, g, b))
