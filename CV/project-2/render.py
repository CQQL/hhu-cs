#!/usr/bin/env python3

from collections import namedtuple
from PIL import Image, ImageDraw
from functools import reduce

import json
import sys
import os
import numpy as np
import itertools


class Shape:
    def __init__(self, points, edges, surfaces):
        self.points = points
        self.edges = edges
        self.surfaces = surfaces

    def edge_points(self):
        """Return the edges as tuples of start and end point
        """
        return [(self.points[e[0]], self.points[e[1]]) for e in self.edges]

    def surface_points(self):
        """Return the surfaces as lists of their corners
        """
        return [[self.points[p] for p in s] for s in self.surfaces]

    def center(self):
        return sum(self.points) / len(self.points)


class Camera:
    def __init__(self, position, focal_length, pixel_size):
        f = focal_length
        s = pixel_size

        self.moveto(position)

        # Look along the Z-axis
        self.R = np.eye(4)

        # Projection matrix
        self.P = np.matrix([[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]])

        # Camera intrinsics
        self.K = np.matrix([[f, 0, s], [0, f, s], [0, 0, 1]])

        self.compute_C()

    def moveto(self, position):
        self.position = position

        # Translation matrix
        #
        # Points have to be translated with the negative position to put the
        # camera in the center of the coordinate system
        self.T = np.eye(4)
        self.T[0:3, -1] = -position

    def lookat(self, point):
        """Orientate the camera towards a point

        We do this by rotating point onto the Z-axis.
        """
        p = point - self.position

        zaxis = np.array([0, 0, 1])
        axis = np.cross(p, zaxis)
        axis = axis / np.linalg.norm(axis, 2)

        # The norm of zaxis is 1
        angle = np.arccos(p.dot(zaxis) / np.linalg.norm(p))

        R = rotationmatrix(axis, angle)

        # Embed 3x3 rotation matrix in a 4x4 matrix
        self.R = np.eye(4)
        self.R[0:3, 0:3] = R

        self.compute_C()

    def compute_C(self):
        """Precompute the camera matrix
        """
        self.C = self.K.dot(self.P.dot(self.R.dot(self.T)))

    def project(self, point):
        """Project a point onto the camera plane
        """
        augmented = np.append(point, 1)
        transformed = self.C.dot(augmented).A1

        if transformed[-1] == 0.0:
            return np.array([0, 0])
        else:
            return transformed[0:-1] / transformed[-1]


def parse_shape(json):
    points = [np.array(p) for p in json["points"]]
    edges = [tuple(e) for e in json["edges"]]
    surfaces = [tuple(s) for s in json["surfaces"]]

    return Shape(points, edges, surfaces)


def parse_camera(json):
    position = np.array(json["position"])
    focal_length = json["focal_length"]
    pixel_size = json["pixel_size"]

    return Camera(position, focal_length, pixel_size)


def rotationmatrix(axis, angle):
    """Compute rotation matrix to rotate a vector angle radians around axis

    This uses Rodrigues' rotation formula.
    """

    K = np.matrix([[0, -axis[2], axis[1]], [axis[2], 0, -axis[0]],
                   [-axis[1], axis[0], 0]])

    R = np.eye(3) + np.sin(angle) * K + (1 - np.cos(angle)
                                         ) * np.linalg.matrix_power(K, 2)

    return R


def project(shape, camera):
    """Project a 3D-shape onto a camera plane as a 2D-shape
    """
    points = [camera.project(p) for p in shape.points]

    return Shape(points, shape.edges, shape.surfaces)


def draw_shape(shape):
    side = 300
    T = np.array([side / 2, -side / 2])
    image = Image.new("RGB", (side, side))
    draw = ImageDraw.Draw(image)
    radius = 2
    corner_colors = ["red", "blue", "green", "yellow"]
    edge_color = (50, 150, 200)

    # We mirror the points on the x axis, because pillow puts the origin in the
    # top-left corner
    height = image.size[1]

    def mirror(point):
        return np.array([point[0], height - point[1]])

    for edge in shape.edge_points():
        start = mirror(edge[0]) + T
        end = mirror(edge[1]) + T

        draw.line([tuple(start), tuple(end)], edge_color, 2)

    points = [mirror(p) for p in shape.points]
    for p, color in zip(points, itertools.cycle(corner_colors)):
        draw.ellipse([tuple(p - radius + T), tuple(p + radius + T)], color)

    for surface in shape.surface_points():
        for a, b in itertools.combinations(surface, 2):
            start = mirror(a) + T
            end = mirror(b) + T

            draw.line([tuple(start), tuple(end)], "cyan")

    return image


def main(shape_file, camera_file):
    dir = os.path.realpath(os.path.dirname(shape_file))
    name, ext = os.path.splitext(os.path.basename(shape_file))

    with open(shape_file, "r") as f:
        shape = parse_shape(json.load(f))

    with open(camera_file, "r") as f:
        camera = parse_camera(json.load(f))

    zaxis = np.array([0, 0, 1])
    steps = 60
    angle = 2 * np.pi / steps

    center = shape.center()
    radius = camera.position - center
    R = rotationmatrix(zaxis, angle)

    # Rotate around the object in the XY-axis and keep looking at the center
    for i in range(steps):
        radius = R.dot(radius).A1

        camera.moveto(center + radius)
        camera.lookat(center)

        projected = project(shape, camera)

        image = draw_shape(projected)

        image.save("{}/{}-{:02}.png".format(dir, name, i))


if __name__ == "__main__":
    if len(sys.argv) >= 3:
        main(sys.argv[1], sys.argv[2])
