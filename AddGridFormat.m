function RD=AddGridFormat(RD)
	for d=1:size(RD.ProcData1,2)
		% determine vectors to relate the subset position (in pixels in the distorted sensor CS) to its position within the grid matrices
		XindicesUnique=sort(ceil(unique(RD.ProcData1(d).Xos(1,:))));
		XindicesUnique(isnan(XindicesUnique))=[];
		Xindices=NaN(1,XindicesUnique(end));
		Xindices(XindicesUnique)=1:1:size(XindicesUnique,2);

		YindicesUnique=sort(ceil(unique(RD.ProcData1(d).Xos(2,:))));
		YindicesUnique(isnan(YindicesUnique))=[];
		Yindices=NaN(1,YindicesUnique(end));
		Yindices(YindicesUnique)=1:1:size(YindicesUnique,2);
		% convert the data to the format of grid matrices
		for q=1:size(RD.DispTrans(d).Xow,2)
			if isnan(RD.ProcData1(d).Xos(1,q))==0 % only process subset pairs that were successfully analysed by ADIC3D
				RD.Display(d).POSX(Yindices(ceil(RD.ProcData1(d).Xos(2,q))),Xindices(ceil(RD.ProcData1(d).Xos(1,q))))=RD.DispTrans(d).Xow(1,q); % grid matrix for the x-position of the subset in the world CS
				RD.Display(d).POSY(Yindices(ceil(RD.ProcData1(d).Xos(2,q))),Xindices(ceil(RD.ProcData1(d).Xos(1,q))))=RD.DispTrans(d).Xow(2,q); % grid matrix for the y-position of the subset in the world CS
				RD.Display(d).POSZ(Yindices(ceil(RD.ProcData1(d).Xos(2,q))),Xindices(ceil(RD.ProcData1(d).Xos(1,q))))=RD.DispTrans(d).Xow(3,q); % grid matrix for the z-position of the subset in the world CS
				RD.Display(d).UX(Yindices(ceil(RD.ProcData1(d).Xos(2,q))),Xindices(ceil(RD.ProcData1(d).Xos(1,q))))=RD.DispTrans(d).Uw(1,q); % grid matrix for the x-displacement in the world CS
				RD.Display(d).UY(Yindices(ceil(RD.ProcData1(d).Xos(2,q))),Xindices(ceil(RD.ProcData1(d).Xos(1,q))))=RD.DispTrans(d).Uw(2,q); % grid matrix for the y-displacement in the world CS
				RD.Display(d).UZ(Yindices(ceil(RD.ProcData1(d).Xos(2,q))),Xindices(ceil(RD.ProcData1(d).Xos(1,q))))=RD.DispTrans(d).Uw(3,q); % grid matrix for the y-displacement in the world CS
				CheckElements(Yindices(ceil(RD.ProcData1(d).Xos(2,q))),Xindices(ceil(RD.ProcData1(d).Xos(1,q))))=RD.ProcData1(d).Xos(1,q); % determine grid matrix of the x-position of the subset in the distorted sensor CS (used to identify grid matrix positions that do not have a corresponding subset that was analysed by ADIC#D)
			end
		end
		% set the values of the elements of the grid matrices, that do not correspond to an analysed subset, to NaN (such that they are not displayed)
		[r,c]=size(RD.Display(d).POSX);
		for i=1:r
			for j=1:c
				if CheckElements(i,j)==0
					RD.Display(d).POSX(i,j)=NaN;
					RD.Display(d).POSY(i,j)=NaN;
					RD.Display(d).POSZ(i,j)=NaN;
					RD.Display(d).UX(i,j)=NaN;
					RD.Display(d).UY(i,j)=NaN;
					RD.Display(d).UZ(i,j)=NaN;
				end
			end
		end
	end
end