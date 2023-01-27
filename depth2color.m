function C=depth2color(V)

color=hsv(size(V,3));
C=zeros(size(V,1),size(V,2),3);
for i=1:size(V,3)
    C(:,:,1)=C(:,:,1)+V(:,:,i).*color(i,1);
    C(:,:,2)=C(:,:,2)+V(:,:,i).*color(i,2);
    C(:,:,3)=C(:,:,3)+V(:,:,i).*color(i,3);
end