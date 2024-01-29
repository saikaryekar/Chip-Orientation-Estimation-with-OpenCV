# Chip-Orientation-Estimation-with-OpenCV

## Overview

This project focuses on chip orientation estimation using computer vision techniques in a VLSI testing environment. The provided Python script uses OpenCV to create a bounding box around objects in a given image and returns the angular offset of the objects with notations.

## Installation

1. **Clone the repository:**

    ```bash
    git clone https://github.com/saikaryekar/Chip-Orientation-Estimation-with-OpenCV.git
    cd Chip-Orientation-Estimation-with-OpenCV
    ```

2. **Install dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

## Usage

Run the `chip_orientation_estimation.py` script with the path to the input image as an argument. For example:

```bash
python chip_orientation_estimation.py --image_path data/input_img.jpg
