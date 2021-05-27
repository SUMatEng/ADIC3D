function ResultData=ADIC3D(FileNames1,FileNames2,Mask, GaussFilt,StepSize,SubSize,SubShape,SFOrder,RefStrat, StopCritVal,WorldCTs, ImgCTs)
[~,ImNames1]=cellfun(@fileparts,FileNames1,'Uni',0);
[~,ImNames2]=cellfun(@fileparts,FileNames2,'Uni',0);
n=numel(FileNames1);
[r,c]=size(im2double(imread(FileNames1{1})));
[XosX,XosY]=meshgrid(((SubSize+1)/2+StepSize):StepSize:(c-(SubSize+1)/2-1-StepSize),((SubSize+1)/2+StepSize): StepSize:(r-(SubSize+1)/2-1-StepSize));
Xos=[XosX(:)'; XosY(:)']; clear XosX, XosY;
Xos=Xos(:,arrayfun(@(X,Y) min(min(Mask(Y-(SubSize-1)/2:Y+(SubSize-1)/2, X-(SubSize-1)/2:X+(SubSize-1)/2))),Xos(1,:),Xos(2,:))==1);
ResultData.ProcData1=struct('ImgName', ImNames1,'ImgSize', repmat({[r,c]},1,n),'ImgFilt',repmat({GaussFilt},1,n), 'SubSize',repmat({SubSize*ones([1,size(Xos,2)])},1,n), 'SubShape',repmat({repmat(SubShape,size(Xos,2),1)},1,n), 'SFOrder', repmat({repmat(SFOrder,1,size(Xos,2))},1,n), 'Xos',repmat({Xos},1,n),'P',repmat({zeros([12,size(Xos,2)])}, 1,n),'C',repmat({NaN([1,size(Xos,2)])},1,n),'StopVal', repmat({ones([1,size(Xos,2)])*StopCritVal},1,n), 'Iter',repmat({zeros([1,size(Xos,2)])},1,n));
ResultData.ProcData2=struct('ImgName', ImNames2, 'ImgSize', repmat({[r,c]},1,n), 'ImgFilt',repmat({GaussFilt},1,n), 'SubSize', repmat({SubSize*ones([1,size(Xos,2)])},1,n), 'SubShape',repmat({repmat(SubShape,size(Xos,2),1)},1,n), 'SFOrder',repmat({repmat(SFOrder,1,size(Xos,2))},1,n), 'Xos',repmat({Xos},1,n),'P',repmat({zeros([12,size(Xos,2)])}, 1,n),'C',repmat({NaN([1,size(Xos,2)])},1,n),'StopVal',repmat ({ones([1,size(Xos,2)])*StopCritVal},1,n),'Iter',repmat ({zeros([1,size(Xos,2)])},1,n));
ResultData.Stereo=struct('P',zeros([12,size(Xos,2)]), 'C', NaN([1,size(Xos,2)]),'StopVal',ones([1,size(Xos,2)])* StopCritVal, 'Iter',zeros([1,size(Xos,2)]));
ResultData.DispTrans=struct('Xow',repmat({NaN(3,size(Xos,2))},1,n),'Uw',repmat({NaN(3,size(Xos,2))},1,n),'CamParams', repmat({stereoParameters(cameraParameters,cameraParameters ,zeros(3,3), zeros(1,3))},1,n))
ResultData=StereoMatch(n,ResultData,FileNames1,FileNames2, StopCritVal); % Section 2.6.2
fprintf('\nFirst image set...\n');
ResultData.ProcData1=ImgCorr(n,ResultData.ProcData1, FileNames1, RefStrat,StopCritVal); % Section 2.6.1
fprintf('\nSecond image set...\n');
ResultData.ProcData2=ImgCorr(n,ResultData.ProcData2, FileNames2, RefStrat,StopCritVal); % Section 2.6.1
ResultData=CSTrans(n,ResultData,WorldCTs,ImgCTs,RefStrat); % Section 2.9