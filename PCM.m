function [u,v]=PCM(F,G,SubSize,XosX,XosY,SubExtract)
if (isnan(XosX)==0)&&(isnan(XosY)==0)
	NCPS=(fft2(SubExtract(F,[XosX,XosY],SubSize)).*conj (fft2(SubExtract(G,[XosX,XosY],SubSize))))./abs(fft2( SubExtract(F,[XosX,XosY],SubSize)).*conj(fft2(SubExtract (G,[XosX,XosY],SubSize))));
	CC=(ifft2(NCPS));
	[vid,uid]=find(CC==max(CC(:)));
	IndShift=-ifftshift(-fix(SubSize/2):ceil(SubSize/2)-1);
	u=IndShift(uid);
	v=IndShift(vid);
else
	u=NaN; v=NaN;
end