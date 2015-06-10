#!/usr/bin/env python

import cv2
import matplotlib.pyplot as plt
import numpy as np

import sys
import os
import math


def downsample(image):
    blurred = cv2.GaussianBlur(image, (9, 9), 5)
    scaled = blurred[::2, ::2, :]

    return scaled


def nearest_neighbor(image, x, y):
    X, Y = image.shape[0:2]

    return image[np.clip(round(x), 0, X - 1), np.clip(round(y), 0, Y - 1)]


def linear_interp(image, x, y):
    X, Y = image.shape[0:2]
    xclip = lambda x: np.clip(x, 0, X - 1)
    yclip = lambda y: np.clip(y, 0, Y - 1)
    color = lambda p: image[p[0], p[1]]

    nbs = [np.array([xclip(math.floor(x)), yclip(math.floor(y))]),
           np.array([xclip(math.floor(x)), yclip(math.ceil(y))]),
           np.array([xclip(math.ceil(x)), yclip(math.floor(y))]),
           np.array([xclip(math.ceil(x)), yclip(math.ceil(y))])]

    dx = x - math.floor(x)
    dy = y - math.floor(y)

    # Bilinear Interpolation
    #
    # See
    # http://de.wikipedia.org/wiki/Skalierung_%28Computergrafik%29#Bilineare_Interpolation
    #
    # dx and dy are switched because opencv loads images in (y,x)-coordinates.
    Q1 = (1 - dy) * color(nbs[0]) + dy * color(nbs[1])
    Q2 = (1 - dy) * color(nbs[2]) + dy * color(nbs[3])
    P = (1 - dx) * Q1 + dx * Q2

    return P


def upsample(image, size, interp=nearest_neighbor):
    dst = np.empty(size, dtype="uint8")
    A, B = image.shape[0:2]
    X, Y = size[0:2]

    for x in range(X):
        for y in range(Y):
            dst[x, y] = interp(image, x / X * A, y / Y * B)

    return dst


def gausspyr(image, levels=5):
    if levels == 1:
        return [image]
    else:
        return [image] + gausspyr(downsample(image), levels - 1)


def lappyr(gpyr):
    return [g0 - upsample(g1, g0.shape,
                          interp=linear_interp)
            for (g0, g1) in zip(gpyr, gpyr[1:])]


def ilappyr(gpyr, lpyr):
    img = gpyr[-1]

    for l in reversed(lpyr):
        img = l + upsample(img, l.shape, interp=linear_interp)

    return img


def plotpyr(pyr):
    n = len(pyr)

    for i in range(n):
        plt.subplot(1, n, i + 1)
        plt.imshow(pyr[i])

    plt.show(block=False)


def pyrtoimg(pyr):
    margin = 10
    width = pyr[0].shape[1]
    height = sum([i.shape[0] for i in pyr]) + margin * (len(pyr) - 1)
    img = np.ones((height, width, 3), dtype="uint8") * 255

    x = 0

    for i in pyr:
        (h, w) = i.shape[0:2]
        y = (width - w) / 2

        img[x:(x + h), y:(y + w), :] = i

        x = x + h + margin

    return img


def main(path):
    path = os.path.realpath(path)
    (root, ext) = os.path.splitext(path)

    def saveimg(name, img):
        cv2.imwrite("{}_{}{}".format(root, name, ext), img)

    image = cv2.imread(path)
    gpyr = gausspyr(image)
    lpyr = lappyr(gpyr)
    reconstructed = ilappyr(gpyr, lpyr)
    difference = image - reconstructed

    saveimg("gaussian", pyrtoimg(gpyr))
    saveimg("laplacian", pyrtoimg(lpyr))
    saveimg("reconst", reconstructed)
    saveimg("diff", difference)


if __name__ == "__main__":
    if len(sys.argv) >= 2:
        main(sys.argv[1])
