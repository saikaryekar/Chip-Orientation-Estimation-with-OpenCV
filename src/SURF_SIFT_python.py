import cv2
import numpy as np

def find_rotation_angle(img1, img2, detector, matcher):
    # Detect keypoints and compute descriptors
    keypoints1, descriptors1 = detector.detectAndCompute(img1, None)
    keypoints2, descriptors2 = detector.detectAndCompute(img2, None)

    # Match descriptors using KNN (K-Nearest Neighbors)
    matches = matcher.knnMatch(descriptors1, descriptors2, k=2)

    # Apply ratio test
    good_matches = []
    for m, n in matches:
        if m.distance < 0.75 * n.distance:
            good_matches.append(m)

    # Extract matching points
    src_pts = np.float32([keypoints1[m.queryIdx].pt for m in good_matches]).reshape(-1, 1, 2)
    dst_pts = np.float32([keypoints2[m.trainIdx].pt for m in good_matches]).reshape(-1, 1, 2)

    # Find the perspective transformation (rotation and translation)
    M, _ = cv2.findHomography(src_pts, dst_pts, cv2.RANSAC, 5.0)

    # Extract rotation angle from the transformation matrix
    angle_rad = np.arctan2(M[1, 0], M[0, 0])
    angle_deg = np.degrees(angle_rad)

    return angle_deg

# Read the input images
image1 = cv2.imread('sample_img_2_ref.jpg', cv2.IMREAD_GRAYSCALE)
image2 = cv2.imread('sample_img_2.jpg', cv2.IMREAD_GRAYSCALE)

# Initialize SURF detector and matcher
# surf = cv2.xfeatures2d.SURF_create()
bf = cv2.BFMatcher()

# Find the rotation angle using SURF
# angle_surf = find_rotation_angle(image1, image2, surf, bf)
# print(f"Rotation Angle (SURF): {angle_surf} degrees")

# Initialize SIFT detector and matcher
sift = cv2.SIFT_create()

# Find the rotation angle using SIFT
angle_sift = find_rotation_angle(image1, image2, sift, bf)
print(f"Rotation Angle (SIFT): {angle_sift} degrees")
