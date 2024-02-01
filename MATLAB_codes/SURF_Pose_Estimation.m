clc;
clear all;
close all;
iptsetpref('ImshowAxesVisible', 'on');

% Specify the correct angle for orientation
correct_angle = 90;

% Load reference image and convert to grayscale
original = imread('H:\Sai\PHOTOS\chip.png');
original = rgb2gray(original);

% Detect SURF features in the reference image
ptsOriginal  = detectSURFFeatures(original);
[featuresOriginal, validPtsOriginal] = extractFeatures(original, ptsOriginal);

% Load distorted image and convert to grayscale
distorted = imread('H:\Sai\PHOTOS\chip-90.png');
distorted = rgb2gray(distorted);

% Detect SURF features in the distorted image
ptsDistorted = detectSURFFeatures(distorted);
[featuresDistorted, validPtsDistorted]  = extractFeatures(distorted, ptsDistorted);

% Match features between original and distorted images
indexPairs = matchFeatures(featuresOriginal, featuresDistorted);
matchedOriginal  = validPtsOriginal(indexPairs(:, 1));
matchedDistorted = validPtsDistorted(indexPairs(:, 2));

% Estimate geometric transform (similarity) between matched points
[tform, inlierDistorted, inlierOriginal] = estimateGeometricTransform(...
    matchedDistorted, matchedOriginal, 'similarity');

% Display matched inlier points
figure;
showMatchedFeatures(original, distorted, inlierOriginal, inlierDistorted, 'montage');
title('Matching points (inliers only)');
legend('ptsOriginal', 'ptsDistorted');

% Recover scale and angle from the transformation matrix
Tinv = tform.invert.T;
ss = Tinv(2, 1);
sc = Tinv(1, 1);
scale_recovered = sqrt(ss*ss + sc*sc);
theta_recovered = atan2(ss, sc) * 180 / pi;

% Reorient the distorted image using the estimated transformation
outputView = imref2d(size(original));
recovered = imwarp(distorted, tform, 'OutputView', outputView);

% Display the original and reoriented image
figure, imshowpair(distorted, recovered, 'montage');
title('Original and reoriented image');

% Adjust theta_recovered to be in the range [0, 360)
if theta_recovered < 0
    theta_recovered = 360 + theta_recovered;
end

% Display the estimated angle and error
fprintf('The estimated angle is %0.4f degrees.\n', theta_recovered);
err = abs(correct_angle - abs(theta_recovered));
fprintf('The error is %0.4f degrees.\n', err);

iptsetpref('ImshowAxesVisible', 'off');
