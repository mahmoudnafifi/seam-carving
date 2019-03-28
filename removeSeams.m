function newImg = removeSeams( img, seams , type )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%removeSeams function: remove given seams from the input image (img)
%Author: Mahmoud Afifi - York University

for i = 1 :length(seams)
     img = removeSeam( img, seams{i} , type(i) );
end

newImg=img;