function [P]=FeatureMatch(PD,d,F,G,SubExtract)
if exist('vl_sift')~=3, fprintf('\nError occurred, please setup the VLFeat library required for SIFT feature matching (algorithm can be found at: https://www.vlfeat.org\n'); end; time_before_sift=toc;
[xk1,d1] = vl_sift(im2single(uint8(255 * F)));
[xk2,d2] = vl_sift(im2single(uint8(255 * G)));
KptsInVacinity=((abs(PD(d).Xos(2,:)-xk1(2,:)')<=PD(d).SubSize /2) +(abs(PD(d).Xos(1,:)-xk1(1,:)')<=PD(d).SubSize/2))==2;
xk1=xk1(:,sum(KptsInVacinity,2)>=1); d1=d1(:,sum(KptsInVacinity,2)>=1);
[matches, scores] = vl_ubcmatch(d1, d2,1.25);
	xk1=xk1(1:2,matches(1,:))';	xk2=xk2(1:2,matches(2,:))';
relevantKpts=knnsearch(xk1,PD(d).Xos','K',20);
RansacModel=@(kpts) [[kpts(:,1) kpts(:,2) ones(size(kpts(:,1) ,1),1)]\kpts(:,3)-[1; 0; 0];[kpts(:,1) kpts(:,2) ones(size (kpts(:,1),1),1)]\kpts(:,4)-[0; 1; 0]]; % solves for affine transformation parameters of Equation (29)
RansacError=@(a, kpts) sum((kpts(:,3:4)'-[1+a(1), a(2), a(3); a(4), 1+a(5), a(6)]*[kpts(:,1)'; kpts(:,2)';ones(1, size(kpts(:,1)',2))]).^2,1); % Equation(30)
P=NaN(12,size(PD(d).Xos,2));
for q=1:size(PD(d).Xos,2) % can be changed to parfor for parallel processing
	try
		[a,~] = ransac([xk1(relevantKpts(q,:),:),xk2( relevantKpts(q,:),:)], @(data) RansacModel(data), @(model,data) RansacError(model,data), 3,1,'Confidence', 99.5);
		P(:,q)=[a(1)*PD(d).Xos(1,q)+a(2)*PD(d).Xos(2,q)+a(3); a(1); a(2); 0; 0; 0;a(4)*PD(d).Xos(1,q)+a(5)*PD(d).Xos(2,q)+a(6); a(4); a(5); 0; 0; 0]; % Equation (31)
	end
end
fprintf('SIFT found %d matching keypoints in %5.2f seconds\n',size(matches,2),toc-time_before_sift);