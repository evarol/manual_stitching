clear all
close all
clc


%% paths to utilities + functions
addpath ./tiff_loading/utilities
addpath(genpath('./tiff_loading/Fiji.app'));
javaaddpath('./tiff_loading/Fiji.app/mij.jar');
myimfuse = @(x,y)(imfuse(x,y,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]));
strpart = @(x,y)(x{y});
%% loading files + manual transformations
disp('Select images to stitch (IMPORTANT: click on them sequentially in increasing order)');
[file,path] = uigetfile('*.tif','MultiSelect','on');

for i=1:length(file)
    filename{i}=[path file{i}];
end

for i=1:length(filename)
    I{i}=double(load_tiff(filename{i}));
    i
end

for i=(length(file)):-1:2
    tforms{i}=load([path strpart(strsplit(file{i},'.'),1) '_to_' strpart(strsplit(file{i-1},'.'),1) '_deformable_tform.mat']);
end

dims=zeros(1,3);
for i=1:length(I)
    dims=max([dims; size(I{i})],[],1);
end

for i=1:length(I)
    I{i}=padarray(I{i},[dims(1)-size(I{i},1) dims(2)-size(I{i},2) 0],'post');
end

for i=2:length(tforms)
    for d=1:2
        tforms{i}.vfieldTotal=padarray(tforms{i}.vfieldTotal,[dims(1)-size(tforms{i}.vfieldTotal,1) dims(2)-size(tforms{i}.vfieldTotal,2) 0],'post');
    end
end

%% composing rigid + deformable transformations per slice

for i=2:length(tforms)
    [ufield_rigid,~,coormap]=rigid2ufield(tforms{i}.globTform,zeros(size(tforms{i}.vfieldTotal)));
    ufield_deformable=tforms{i}.vfieldTotal;
    tic;
    total_ufield{i}=composeUfields(ufield_rigid,ufield_deformable,coormap,1);
    toc
end

total_ufield{1}=zeros(size(total_ufield{end}));
backtracked_ufield{1,1}=zeros(size(coormap));
total_rotation{1}=eye(3);
registered{1}=I{1};
rigid_registered{1}=I{1};


%% back tracking transformations for each slice to slice 1
for i=2:length(tforms)
    for z=1:size(I{i},3)
        registered{i}(:,:,z)=I{i}(:,:,z);
    end
    backtracked_ufield{i,i-1}=total_ufield{i};
    for z=1:size(I{i},3)
        registered{i}(:,:,z)=imwarp(registered{i}(:,:,z),total_ufield{i});
    end
    
    total_rotation{i}=eye(3);
    if i>2
        for j=(i-1):-1:2
            tic
            backtracked_ufield{i,j-1}=composeUfields(backtracked_ufield{i,j},total_ufield{j},coormap,1);
            total_rotation{i}=tforms{j}.globTform*total_rotation{i};
            for z=1:size(I{i},3)
                registered{i}(:,:,z)=imwarp(registered{i}(:,:,z),total_ufield{j});
            end
            toc
            [i j]
        end
    end
    
end


for i=1:length(I)
    for z=1:size(I{i},3)
        rigid_registered{i}(:,:,z)=imwarp(I{i}(:,:,z),affine2d(total_rotation{i}),"OutputView",imref2d(size(I{i}(:,:,1))));
    end
end

%% Pairwise aligned slices
figure(1)
for i=1:length(I)-1
    ax1(i)=subplot(2,5,i);
    imagesc(10*myimfuse(I{i}(:,:,1),imwarp(I{i+1}(:,:,1),total_ufield{i+1})));
    title(['Pairwise: Red: Slice ' num2str(i) ' - Green: Slice ' num2str(i+1)]);drawnow
    set(gca,'FontSize',14,'FontWeight','bold');
end
set(gcf,'color','w');
linkaxes(ax1)


%% Globally aligned slices
figure(2)
for i=1:length(I)
    ax2(i)=subplot(2,5,i);
    imagesc(10*myimfuse(I{1}(:,:,1),registered{i}(:,:,1)));
    title(['Global: Red: Slice 1 - Green: Slice ' num2str(i)]);drawnow
    set(gca,'FontSize',14,'FontWeight','bold');
end
set(gcf,'color','w');
linkaxes(ax2)

%% save data

for i=1:length(I)
    disp(['Saving aligned slice ' num2str(i)]);
    im=registered{i};
    save([path strpart(strsplit(file{i},'.'),1) '_to_' strpart(strsplit(file{1},'.'),1) '_globally_deformed.mat'],'im');
end
