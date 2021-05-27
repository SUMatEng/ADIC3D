function RD=CSTrans(n,RD,WorldCTs,ImgCTs,RefStrat)
CamParams=estimateCameraParameters(ImgCTs,WorldCTs, 'NumRadialDistortionCoefficients',2); % Section 2.2
Q1=[CamParams.CameraParameters1.IntrinsicMatrix',[0; 0; 0]]*[[eye(3), [0;0;0]]; 0, 0, 0, 1];
Q2=[CamParams.CameraParameters2.IntrinsicMatrix',[0; 0; 0]]*[[CamParams.RotationOfCamera2', CamParams.TranslationOfCamera2']; 0, 0, 0, 1];
B=CamParams.FundamentalMatrix;
for d=1:n, tic
	Xds1=RD.ProcData1(d).Xos+[RD.ProcData1(d).P(1,:); RD.ProcData1(d).P(7,:)]; % Equation (49)
	Xds2=RD.ProcData2(d).Xos+[RD.ProcData2(d).P(1,:); RD.ProcData2(d).P(7,:)]; % Equation (49)
	indValid=find((isnan(Xds1(1,:))+isnan(Xds1(2,:)) +isnan(Xds2(1,:))+isnan(Xds2(2,:)))==0);
	if d==1|RefStrat==1
		RD.DispTrans(d).Xow(:,indValid)=Triangulation(B,Q1,Q2, UndistortPasser(RD.ProcData1(d).Xos(:,indValid)', CamParams.CameraParameters1)',UndistortPasser( RD.ProcData2(d).Xos(:,indValid)', CamParams.CameraParameters2)');
	else
		RD.DispTrans(d).Xow=RD.DispTrans(d-1).Xow;
	end	
	RD.DispTrans(d).Uw(:,indValid)=Triangulation(B,Q1,Q2, UndistortPasser(Xds1(:,indValid)', CamParams.CameraParameters1)',UndistortPasser(Xds2(:, indValid)', CamParams.CameraParameters2)')-RD.DispTrans(d).Xow (:,indValid); % Equation (51)
	RD.DispTrans(d).CamParams=CamParams;
	fprintf('CS transformation image: %d/%d\t\ttime:%.3f\n',d,n,toc);
end