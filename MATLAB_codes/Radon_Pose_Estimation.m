clc;
clear all;
close all;

% Replace the placeholder with your image path
I = imread("your_image_path"); 

% Convert RGB to Grayscale
im = rgb2gray(I);

% Specify the correct angle for orientation
correct_angle = 90;

% Sweep theta from 0 to 179 degrees for Radon Transform
theta = 0:1:179; 

% Apply Canny edge filter to get binary image
BW = edge(im, 'canny'); 

% Apply Radon Transform and get R matrix and xp (distance from the center)
[R, xp] = radon(BW, theta); 

% Round the Radon Transform matrix to 0 decimal places
RR = round(R, 0); 

% Find peaks in the Hough matrix
pp = houghpeaks(RR, 4);

% Extract angles corresponding to the peaks
angl = pp(:, 2);

% Introduce OCR to detect correct angle
flag = 4; 
rot = min(angl); 

% Rotate the image until correct orientation is obtained
while flag ~= 0
    bboxes = ocr_results(im, -rot, 'SCL');
    
    % Rotate image by -90 degrees until correct angle is obtained
    if isempty(bboxes)  
        rot = rot + 90;
        flag = flag - 1;
        
        if flag == 0
            rot = rot - 360;
            
            % Further check for 'ACC' detection
            f1 = 4; 
            while f1 ~= 0
                bboxes = ocr_results(im, -rot, 'ACC');
                
                if isempty(bboxes)
                    rot = rot + 90;
                    f1 = f1 - 1;
                    
                    if f1 == 0
                        rot = rot - 360;
                    end
                else
                    f1 = 0;
                end
            end
        end
    else
        flag = 0;
    end
end

% Correct error of erroneous results due to failed OCR attempts
err = abs(correct_angle - abs(rot));

% Adjust rotation based on error
if err >= 89 && err < 180
    rot = rot - 90;
end

if err >= 180 && err < 270
    rot = rot - 180;
end

if err >= 270 && err <= 360
    rot = rot - 270;
end

err = abs(correct_angle - abs(rot));

% Rotate the image to the corrected orientation
img = imrotate(im, -rot);

% Display the estimated angle
fprintf('The estimated angle is %d degrees.\n', rot);

% Display the original and corrected image
figure, imshowpair(im, img, 'montage'); 
title('Original and reoriented image');

% Display the error
fprintf('The error is %d degrees.\n', err);
