clc;clear;close all;

T=3;
height=120;
width=240;
errorThresh=0.0354;
% We will sub sample frames from the 
% bottom left
video = mmread('../cars.avi',1:T,[],false,true);

frames = zeros([height width T]);

for i=1:T
    frames(:,:,i)=im2gray(im2double(video.frames(i).cdata(end-height+1:end,end-width+1:end,:)));
end

% Decides which pixel goes to which frame
code_dist = randi([1 T], [height width]);

% hwt_code will store the binary coding
hwt_code = zeros([height width T]);
for i=1:height
    for j=1:width
        hwt_code(i,j,code_dist(i,j))=1;
    end
end

coded_snapshot = zeros([height width]);
for i=1:T
    coded_snapshot = coded_snapshot + hwt_code(:,:,i).*frames(:,:,i);
end

% Adding Gaussian noise to the snapshot. Bringing standard deviation of 2 
% as mentioned in the 0-255 scale into the 0-1 scale.
coded_snapshot = imnoise(coded_snapshot,'gaussian',0,(2/255)^2); 

% Uncomment the line below to show the coded_snapshot
figure; imshow(coded_snapshot); title(['Coded Snapshot for ',num2str(T),' frames']);

% Let's reconstruct our video of T frames
finalvid=zeros([height width T]);

% Get the inverse DCT Basis
invdct=dctmtx(8*8*T);
invdct=invdct';

for i=1:height-8+1
    for j=1:width-8+1
        % Sample the required part of the Coded Snapshot
        j_vect=coded_snapshot(i:i+7,j:j+7);
        j_vect=reshape(j_vect,[8*8 1]);
        
        % Sample the required subset of the binary code
        hwt_code_subset=hwt_code(i:i+7,j:j+7,:);
        hwt_subset_new=reshape(hwt_code_subset, [8*8 T]);
        
        % Get the concatenated diagonal matrices
        phimat=zeros([8*8 8*8*T]);
        for ii=1:T
            phimat(:,ii*64-63:ii*64)=diag(hwt_subset_new(:,ii));
        end
        
        % Get the reconstructed solution using the OMP implementation. Its
        % present in omp.m
        theta = omp(phimat*invdct,j_vect,errorThresh); 
        
        % Reconstruct the original signal using a idct(theta) which is
        % basically same as invdct*theta
        reconstructedmat=invdct*theta;
        f1=reshape(reconstructedmat,[8 8 T]);
        
        % Add the parts since they are overlapping
        finalvid(i:i+7,j:j+7,:) = finalvid(i:i+7,j:j+7,:) + f1;
    end
end

% Get dividing row and column to get the mean of each pixel.

% Row(1 x width): 1 2 3 4 5 6 7 8 8 ... 8 8 7 6 5 4 3 2 1
averager_row=zeros([1 width]);
averager_row(1:7)=1:7;
averager_row(8:end)=8;
averager_row(end-7+1:end)=averager_row(end-7+1:end)-averager_row(1:7);

% Column(height x 1): (1 2 3 4 5 6 7 8 8 ... 8 8 7 6 5 4 3 2 1)'
averager_col=zeros([height 1]);
averager_col(1:7)=1:7;
averager_col(8:end)=8;
averager_col(end-7+1:end)=averager_col(end-7+1:end)-averager_col(1:7);

% Average out all the overlapping pixels! We have out final video matrix
% of T frames.
finalvid=finalvid./averager_row;
finalvid=finalvid./averager_col;

% Uncomment lines below to show the frames
for fremnum=1:T
    figure; imshow(finalvid(:,:,fremnum));
end

% Error calculation. Self-explanatory code.
% We are finding error between frames and finalvid
reconstruction_error=frames-finalvid;
rmse=(norm(reconstruction_error(:))^2)/(norm(frames(:))^2);

disp(['Relative Mean Squared Error of Reconstruction: ',num2str(rmse)]);