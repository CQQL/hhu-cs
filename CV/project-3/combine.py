#!/usr/bin/env python

import cv2
import numpy as np
import matplotlib.pyplot as plt

import os
import sys
import itertools

from pyramids import gausspyr, lappyr, ilappyr


def combine(mask, a, b):
    X, Y = mask.shape[0:2]
    img = np.empty((X, Y, 3), dtype="uint8")

    for x in range(X):
        for y in range(Y):
            if np.mean(mask[x, y]) < 128:
                img[x, y] = a[x, y]
            else:
                img[x, y] = b[x, y]

    return img


def downscalepyr(img, levels=5):
    if levels == 1:
        return [img]
    else:
        return [img] + downscalepyr(img[::2,::2,:], levels=levels - 1)


def main(maskpath, apath, bpath):
    apath = os.path.realpath(apath)
    bpath = os.path.realpath(bpath)
    (root, ext) = os.path.splitext(apath)
    (broot, _) = os.path.splitext(bpath)
    bname = os.path.basename(broot)

    # Read images
    mask = cv2.imread(maskpath)
    a = cv2.imread(apath)
    b = cv2.imread(bpath)

    # Create direct combination
    cmb = combine(mask, a, b)

    # Construct the pyramids
    masks = downscalepyr(mask)
    agausspyr = gausspyr(a)
    bgausspyr = gausspyr(b)
    alappyr = lappyr(agausspyr)
    blappyr = lappyr(bgausspyr)

    # Combine the pyramids
    cgausspyr = list(itertools.starmap(combine, zip(masks, agausspyr,
                                                    bgausspyr)))
    clappyr = list(itertools.starmap(combine, zip(masks, alappyr, blappyr)))

    # Recreate the original from the combined pyramids
    c = ilappyr(cgausspyr, clappyr)

    cv2.imwrite("{}_{}{}".format(root, bname, ext), cmb)
    cv2.imwrite("{}_{}_laplacian{}".format(root, bname, ext), c)


if __name__ == "__main__":
    if len(sys.argv) >= 4:
        main(*sys.argv[1:4])
