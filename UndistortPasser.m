function XosOut=UndistortPasser(Xos,CamParams)
n=size(Xos,1);
iterations=floor(n/100);
for i=1:iterations
	XosOut((i-1)*100+1:i*100,:)=undistortPoints(Xos((i - 1)*100+1:i*100,:),CamParams);
end
if rem(n,100)>0
	XosOut(iterations*100+1:iterations*100+rem(n,100),:)= undistortPoints(Xos(iterations*100+1:iterations*100+rem(n, 100),:),CamParams);
end