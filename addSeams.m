function [newImg,I] = addSeams( img, seams , type )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%addSeams function: add given seams to the input image (img)
%Author: Mahmoud Afifi - York University

I=img;
for i = 1 :length(seams)
     [img,I]=addSeam( img, seams{i} , type(i),I );
end

newImg=img;
