#!/usr/bin/env python

from PIL import Image
from matplotlib.pyplot import imsave

import numpy as np
import sys
import os


def main(low_file, high_file):
    dir = os.path.realpath(os.path.dirname(low_file))
    low_name, ext = os.path.splitext(os.path.basename(low_file))
    high_name, _ = os.path.splitext(os.path.basename(high_file))

    low_img = Image.open(low_file).convert("L")
    high_img = Image.open(high_file).convert("L")

    low_fft = np.fft.fftshift(np.fft.fft2(low_img))
    high_fft = np.fft.fftshift(np.fft.fft2(high_img))

    # Clear out a 2rh*2rh section from the center of the FFT of the high pass
    # image and paste in the 2rl*2rl center from the low pass image
    center = (int(low_fft.shape[0] / 2), int(low_fft.shape[1] / 2))
    cx = center[0]
    cy = center[1]
    rl = 23
    rh = 28
    cll = cx - rl
    clh = cx - rh
    crl = cx + rl
    crh = cx + rh
    cbl = cy - rl
    cbh = cy - rh
    ctl = cy + rl
    cth = cy + rh

    # Start with high pass FFT
    hybrid_fft = high_fft

    # Clear out the center
    hybrid_fft[clh:crh, cbh:cth] = 0

    # Paste a smaller section into the cleared out center
    hybrid_fft[cll:crl, cbl:ctl] = low_fft[cll:crl, cbl:ctl]

    hybrid = np.abs(np.fft.ifft2(hybrid_fft))

    imsave("{}/{}-{}{}".format(dir, low_name, high_name, ext), hybrid,
           cmap="binary")

    imsave("{}/{}-{}-fft{}".format(dir, low_name, high_name, ext),
           np.log(np.abs(hybrid_fft)))


if __name__ == "__main__":
    if len(sys.argv) >= 3:
        main(sys.argv[1], sys.argv[2])
