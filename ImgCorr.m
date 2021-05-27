function PD=ImgCorr(n,PD,FileNames,RefStrat,StopCritVal)
SubExtract=@(Mat,Xos,SubSize) Mat(Xos(2)-(SubSize-1)/2: Xos(2)+(SubSize-1)/2,Xos(1)-(SubSize-1)/2:Xos(1)+(SubSize- 1)/2);
for d=2:n, tic; % outer loop
	G=im2double(imread(FileNames{d}));
	if all(PD(d).ImgFilt), G=imgaussfilt(G,PD(d).ImgFilt(1), 'FilterSize',PD(d).ImgFilt(2)); end
	InterpCoef=griddedInterpolant({1:1:size(G,1),1:1:size(G,2)} ,G, 'spline'); % Section 2.3.2
	if any([RefStrat==1,d==2])
		F=im2double(imread(FileNames{d-1}));
		if all(PD(d).ImgFilt), F=imgaussfilt(F,PD(d).ImgFilt(1) ,'FilterSize',PD(d).ImgFilt(2)); end
		[dFdx,dFdy]=imgradientxy(F,'prewitt');
		PD(d).Xos(1,:)=PD(d-1).Xos(1,:)+fix(PD(d-1).P(1,:));
		PD(d).Xos(2,:)=PD(d-1).Xos(2,:)+fix(PD(d-1).P(7,:));
		[PD(d).P(1,:),PD(d).P(7,:)]=arrayfun(@(XosX,XosY,SubSize )PCM(F,G,SubSize,XosX,XosY,SubExtract),PD(d).Xos(1,:), PD(d).Xos(2,:),PD(d).SubSize); % Section 3.4.1
	else
		PD(d).P=PD(d-1).P;
	end
	P=NaN(size(PD(d).P)); C=NaN(size(PD(d).C)); Iter=NaN(size(PD(d).C)); StopVal=NaN(size(PD(d).C));
	for q=1:size(PD(d).Xos,2) % inner loop (can be changed to parfor for parallel processing)
		if (sum(isnan(PD(d).P(:,q)))==0)&&(sum(isnan( PD(d).Xos(:,q)))==0)
			[f,dfdx,dfdy,dX,dY]=SubShapeExtract(PD(d).SubSize(q),  PD(d).SubShape(q,:),PD(d).Xos(:,q),F,dFdx,dFdy, SubExtract); % Section 3.2
			[P(:,q),C(q),Iter(q),StopVal(q)]=SubCorr(InterpCoef,f ,dfdx,dfdy,PD(d).SubSize(q),PD(d).SFOrder(q), PD(d).Xos(:,q),dX,dY,PD(d).P(:,q),StopCritVal); % Section 3.2
	       end
	end
PD(d).P=P; PD(d).C=C; PD(d).Iter=Iter; PD(d).StopVal=StopVal;
if rem(d-2,10)==0, fprintf('Image/Total| Time (s) | CC (min) | CC (mean) | Iter (max) \n'); end
fprintf(' %4.d/%4.d | %8.3f | %.6f | %.7f | %4.0f \n',d,n,toc,min(PD(d).C),nanmean(PD(d).C),max(PD(d).Iter));
end