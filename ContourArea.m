function [ A ] = ContourArea( C )
%[ A ] = ContourArea( C )
%   C is a 2*n matrix corresponding to the output of the low-level contourc
%   function. A is a 2*m matrix, the first line corresponding to the m
%   heights specified in C and the second line corresponding to the output
%   of Polyarea of each contour.
Clength = length(C);
A=zeros(2,50);
ind=1;
i=1;
while ind<=Clength
    height=C(1,ind);
    Incr=C(2,ind);
    V=C(1:2,ind+1:ind+Incr);
    A(1,i)=height;
    A(2,i)=polyarea(V(1,:),V(2,:));
    ind=ind+Incr+1;
    i=i+1;
end
A(:,i:end)=[];