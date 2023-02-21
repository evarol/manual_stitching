function [ufield,phifield,coormap]=rigid2ufield(rigidTform,ref)

[X,Y]=meshgrid(1:size(ref,1),1:size(ref,2));
X=permute(X,[2 1]);
Y=permute(Y,[2 1]);
coors0=[X(:) Y(:)];

coorsTformed=(coors0-rigidTform(3,[2 1]))*rigidTform(1:2,1:2);
ufield=zeros(size(ref));
phifield=zeros(size(ref));
coormap=zeros(size(ref));
for d=1:size(ref,3)
    ufield(:,:,d)=reshape(coorsTformed(:,d)-coors0(:,d),size(ref(:,:,d)));
    phifield(:,:,d)=reshape(coorsTformed(:,d),size(ref(:,:,d)));
    coormap(:,:,d)=reshape(coors0(:,d),size(ref(:,:,d)));
end
ufield=ufield(:,:,[2 1]);
phifield=phifield(:,:,[2 1]);
coormap=coormap(:,:,[2 1]);
end