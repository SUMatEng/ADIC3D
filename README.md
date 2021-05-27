# ADIC3D

## Description:
This repository houses a modular, open-source MATLAB code to perform Stereo Digital Image Correlation (DIC). This code forms part of the paper titled: "Stereo Digital Image Correlation in MATLAB" which aims to serve as an educational resource to bridge the gap between the theory of Stereo DIC and its practical implementation. Furthermore, although the code is designed as an educational resource, its validation combined with its modularity makes it attractive as a starting point to develop the capabilities of DIC.

More specifically, DIC has found widespread use in measuring full-field displacements and deformations experienced by a body from images captured of it. Stereo-DIC has received significantly more attention than two-dimensional (2D) DIC since it can account for out-of-plane displacements. Although many aspects of Stereo-DIC that are shared in common with 2D DIC are well documented, there is a lack of resources that cover the theory of Stereo-DIC. Furthermore, publications which do detail aspects of the theory do not detail its implementation in practice. This literature gap makes it difficult for newcomers to the field of DIC to gain a deep understanding of the Stereo-DIC process, although this knowledge is necessary to contribute to the development of the field by either furthering its capabilities or adapting it for novel applications. This gap in literature acts as a barrier thereby limiting the development rate of Stereo-DIC. This paper attempts to address this by presenting the theory of a subset-based Stereo-DIC framework that is predominantly consistent with the current state-of-the-art (as of the writing of the paper). The framework is implemented in practice as a 202 line MATLAB code. Validation of the framework shows that it performs on par with well-established Stereo-DIC algorithms, indicating it is sufficiently reliable for practical use. Although the framework is designed to serve as an educational resource, its modularity and validation make it attractive as a means to further the capabilities of DIC (refer to the paper, referenced below, for more details). 

## How to use:
ADIC3D can be used through the command line of MATLAB. However it is advised to create a run file, such as the example file provided which is called runme.m, in order to run ADIC3D. This file (runme.m) runs the ADIC3D code for Samples 1 or 5 of the Stereo DIC challenge. The function input values on lines 43-49 of runme.m can be changed in order to set up the DIC analysis in the desired way. Once ADIC3D has analysed the images and returns the results (as ResultData on line 52) the subroutine AddGridFormat appends the displacement results in gridded format to the ResultData variable within the field ResultData.Display and the displacements in the x, y and z-direction are displayed in lines 61-76.

### Parallel processing:
The correlation aspect of ADIC3D can be run using parallel processing by changing the for loop line 18 of the function ImgCorr and line 11 of StereoMatch to a parfor loop. Furthermore, determining shape function parameters initial estimates for stereo matching (from displacements determined using SIFT feature matching) can be run using parallel processing by changing the for loop of line 13 of FeatureMatch to a parfor loop. Note however that this does increase memory required by ADIC3D in order to run (exceeding memory limits of your PC will result in the code crashing).

### Displaying computed displacements:
ProcData stores the results in a vector format. In order to display the displacement and position information of the subsets easily a gridded format is necessary. The function AddGridFormat accepts ProcData and adds fields with gridded matrices for the purpose of displaying the results. More specifically, AddGridFormat adds the following fields:
* ResultData.Display(d).POSX 	- which for image d stores the x-positions of the subsets (in the world CS) in a gridded format
* ResultData.Display(d).POSY 	- which for image d stores the y-positions of the subsets (in the world CS) in a gridded format
* ResultData.Display(d).POSZ 	- which for image d stores the z-positions of the subsets (in the world CS) in a gridded format
* ResultData.Display(d).UX 		- which for image d stores the x-displacements of the subsets (in the world CS) in a gridded format
* ResultData.Display(d).UY 		- which for image d stores the y-displacements of the subsets (in the world CS) in a gridded format
* ResultData.Display(d).UZ 		- which for image d stores the z-displacements of the subsets (in the world CS) in a gridded format

This function is called as shown on line 61 of runme.m and the displacements can be plotted as shown on lines 62-76.

### Alternative implementation:
Running ADIC3D with a large amount of subsets can cause MATLAB’s undistortPoints function (used during subroutine CSTrans) to require a large amount of random-access memory. If it requires more memory than is available this causes a fatal error. This is avoided by replacing calls to undistortPoints with calls to subroutine UndistortPasser which processes batches of 100 subset pairs at a time, both increasing the speed of computation and avoiding crashes due to high random-access memory requirements.

Additionally, in cases where there is a large amount of displacement occurring between two consecutive image pairs in the image set, it is recommended that the feature matching method (used during stereo matching) be used during temporal matching in order to determine reliable shape function parameter initial estimates (be aware of the limitations of this method briefly highlighted in the discussion section of the paper). This can be implemented by placing "[PD(d).P]=FeatureMatch(PD,d,F,G,SubExtract);" after line 16 of subroutine ImgCorr.

### Obtaining VLFeat's SIFT function:
The FeatureMatch subroutine requires the vl_sift and vl_ubsmatch functions VLFeat's code package. The MATLAB code needs to be downloaded from VLFeat's website https://www.vlfeat.org/install-matlab.html. Download the binary version for MATLAB, unzip the downloaded folder and place the unzipped folder in the working directory. To set up the required SIFT algorithm you need to run the vl_setup file from the MATLAB command prompt as run('PathToWorkingDirectory\vlfeat-0.9.21\toolbox\vl_setup'). Note that if you have downloaded a different version of the code you need to modify "vlfeat-0.9.21" to the appropriate folder name. This has been done in line 4 of the runme file for the user's convenience.

### Obtaining DIC Challenge Image Sets:
In order to use this runme.m file Sample 1 (35mm lens) or 5 of the Stereo DIC challenge must be downloaded from the SEM website https://sem.org/3ddic. Thereafter they need to be unzipped and the unzipped folders of each sample need to be placed in a folder within the working directory named "Stereo_DIC_Challenge". (Alternatively you can save the Sample images to a location of your choice and modify line 6 as appropriate). Within the unzipped folder there are zipped folders, the folder named "Translate" needs to be unzipped as this contains the images (the other folders contain calibration image sets).

### How to determine calibration data:
ADIC3D expects calibration targets to be input which are consistent with the requirements of MATLAB's estimateCameraParameters function. It is recommended to use Multi-DIC's STEP1_CalcDLTparameters function to determine the location of calibration targets in the calibration images. Here for the runme example file calibration data is provided in the "CT_S1_35_raw.mat" and "CT_S5_raw.mat" files for Sample 1 and 5 of the Stereo DIC Challenge respectively.

## License:
Note that use of this code (ADIC3D and all its sub-functions) falls under the GNU GENERAL PUBLIC LICENSE Version 3. Furthermore, note that in the case of using this code for works related to publications (scientific or otherwise) requires citing of the source paper (citation given below).

## Citing ADIC3D:
Atkinson, D.; Becker, T.H. Stereo Digital Image Correlation in MATLAB. Appl. Sci. 2021, 11, 4904. 
Paper can be accessed at: https://doi.org/10.3390/app11114904