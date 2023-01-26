# manual_stitching
Manual alignment of microscopy sections

Instructions:
1. run deformably_align_sections.m
2. Select a pair of images to align. IMPORTANT: The convention is that the second image is warped onto first.
3. Click on successive points on red --> then green images that match. Right click when done.
4. Type 1 on command line if done - otherwise type 2 (affine) or 3 (rigid) for continuing to add more points.
5. When done, add more points to serve as landmarks for deformable alignment.
6. Type 1 when done, otherwise 0 to add more points or 2 to start over.
7. When done - the aligned image and deformation map will be saved to original directory of input images.

![Demo](https://github.com/evarol/manual_stitching/blob/master/demo.png)
