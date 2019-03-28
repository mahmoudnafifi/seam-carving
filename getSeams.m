function seams = getSeams( G, type )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%getSeams function: get all seams of the given gradient energy function
%Usage:
%    seams = getSeams( G, type );
%Input:
%   -G: gradient of the image
%   -type: 'H' for horizontal seams - 'V' for vertical seams
%Output:
%   -seams: the seams extracted from the gradient G
%
%Citation: Avidan, Shai, and Ariel Shamir. "Seam carving for content-aware
%image resizing. ACM Transactions on graphics (TOG). Vol. 26. No. 3.
%ACM, 2007"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Mahmoud Afifi, York University.
switch lower(type)
    case 'v'
        t=1;
        seam_num=size(G,2);
        seam_point_num=size(G,1);
       
    case 'h'
        t=2;
        seam_num=size(G,1);
        seam_point_num=size(G,2);

end

 G=padarray(G, [1,1],'replicate'); %padding G

 %seams(i,j,k) -> i=seam number, j=point (pixel) number, k=x or y coord. 
 %If k=3 it refers to the score of this point
seams=zeros(seam_num,seam_point_num,3); %initialization 

%if t=1 (horizontal)
if t==2
    for i=2:seam_num+1
        previous=0;
        for j=2:seam_point_num+1
           
            if previous==0
                seams(i-1,j-1,2)=j; %x
                seams(i-1,j-1,1)=i; %y
                previous=1;
            else
                new_x=seams(i-1,j-1-1,2)+1;
                new_y=seams(i-1,j-1-1,1); 
                min_g=min(min(G(new_y,new_x),...
                    G(new_y+1,new_x)),...
                    G(new_y-1,new_x));
                switch min_g
                    case G(new_y,new_x)
                        seams(i-1,j-1,1)=new_y;
                        seams(i-1,j-1,2)=new_x; 
                    case  G(new_y-1,new_x)
                        seams(i-1,j-1,1)=new_y-1;
                        seams(i-1,j-1,2)=new_x;
                    case G(new_y+1,new_x)
                        seams(i-1,j-1,1)=new_y+1;
                        seams(i-1,j-1,2)=new_x;
                end
                seams(i-1,j-1,3)=min_g;
            end
        end
    end
elseif t==1
    for i=2:seam_num+1
        previous=0;
        for j=2:seam_point_num+1
            if previous==0
                seams(i-1,j-1,2)=i; %x
                seams(i-1,j-1,1)=j; %y
                previous=1;
            else
                new_x=seams(i-1,j-1-1,2);
                new_y=seams(i-1,j-1-1,1)+1;
                min_g=min(min(G(new_y,new_x),...
                    G(new_y,new_x+1)),...
                    G(new_y,new_x-1));
                switch min_g
                    case G(new_y,new_x)
                        seams(i-1,j-1,1)=new_y;
                        seams(i-1,j-1,2)=new_x;
                    case  G(new_y,new_x-1)
                        seams(i-1,j-1,1)=new_y;
                        seams(i-1,j-1,2)=new_x-1;
                    case G(new_y,new_x+1)
                        seams(i-1,j-1,1)=new_y;
                        seams(i-1,j-1,2)=new_x+1;
                end
                seams(i-1,j-1,3)=min_g;
            end
        end
    end
end


seams=seams-1;
seams(:,:,3)=seams(:,:,3)+1;