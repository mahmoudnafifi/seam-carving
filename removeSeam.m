function [newImg,mask] = removeSeam( img, seam , type,mask )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%removeSeam function: remove given seam from the input image (img)
%Usage:
%    newImg = removeSeam( img, seam,'h');  %remove horizontal seam from the image
%    newImg = removeSeam( img, seam,'h');  %remove vertical seam from the image
%Input:
%   -img: input image
%   -seam: the interesting seam, that is extracted from getSeams function
%   -type: 'H' for horizontal seams - 'V' for vertical seams
%Output:
%   -newImg: new image after removing the seam
%   -mask: markup mask after removing pixels
%Citation: Avidan, Shai, and Ariel Shamir. "Seam carving for content-aware
%image resizing. ACM Transactions on graphics (TOG). Vol. 26. No. 3.
%ACM, 2007"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Mahmoud Afifi, York University.

if nargin<3
    error('Too few input arguments');
elseif nargin<4
    mask=zeros(size(img,1),size(img,2));
end


switch lower(type)
    case 'h'
        newSize=[size(img,1)-1,size(img,2)]; %new image's size
        T=0; %no transpose
    case 'v'
        %transpose img and seam
        img_=zeros(size(img,2),size(img,1),size(img,3)); %memory allocation
        for c=1:size(img,3)
            img_(:,:,c)=img(:,:,c)'; %image transpose
           
        end
        img=img_;
        mask=mask';
        clear img_; %delete temp object 
        newSize=[size(img,1)-1,size(img,2)]; %new image's size
        s_(1,:,2)=seam(1,:,1); %transpose seam object as well
        s_(1,:,1)=seam(1,:,2);
        seam=s_;
        clear s_; %delete temp object
        T=1; %raise transpose flag
end

%convert indices to linear indices
linearInd=sub2ind([size(img,1),size(img,2)], seam(:,:,1), seam(:,:,2));
%get linear indicies of residual pixels
C=setdiff([1:size(img,1)*size(img,2)],linearInd);
newGray=zeros(length(C),size(img,3)); %memory allocation
newImg=zeros(newSize(1),newSize(2),size(img,3));  %memory allocation
mask=mask(:);
mask=mask(C);
mask=reshape(mask,newSize);
for c=1:size(img,3)
    gray=img(:,:,c); %get current color channel
    gray=gray(:); %convert it to a 1-D vector
    newGray(:,c)=gray(C); %get residual pixels only
    newImg(:,:,c)=reshape(newGray(:,c),newSize); %reshape 
end

if T==1 %remove the effect of transpose
    img_=zeros(size(newImg,2),size(newImg,1),size(newImg,3)); %memory allocation
    for c=1:size(img,3) 
        img_(:,:,c)=newImg(:,:,c)'; %transpose
    end
    newImg=img_;
    mask=mask';
    clear img_; %delete temp object
end
newImg=uint8(newImg); %convert image to uint8
end

