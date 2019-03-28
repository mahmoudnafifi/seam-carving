function [newImg,newImg2,mask] = addSeam( img, seam , type, img2, mask)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%addSeam function: duplicate given seam in the input image (img)
%Usage:
%    newImg = addSeam( img, seam,'v'); %add vertical seam to the image
%    newImg = addSeam( img, seam,'v'); %add horizontal seam to the image
%   [newImg,seamImg]=addSeam(img,seam,'v'); %here you receive seamImg which
%   contains the same image but with a colored (random color) seam on it.
%   [newImg,seamImg]=addSeam(image1,seam,'v',image2); %here you receive seamImg
%   which contains image2 but with a colored (random color). Note: image2
%   should have the same dimensions of image1.
%Input:
%   -img: input image
%   -seam: the interesting seam, that is extracted from getSeams function
%   -type: 'H' for horizontal seams - 'V' for vertical seams
%   -img2: if you want to draw the new seam on another image 
%   (with the same dimensions of img object), use it. Otherwise, you can
%   use the same image object for both img and img2. (default img2=img).
%   -mask: markup mask 
%Output:
%   -newImg: new image after adding the seam
%   -newImg2: new image after adding noticable seam
%   -mask: markup mask after adding new pixels
%Citation: Avidan, Shai, and Ariel Shamir. "Seam carving for content-aware
%image resizing. ACM Transactions on graphics (TOG). Vol. 26. No. 3.
%ACM, 2007"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Mahmoud Afifi, York University.

if nargin<3
    error('Too few input arguments');
elseif nargin<4 
    img2=img;
    mask=zeros(size(img,1),size(img,2));
elseif nargin<5
    mask=zeros(size(img,1),size(img,2));
end

switch lower(type)
    case 'h'
        newSize=[size(img,1)+1,size(img,2)]; %new size
        T=0; %no transpose
    case 'v'
        %transpose img and seam
        img_=zeros(size(img,2),size(img,1),size(img,3)); %memory allocation
        img_2=zeros(size(img2,2),size(img2,1),size(img2,3)); %memory allocation
        
        for c=1:size(img,3)
            img_(:,:,c)=img(:,:,c)'; %image transpose
            img_2(:,:,c)=img2(:,:,c)'; %image transpose
        end
        img=img_;
        img2=img_2;
        mask=mask';
        clear img_ img_2; %delete temp obj
        newSize=[size(img,1)+1,size(img,2)]; %get new image's size
        s_(1,:,2)=seam(1,:,1); %transpose seam as well
        s_(1,:,1)=seam(1,:,2);
        seam=s_;
        clear s_; %delete temp object
        T=1; %raise transpose flag
end

%convert indices to linear indices
linearInd=sub2ind([size(img,1),size(img,2)], seam(:,:,1), seam(:,:,2));
C=sort(cat(2,[1:size(img,1)*size(img,2)],linearInd)); %doublicate seam indicies
newInd=zeros(size(linearInd)); %memory allocation
for i=1:length(linearInd)
    ind=find(C==linearInd(i)); %get the location of interesting pixels in the new image
    newInd(i)=ind(1); %take first index
end
newGray=zeros(length(C),size(img,3)); %memory allocation
newGray2=zeros(length(C),size(img,3)); %memory allocation
newImg=zeros(newSize(1),newSize(2),size(img,3)); %memory allocation of new image
newImg2=zeros(newSize(1),newSize(2),size(img,3)); %memory allocation of new image
mask=mask(:);
mask=mask(C);
mask=reshape(mask,newSize);
for c=1:size(img,3)
    gray=img(:,:,c); %get current color channel
    gray=gray(:); %to 1-D vector
    gray2=img2(:,:,c);
    gray2=gray2(:);
    newGray(:,c)=gray(C); %get pixel intensities of new image (current color channel)
    newGray2(:,c)=gray2(C);
    %manipulate the intensity of new pixels
    newInd_previous=newInd-1; %get the index of previous pixels
    newInd_next=newInd+1; %get the index of next pixels
    newInd_previous(newInd_previous==0)=newInd_previous(newInd_previous==0)+1; %if index<0 don't change it
    newInd_next(newInd_next>newSize(1)*newSize(2))=...
    newInd_next(newInd_next>newSize(1)*newSize(2))-1; %if index>end don't change it
%   %new pixel=average of previous and next pixel
%   newGray(newInd,c)=(newGray(newInd_next,c)+newGray(newInd_previous,c))/2;
    %for newImg2, we want to add noticable seams, so make it=random value
    newGray2(newInd,c)=abs(newGray2(newInd,c)-randi(255));
    newGray2(newInd_previous,c)=randi(255);
    newGray2(newInd_next,c)=abs(newGray2(newInd,c)+randi(255));
    newImg(:,:,c)=reshape(newGray(:,c),newSize); %reshape it
    newImg2(:,:,c)=reshape(newGray2(:,c),newSize); %reshape it
end




if T==1 %remove the effect of transpose, if applied
    img_=zeros(size(newImg,2),size(newImg,1),size(newImg,3));
    img_2=zeros(size(newImg,2),size(newImg,1),size(newImg,3));
    for c=1:size(img,3)
        img_(:,:,c)=newImg(:,:,c)';
        img_2(:,:,c)=newImg2(:,:,c)';
    end
    newImg=img_;
    newImg2=img_2;
    mask=mask';
    clear img_ img_2;
end
newImg=uint8(newImg); %convert the image to uint8
newImg2=uint8(newImg2); %convert the image to uint8
end

