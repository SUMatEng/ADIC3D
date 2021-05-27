function runme
	current_folder=pwd;
	addpath(fullfile(current_folder,'vlfeat-0.9.21'))
	if exist('vl_sift')~=3, run(fullfile(current_folder,'vlfeat-0.9.21\toolbox\vl_setup')); fprintf('\nVLFeats vl_sift and vl_ubcmatch functions were not availabe, the required packages have been loaded (algorithm can be found at: https://www.vlfeat.org\n'); end

	[FileName,PathName] = uigetfile({'*.*'},'Select the images to analyse','MultiSelect','on',fullfile(current_folder,'Stereo_DIC_Challenge')); % choose images to correlate

	% determine which images belong to which image series
	count1=1;
	count2=1;
	for i=1:max(size(FileName))
		fullname=fullfile(PathName,FileName{i});
		[~,name,~]=fileparts(fullname);
		if name(end)=='0';
			FileNames1{count1}=fullname;
			count1=count1+1;
		elseif name(end)=='1'
			FileNames2{count2}=fullname;
			count2=count2+1;
		end
	end

	% show first image of first camera
	ImName=fullfile(PathName,FileName{1});
	I=im2double(imread(ImName));
	figure
	imshow(imadjust(I));

	% create mask
	ractan=imrect(gca);
	Mask=createMask(ractan);

	% load calibration targets
	if size(strfind(PathName,'Sample1'),1)~=0
	 	load(fullfile(current_folder,'Resources','CT_S1_35_raw.mat')); % for sample 1
	else
	 	load(fullfile(current_folder,'Resources','CT_S5_raw.mat')); % for sample 5
	end
 	ImgCTs=CT;
 	WorldCTs=WCT;

 	%change parameters if desired
	SubShape='Circle';
	SubSize=41;
	StepSize=10;
	SFOrder=1;
	RefStrat=0;
	StopCritVal=1e-4;
	GaussFilt=[0.2 5];

	warning('off','all') % suppress warnings ransac gives for noisy keypoints - change to "pctRunOnAll warning('off','all')" for parfor use
	ResultData=ADIC3D(FileNames1,FileNames2,Mask,GaussFilt,StepSize,SubSize,SubShape,SFOrder,RefStrat,StopCritVal,WorldCTs,ImgCTs);
	warning('on','all') % stop suppressing warnings - change to "pctRunOnAll warning('on','all')" for parfor use

	if RefStrat==1
	    for d=2:size(ResultData.ProcData,2)
	        ResultData.ProcData(d).Uw=ResultData.ProcData(d).Uw+ResultData.ProcData(d-1).Uw;
	    end
	end

	ResultData=AddGridFormat(ResultData); % add gridded matrices for display purposes
	figure
	surf(ResultData.Display(2).POSX,ResultData.Display(2).POSY,ResultData.Display(2).UX) % display displacement in the x-direction for the 2nd image
	xlabel('x')
	ylabel('y')
	title('Displacement in the x-direction')
	figure
	surf(ResultData.Display(2).POSX,ResultData.Display(2).POSY,ResultData.Display(2).UY) % display displacement in the y-direction for the 2nd image
	xlabel('x')
	ylabel('y')
	title('Displacement in the y-direction')
	figure
	surf(ResultData.Display(2).POSX,ResultData.Display(2).POSY,ResultData.Display(2).UZ) % display displacement in the z-direction for the 2nd image
	xlabel('x')
	ylabel('y')
	title('Displacement in the z-direction')
end