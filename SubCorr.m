function [P,C,Iter,StopVal]=SubCorr(InterpCoef,f,dfdx,dfdy,SubSize, SFOrder,Xos,dX,dY,P,StopCritVal)
[W,dFdWdP,SFPVec2Mat,Mat2SFPVec,StopCrit]=SFExpressions( SFOrder); % Section 3.2
dfdWdP=dFdWdP(dX(:),dY(:),dfdx(:),dfdy(:));
Hinv=inv(dfdWdP'*dfdWdP); % inverse of Equation (19)
f_bar=mean(f(:)); f_tilde=sqrt(sum((f(:)-f_bar).^2)); % Equations (13) and (14)
flag=0; Iter=1; dP=ones(size(P));
while flag==0
	[dXY]=W(dX(:),dY(:),P); % Equation (7)
	g=InterpCoef(Xos(2).*ones(size(dXY,1),1)+dXY(:,2), Xos(1).*ones(size(dXY,1),1)+dXY(:,1));
	g_bar=mean(g(:)); g_tilde=sqrt(sum((g(:)-g_bar).^2)); % Equations (13) and (14)
	StopVal=StopCrit(dP,(SubSize-1)/2); % Equation (23)
	if any([StopVal<StopCritVal,Iter>=100])
		flag=1;
		C=1-sum(((f(:)-f_bar)/f_tilde-(g(:)-g_bar)/g_tilde).^2) /2; % Equation (12) substituted into Equation (15)
	else
		J=dfdWdP'*(f(:)-f_bar-f_tilde/g_tilde*(g(:)-g_bar)); % Summation of Equation (18)
		dP([1:SFOrder*3+0^SFOrder 7:6+SFOrder*3+0^SFOrder])=-Hinv*J; % Equation (18)
		P=Mat2SFPVec(SFPVec2Mat(P)/SFPVec2Mat(dP)); % Equation (21)
	end
	Iter=Iter+1;
end