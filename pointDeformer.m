function vfieldTotal=pointDeformer(moving,fixed,sigma,moving_loc,fixed_loc)
close all
% sigma=100;
myimfuse = @(x,y)(imfuse(x,y,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]));

% I=imread('cameraman.tif');axis equal;axis off
% imagesc(I);

if nargin<4
imagesc(10*myimfuse(moving,fixed));axis equal;axis off
title('Click successive pairs of matching landmarks - Chose RED first then GREEN  - right click when done');

[x,y]=getpts;
x(end)=[];
y(end)=[];


fixed_matches=round([x(mod(1:length(x),2)==1) y(mod(1:length(x),2)==1)]);
moving_matches=round([x(mod(1:length(x),2)==0) y(mod(1:length(x),2)==0)]);

else
    input_fixed_matches=round(moving_loc);
    input_moving_matches=round(fixed_loc);
end



% fixed_matches=round([x(1) y(1)]);
% moving_matches=round([x(2) y(2)]);

vfield=repmat(zeros(size(moving)),[1 1 2]);

for i=1:size(moving_matches,1)
vfield(moving_matches(i,2),moving_matches(i,1),2)=fixed_matches(i,2)-moving_matches(i,2);
vfield(moving_matches(i,2),moving_matches(i,1),1)=fixed_matches(i,1)-moving_matches(i,1);
end

for i=1:size(vfield,3)
    vfield(:,:,i)=imgaussfilt(vfield(:,:,i),sigma,'FilterDomain','auto','FilterSize',4*ceil(2*sigma)+1);
end

% for i=1:size(moving_matches,1)
% vfield(moving_matches(i,2)-20:moving_matches(i,2)+20,moving_matches(i,1)-20:moving_matches(i,1)+20,1)=fixed_matches(i,1)-moving_matches(i,1);
% vfield(moving_matches(i,2)-20:moving_matches(i,2)+20,moving_matches(i,1)-20:moving_matches(i,1)+20,2)=fixed_matches(i,2)-moving_matches(i,2);
% end


subplot(2,3,1)
imagesc(10*myimfuse(moving,fixed));axis equal;axis off
hold on
plot(moving_matches(:,1),moving_matches(:,2),'r.','MarkerSize',15);
plot(fixed_matches(:,1),fixed_matches(:,2),'g.','MarkerSize',15);
subplot(2,3,2)
imagesc(vfield(:,:,1));axis equal;axis off;title('X-displacement');colorbar
hold on
plot(moving_matches(:,1),moving_matches(:,2),'r.','MarkerSize',15);
plot(fixed_matches(:,1),fixed_matches(:,2),'g.','MarkerSize',15);
subplot(2,3,3)
imagesc(vfield(:,:,2));axis equal;axis off;title('Y-displacement');colorbar
hold on
plot(moving_matches(:,1),moving_matches(:,2),'r.','MarkerSize',15);
plot(fixed_matches(:,1),fixed_matches(:,2),'g.','MarkerSize',15);

for d=1:2
for i=1:size(moving_matches,1)
    A(i,d)=vfield(moving_matches(i,2),moving_matches(i,1),d);
    b(i,d)=fixed_matches(i,d)-moving_matches(i,d);
end
    step(1,1,d)=linsolve(A(:,d),b(:,d));
end
  
step(or(isnan(step),isinf(step)))=0;

% step(1,1,1)=1;
% step(1,1,2)=1;

vfieldTotal=vfield.*step;
moving_warped=imwarp(moving,vfieldTotal);
moving_matches_moved=zeros(size(moving_matches));
for d=1:2
for i=1:size(moving_matches,1)
moving_matches_moved(i,d)=moving_matches(i,d)+vfield(moving_matches(i,2),moving_matches(i,1),d)*step(d);
end
end



subplot(2,3,4)
imagesc(10*myimfuse(moving_warped,fixed));axis equal;axis off
hold on
plot(fixed_matches(:,1),fixed_matches(:,2),'g.','MarkerSize',15);
plot(moving_matches_moved(:,1),moving_matches_moved(:,2),'r.','MarkerSize',15);

subplot(2,3,5)
imagesc(vfield(:,:,1)*step(1));axis equal;axis off;title('X-displacement');colorbar
hold on
plot(moving_matches(:,1),moving_matches(:,2),'r.','MarkerSize',15);
plot(fixed_matches(:,1),fixed_matches(:,2),'g.','MarkerSize',15);
subplot(2,3,6)
imagesc(vfield(:,:,2)*step(2));axis equal;axis off;title('Y-displacement');colorbar
hold on
plot(moving_matches(:,1),moving_matches(:,2),'r.','MarkerSize',15);
plot(fixed_matches(:,1),fixed_matches(:,2),'g.','MarkerSize',15);
end