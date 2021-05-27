function RD=StereoMatch(n,RD,ImNames1,ImNames2,StopCritVal)
SubExtract=@(Mat,Xos,SubSize) Mat(Xos(2)-(SubSize-1)/2: Xos(2)+(SubSize-1)/2,Xos(1)-(SubSize-1)/2:Xos(1)+(SubSize-1)/2); tic;
F=im2double(imread(ImNames1{1}));
if all(RD.ProcData1(1).ImgFilt), F=imgaussfilt(F, RD.ProcData1(1).ImgFilt(1),'FilterSize', RD.ProcData1(1).ImgFilt(2)); end
G=im2double(imread(ImNames2{1}));
if all(RD.ProcData1(1).ImgFilt), G=imgaussfilt(G, RD.ProcData1(1).ImgFilt(1),'FilterSize', RD.ProcData1(1).ImgFilt(2)); end
InterpCoef=griddedInterpolant({1:1:size(G,1),1:1:size(G,2)}, G, 'spline');
[dFdx,dFdy]=imgradientxy(F, 'prewitt');
P=FeatureMatch(RD.ProcData1,1,F,G,SubExtract); % Section 3.3.2
C=NaN(1,size(P,2)); Iter=NaN(1,size(P,2)); StopVal=NaN(1,size(P,2));
for q=1:size(P,2) % can be changed to parfor for parallel processing
	if (sum(isnan(P(:,q)))==0)&&(sum(isnan(RD.ProcData1(1).Xos (:,q)))==0)
		[f,dfdx,dfdy,dX,dY]=SubShapeExtract( RD.ProcData1(1).SubSize(q),RD.ProcData1(1).SubShape(q,:) ,RD.ProcData1(1).Xos(:,q),F,dFdx,dFdy,SubExtract); % Section 3.2
		[Pout(:,q),C(q),Iter(q),StopVal(q)]=SubCorr(InterpCoef,f ,dfdx,dfdy,RD.ProcData1(1).SubSize(q), RD.ProcData1(1).SFOrder(q),RD.ProcData1(1).Xos(:,q),dX, dY,P(:,q), StopCritVal); % Section 3.2
	end
end
RD.Stereo.P=Pout; RD.Stereo.C=C; RD.Stereo.Iter=Iter; RD.Stereo.StopVal=StopVal;
for d=1:n % determine subset positions in the FIS2 using Equation (32)
	RD.ProcData2(d).Xos(1,:)=RD.ProcData2(d).Xos(1,:)+ round(RD.Stereo.P(1,:)); RD.ProcData2(d).Xos(2,:)= RD.ProcData2(d).Xos(2,:)+round(RD.Stereo.P(7,:));
end
FailedSubsetsCondition=(RD.Stereo.C>=0.6)==0|(RD.ProcData2(1) .Xos(1,:)+(RD.ProcData2(1).SubSize(:)'-1)/2>size(G,2))|( RD.ProcData2(1).Xos(1,:)-(RD.ProcData2(1).SubSize(:)'-1)/2<1) |(RD.ProcData2(1).Xos(2,:)+(RD.ProcData2(1).SubSize(:)'- 1)/2>size(G,1))|(RD.ProcData2(1).Xos(2,:)-(RD.ProcData2(1).SubSize(:)'-1)/2<1);
FailedSubsets=find(FailedSubsetsCondition); PassedSubsets=find(FailedSubsetsCondition==0);
for d=1:n
	RD.ProcData1(d).Xos(:,FailedSubsets)=NaN(2,size( FailedSubsets,2));
	RD.ProcData2(d).Xos(:,FailedSubsets)=NaN(2,size( FailedSubsets,2));
end
fprintf('Stereo results\t| Time (s)| CC (min) | CC (mean) | Iter (max)\n\t\t\t\t| %7.3f | % .5f | % .6f | %4.0f \nSubsets that failed stereo matching %d/%d\n',toc,min(RD.Stereo.C(PassedSubsets)), nanmean(RD.Stereo.C(PassedSubsets)),max(RD.Stereo.Iter( PassedSubsets)),size(FailedSubsets,2),size(P,2));