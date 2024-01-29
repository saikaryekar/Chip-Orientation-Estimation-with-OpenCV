import os
import cv2 as cv
import numpy as np
from math import atan2, cos, sin, sqrt, pi

def drawAxis(img, p_, q_, color, scale):
    p = list(p_)
    q = list(q_)

    angle = atan2(p[1] - q[1], p[0] - q[0])
    hypotenuse = sqrt((p[1] - q[1]) * (p[1] - q[1]) + (p[0] - q[0]) * (p[0] - q[0]))

    q[0] = p[0] - scale * hypotenuse * cos(angle)
    q[1] = p[1] - scale * hypotenuse * sin(angle)
    cv.line(img, (int(p[0]), int(p[1])), (int(q[0]), int(q[1])), color, 3, cv.LINE_AA)

    p[0] = q[0] + 9 * cos(angle + pi / 4)
    p[1] = q[1] + 9 * sin(angle + pi / 4)
    cv.line(img, (int(p[0]), int(p[1])), (int(q[0]), int(q[1])), color, 3, cv.LINE_AA)

    p[0] = q[0] + 9 * cos(angle - pi / 4)
    p[1] = q[1] + 9 * sin(angle - pi / 4)
    cv.line(img, (int(p[0]), int(p[1])), (int(q[0]), int(q[1])), color, 3, cv.LINE_AA)

def getOrientation(pts, img):
    sz = len(pts)
    data_pts = np.empty((sz, 2), dtype=np.float64)
    for i in range(data_pts.shape[0]):
        data_pts[i, 0] = pts[i, 0, 0]
        data_pts[i, 1] = pts[i, 0, 1]

    mean = np.empty((0))
    mean, eigenvectors, eigenvalues = cv.PCACompute2(data_pts, mean)

    cntr = (int(mean[0, 0]), int(mean[0, 1]))

    cv.circle(img, cntr, 3, (255, 0, 255), 2)
    p1 = (cntr[0] + 0.02 * eigenvectors[0, 0] * eigenvalues[0, 0], cntr[1] + 0.02 * eigenvectors[0, 1] * eigenvalues[0, 0])
    p2 = (cntr[0] - 0.02 * eigenvectors[1, 0] * eigenvalues[1, 0], cntr[1] - 0.02 * eigenvectors[1, 1] * eigenvalues[1, 0])
    
    drawAxis(img, cntr, p1, (255, 255, 0), 1)
    drawAxis(img, cntr, p2, (0, 0, 255), 5)

    angle = atan2(eigenvectors[0, 1], eigenvectors[0, 0])
    
    label = "  Rotation Angle: " + str(-int(np.rad2deg(angle)) - 90) + " degrees"
    textbox = cv.rectangle(img, (cntr[0], cntr[1] - 25), (cntr[0] + 250, cntr[1] + 10), (255, 255, 255), -1)
    cv.putText(img, label, (cntr[0], cntr[1]), cv.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0), 1, cv.LINE_AA)

    return angle

def processImage(img_path):
    img = cv.imread(img_path)
    if img is None:
        print(f"Error: File not found - {img_path}")
        exit(0)

    cv.imshow('Input Image', img)
    
    gray = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
    _, bw = cv.threshold(gray, 50, 255, cv.THRESH_BINARY | cv.THRESH_OTSU)

    contours, _ = cv.findContours(bw, cv.RETR_LIST, cv.CHAIN_APPROX_NONE)

    for i, c in enumerate(contours):
        area = cv.contourArea(c)

        if area < 3700 or 100000 < area:
            continue

        rect = cv.minAreaRect(c)
        box = cv.boxPoints(rect)
        box = np.int_(box)

        center = (int(rect[0][0]), int(rect[0][1]))
        width = int(rect[1][0])
        height = int(rect[1][1])
        angle = int(rect[2])

        if width < height:
            angle = 90 - angle
        else:
            angle = -angle

        label = "  Rotation Angle: " + str(angle) + " degrees"
        textbox = cv.rectangle(img, (center[0] - 35, center[1] - 25), (center[0] + 295, center[1] + 10), (255, 255, 255), -1)
        cv.putText(img, label, (center[0] - 50, center[1]), cv.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 0), 1, cv.LINE_AA)
        cv.drawContours(img, [box], 0, (0, 0, 255), 2)

    cv.imshow('Output Image', img)
    cv.waitKey(0)
    cv.destroyAllWindows()

    cv.imwrite("min_area_rec_output.jpg", img)

# Example Usage
# Assuming the script is in the "src" folder
script_directory = os.path.dirname(os.path.realpath(__file__))
data_folder = os.path.join(script_directory, '..', 'data')

# Load the image from the "data" folder
img_path = os.path.join(data_folder, 'sample_img_2.jpg')
processImage(img_path)
