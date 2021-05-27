function [ptsOut]=Triangulation(B,Q1,Q2,pts1,pts2)
for i=1:size(pts1,2)
	T1inv=[1, 0, pts1(1,i); 0, 1, pts1(2,i); 0, 0, 1]; % Equation (35)
	T2inv=[1, 0, pts2(1,i); 0, 1, pts2(2,i); 0, 0, 1]; % Equation (35)
	B1=T2inv'*B*T1inv; % Equation (36)
	[U,~,V]=svd(B1,0);
	e1=V(:,3)./norm(V(1:2,3));
	e2=U(:,3)./norm(U(1:2,3));
	R1=[e1(1), e1(2), 0; -e1(2), e1(1), 0; 0, 0, 1]; % Equation (37)
	R2=[e2(1), e2(2), 0; -e2(2), e2(1), 0; 0, 0, 1]; % Equation (37)
	B2=R2*B1*R1'; % Equation (38)
	phi_1=B2(2,2); phi_2=B2(2,3); phi_3=B2(3,2); phi_4=B2(3,3);
	p=[- phi_4*phi_1^2*phi_3*e1(3)^4 + phi_2*phi_1*phi_3^2*e1(3)^4, phi_1^4 + 2*phi_1^2*phi_3^2*e2(3)^2 - phi_1^2*phi_4^2*e1(3)^4 + phi_2^2*phi_3^2*e1(3)^4 + phi_3^4*e2(3)^4, 4*phi_1^3*phi_2 - 2*phi_1^2*phi_3*phi_4*e1(3)^2 + 4*phi_1^2*phi_3*phi_4*e2(3)^2 + 2*phi_1*phi_2*phi_3^2*e1(3)^2 + 4*phi_1*phi_2*phi_3^2*e2(3)^2 - phi_1*phi_2*phi_4^2*e1(3)^4 + phi_2^2*phi_3*phi_4*e1(3)^4 + 4*phi_3^3*phi_4*e2(3)^4, 6*phi_1^2*phi_2^2 - 2*phi_1^2*phi_4^2*e1(3)^2 + 2*phi_1^2*phi_4^2*e2(3)^2 + 8*phi_1*phi_2*phi_3*phi_4*e2(3)^2 + 2*phi_2^2*phi_3^2*e1(3)^2 + 2*phi_2^2*phi_3^2*e2(3)^2 + 6*phi_3^2*phi_4^2*e2(3)^4, - phi_1^2*phi_3*phi_4 + 4*phi_1*phi_2^3 + phi_1*phi_2*phi_3^2 - 2*phi_1*phi_2*phi_4^2*e1(3)^2 + 4*phi_1*phi_2*phi_4^2*e2(3)^2 + 2*phi_2^2*phi_3*phi_4*e1(3)^2 + 4*phi_2^2*phi_3*phi_4*e2(3)^2 + 4*phi_3*phi_4^3*e2(3)^4, - phi_1^2*phi_4^2 + phi_2^4 + phi_2^2*phi_3^2 + 2*phi_2^2*phi_4^2*e2(3)^2 + phi_4^4*e2(3)^4, phi_3*phi_2^2*phi_4 - phi_1*phi_2*phi_4^2];
	r=roots(p); % determine roots of polynomial of Equation (43)
	r=r(imag(r)==0);
	Ds=r.^2./(1+(r.*e1(3)).^2)+(phi_3.*r+phi_4).^2./((phi_1.*r +phi_2).^2+e2(3)^2*(phi_3.*r+phi_4).^2); % Equation (42)
	[t]=min(Ds);
	pts1temp=T1inv*R1'*[t^2*e1(3); t; t^2*e1(3)^2+1]; % Equation (44)
	pts2temp=T2inv*R2'*[e2(3)*(phi_3*t+phi_4)^2; -(phi_1*t+phi_2)*(phi_3*t+phi_4); (phi_1*t+phi_2)^2+e2(3)^2*(phi_3*t+phi_4)^2]; % Equation (45)
	ptsOut1=pts1temp(1:2)./pts1temp(3); ptsOut2=pts2temp(1:2)./pts2temp(3);
	[~,~,V]=svd([ptsOut1(1)*Q1(3,:)-Q1(1,:); ptsOut1(2)* Q1(3,:)-Q1(2,:); ptsOut2(1)*Q2(3,:)-Q2(1,:); ptsOut2(2)* Q2(3,:)-Q2(2,:)],0); % Section 2.8
	ptsOut(:,i)=V(1:3,4)./V(4,4);
end