clc;
clear all;
close all;

% Load image from the specified path
I = imread('C:\Users\VTDCCD\Desktop\Presentations\img89.jpg'); 

% Convert RGB to Grayscale
I = rgb2gray(I);

% Specify the correct angle for orientation
correct_angle = 30;

% Uncomment the line below if rotation is needed initially
% Im = imrotate(I, correct_angle);

% Initialize with the original image
Im = I;

%% Perform Hough Transform
I_bw = edge(Im, 'canny'); 

% Apply canny edge filter to get binary image
[H, theta, rho] = hough(I_bw, 'Theta', -45:1:45); 

% Find the 4 peaks in the hough matrix. Peaks correspond to potential lines in the image.
P = houghpeaks(H, 4);   

% Apply houghlines function to get coordinates of line segments
lines = houghlines(I_bw, theta, rho, P, 'FillGap', 10, 'MinLength', 7); 

% Initialize array to store theta values
angl = zeros(1, length(lines));

% Extract theta values from the obtained line segments
for k = 1:length(lines)
    angl(k) = lines(k).theta;
end

%% Introduce OCR to detect correct angle
flag = 4; 
rot = min(angl); 

% Correct the angle with respect to 90, 180, and 270 degrees
while flag ~= 0
    bboxes = ocr_results(Im, rot, 'SCL'); 

    % Rotate image by -90 degrees until correct angle is obtained
    if isempty(bboxes)  
        rot = rot - 90;
        flag = flag - 1;
        
        if flag == 0
            rot = rot + 360;
            f1 = 4;
            
            % Further check for 'ACC' detection
            while f1 ~= 0
                bboxes = ocr_results(Im, rot, 'ACC');
                
                if isempty(bboxes)
                    rot = rot - 90;
                    f1 = f1 - 1;
                    
                    if f1 == 0
                        rot = rot + 360;
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

%% Correct error and rotate image
err = abs(correct_angle - abs(rot)); 

% Adjust rotation based on error
if err >= 89 && err < 180
    rot = rot + 90;
end

if err >= 180 && err < 270
    rot = rot + 180;
end

if err >= 270 && err <= 360
    rot = rot + 270;
end

err = abs(correct_angle - abs(rot));

% Rotate the image to the corrected orientation
Image = imrotate(Im, rot);

% Display the estimated angle
fprintf('The estimated angle is %d degrees.\n', rot);

% Display the error
fprintf('The error is %d degrees.\n', err);

% Display the original and corrected image
iptsetpref('ImshowAxesVisible', 'on');
figure, imshowpair(Im, Image, 'montage');
title('Original and reoriented image');
iptsetpref('ImshowAxesVisible', 'off');
