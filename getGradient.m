function G = getGradient( img,mask )
%get Gradient function: return the gradient of the given image
%Usage:
%   G=getgradient(img);
%Input:
%   -img: input image (colored or grayscale)
%   -mask: markup mask
%Output:
%   -G: gradient of the given image
%Author: Mahmoud Afifi - York University

if nargin<1
    error('Too few input arguments');
elseif nargin<2 
    mask=zeros(size(img,1),size(img,2));
end

if size(img,3)>1
    img=rgb2gray(img);
end
img=double(img)/255; %normalize
%create the gradient mask for the first derivative
kernel_x=[-1 1];
kernel_y=[-1;1]; 
g_x=conv2(img,kernel_x, 'same');
g_y=conv2(img,kernel_y, 'same');
G=abs(g_x)+abs(g_y);
G=G+mask;
end

