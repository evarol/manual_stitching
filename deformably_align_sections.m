clear all
close all
clc

%%% PARAMETERS
sigma=200; %% Width of deformation field - larger: smoother deformation

%% paths to utilities + functions
addpath ./tiff_loading/utilities
addpath(genpath('./tiff_loading/Fiji.app'));
javaaddpath('./tiff_loading/Fiji.app/mij.jar');
myimfuse = @(x,y)(imfuse(x,y,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]));
strpart = @(x,y)(x{y});
%%
disp('Select pair of images to align');
[file,path] = uigetfile('*.tif','MultiSelect','on');

for i=1:length(file)
    filename{i}=[path file{i}];
end

for i=1:length(filename)
    I{i}=double(load_tiff(filename{i}));
    i
end

dims=zeros(1,3);
for i=1:length(I)
    dims=max([dims; size(I{i})],[],1);
end

for i=1:length(I)
    I{i}=padarray(I{i},[dims(1)-size(I{i},1) dims(2)-size(I{i},2) 0],'post');
end

sliceA=1;
sliceB=2;

I1slice=I{sliceA}(:,:,1);
I2slice=I{sliceB}(:,:,end);
I2slice_warped=I2slice;

notGood=1;
rigid=1;
affine=0;
globTform=[eye(2) zeros(2,1);zeros(1,2) 1];
while notGood==1
    close all
    imagesc(10*imfuse(I1slice,I2slice_warped,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]));
    title('Click successive pairs of matching landmarks - Chose RED first then GREEN  - right click when done');
    
    [x,y]=getpts;
    
    x(end)=[];
    y(end)=[];
    
    matches1=[x(mod(1:length(x),2)==1) y(mod(1:length(x),2)==1)];
    matches2=[x(mod(1:length(x),2)==0) y(mod(1:length(x),2)==0)];

    
    if rigid==1
        [R,T]=wahba(matches2,matches1);
        tform=affine2d([R zeros(2,1);T 1]);
    elseif affine==1
        beta=linsolve([matches2 ones(size(matches2,1),1)],matches1);
        tform=affine2d([beta(1:2,:) zeros(2,1);beta(3,:) 1]);
    end
    
    globTform=tform.T*globTform;
    
    I2slice_warped=imwarp(I2slice,affine2d(globTform),"OutputView",imref2d(size(I1slice)));
    close all
    imagesc(10*imfuse(I1slice,I2slice_warped,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]));
    switch input('Is it good enough? (1 for yes) Do you want to switch to affine? (2 for affine)? Do you want to switch to rigid? (3 for rigid)');
        case 1
            notGood=0;
            
        case 2
            rigid=0;
            affine=1;
        case 3
            rigid=1;
            affine=0;
    end
    
    
end



close all
tform=affine2d(globTform);
I2slice_globtform=imwarp(I2slice,tform,"OutputView",imref2d(size(I1slice)));
imagesc(10*myimfuse(I2slice_globtform,I1slice));

for i=1:size(I{sliceB},3)
    I2transformed(:,:,i)=imwarp(I{sliceB}(:,:,i),tform,"OutputView",imref2d(size(I1slice)));
end
I1=I{sliceA};
I2=I{sliceB};

vfieldTotal=pointDeformerIterative(I2transformed(:,:,8),I1(:,:,1),sigma);
close all

for i=1:size(I{sliceB},3)
    I2transformed_warped(:,:,i)=imwarp(I2transformed(:,:,i),vfieldTotal);
end


[ax, ~] = tight_subplot(1, 3, [0.01 0.01], 0.1,0.1);
axes(ax(1));
imagesc(10*myimfuse(I2(:,:,8),I1(:,:,1)));title('Unregistered');axis equal;axis off;text(100,100,'Unregistered','color','w','FontWeight','bold','FontSize',20);
axes(ax(2))
imagesc(10*myimfuse(I2transformed(:,:,8),I1(:,:,1)));title('Rigid/Affine');axis equal;axis off;text(100,100,'Rigid/affine','color','w','FontWeight','bold','FontSize',20);
axes(ax(3))
imagesc(10*myimfuse(I2transformed_warped(:,:,8),I1(:,:,1)));title('Deformable');axis equal;axis off;text(100,100,'Deformable','color','w','FontWeight','bold','FontSize',20);
linkaxes([ax(1) ax(2) ax(3)]);
set(gcf,'color','w');


save([path strpart(strsplit(file{sliceB},'.'),1) '_to_' strpart(strsplit(file{sliceA},'.'),1) '_deformable_tform.mat'],'globTform','vfieldTotal');
save([path strpart(strsplit(file{sliceB},'.'),1) '_to_' strpart(strsplit(file{sliceA},'.'),1) '_deformed.mat'],'I2transformed_warped');



