#!/usr/bin/env python3

from PIL import Image
from matplotlib.pyplot import imsave

import numpy as np
import cv2
import sys
import os


def main(a_file, b_file):
    dir = os.path.realpath(os.path.dirname(a_file))
    a_name, _ = os.path.splitext(os.path.basename(a_file))
    b_name, ext = os.path.splitext(os.path.basename(b_file))

    a_img = Image.open(a_file).convert("L")
    b_img = Image.open(b_file).convert("L")

    a_fft = np.fft.fft2(a_img)
    b_fft = np.fft.fft2(b_img)

    a_mag = np.abs(a_fft)
    b_mag = np.abs(b_fft)

    a_phase = np.angle(a_fft)
    b_phase = np.angle(b_fft)

    ambp = np.abs(np.fft.ifft2(a_mag * np.exp(1j * b_phase)))
    bmap = np.abs(np.fft.ifft2(b_mag * np.exp(1j * a_phase)))

    imsave("{}/{}-m{}".format(dir, a_name, ext),
           np.log(np.fft.fftshift(a_mag)))
    imsave("{}/{}-m{}".format(dir, b_name, ext),
           np.log(np.fft.fftshift(b_mag)))
    imsave("{}/{}-p{}".format(dir, a_name, ext), np.fft.fftshift(a_phase))
    imsave("{}/{}-p{}".format(dir, b_name, ext), np.fft.fftshift(b_phase))
    imsave("{}/{}-m-{}-p{}".format(dir, a_name, b_name, ext), ambp,
           cmap="binary")
    imsave("{}/{}-m-{}-p{}".format(dir, b_name, a_name, ext), bmap,
           cmap="binary")


if __name__ == "__main__":
    if len(sys.argv) >= 3:
        main(sys.argv[1], sys.argv[2])
