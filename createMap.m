function [T1,T2]=createMap(img)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%createMap function: compute the map for seam carving as a
%pre-processing step.
%Usage:
%    [T1,T2]=createMap(img);
%Input:
%   -img: input image (uint8)
%Output:
%   -T1: a map of shrinking the given image. The map is used by seamCarving
%   function
%   -T2: a map of enlarging the given image. The map is used by seamCarving
%   function
%
%Citation: Avidan, Shai, and Ariel Shamir. "Seam carving for content-aware 
%image resizing. ACM Transactions on graphics (TOG). Vol. 26. No. 3.
%ACM, 2007"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Mahmoud Afifi, York University.


display('creating the map... ');

%% 
%Calculate T1
filled_map=false(size(img,1),size(img,2)); %filled map (memory allocation)
T1=cell(size(img,1),size(img,2)); %map (memory allocation)
%map entity contains: cost, seamPixels, and seamTypes
%cost is the energy cost. seamPixels is an array, each element contains all
%(x,y) for each pixel in the seams. seamTypes is an array contains either 
%'h' or 'v' for each seam in seamPixels array.
for i=2:size(img,1)
    for j=2:size(img,2)
       if filled_map(i,j-1)==false %left did not calculated yet
           %calculate it
           type='h'; %horizontal
           totalCost=0;
           I_left=img;
           for k=1:j-1
               G=getGradient(I_left); %calc gradient for I
               seams = getSeams(G,type); %calc all seams
               [s,cost]=getBestSeam(G,seams); %get best one 
               I_left=removeSeam(I_left,s,type); %remove it and receive new image I
               totalCost=totalCost+cost; %accumulated cost
               T1{i,j-1}.seamPixels{k}=s;
               T1{i,j-1}.seamTypes(k)=type;
               T1{i,j-1}.cost=totalCost;
           end
           filled_map(i,j-1)=true;
       else
           I_left=removeSeams(img,T1{i,j-1}.seamPixels,T1{i,j-1}.seamTypes);
       end
       if filled_map(i-1,j)==false %up did not calculated yet
           %calculate it
           type='v'; %vertical
           totalCost=0;
           I_up=img;
           for k=1:j-1
               G=getGradient(I_up); %calc gradient for I
               seams = getSeams(G,type); %calc all seams
               [s,cost]=getBestSeam(G,seams); %get best one 
               I_up=removeSeam(I_up,s,type); %remove it and receive new image I
               totalCost=totalCost+cost; %accumulated cost
               T1{i-1,j}.seamPixels{k}=s;
               T1{i-1,j}.seamTypes(k)=type;
               T1{i-1,j}.cost=totalCost;
           end
           filled_map(i-1,j)=true;
       else
           I_up=removeSeams(img,T1{i-1,j}.seamPixels,T1{i-1,j}.seamTypes);
       end
       %calcualte the cost of coming from left and coming from up
       %coming from left, so now you are removing the 'v' seam
       typeV='v';
       G=getGradient(I_left); %calc gradient for I
       seams = getSeams(G,typeV); %calc all seams
       [sV,costV]=getBestSeam(G,seams); %get best one 
       costV=costV+T1{i,j-1}.cost;
       %coming from up, so now you are removing the 'h' seam
       typeH='h';
       G=getGradient(I_up); %calc gradient for I
       seams = getSeams(G,typeH); %calc all seams
       [sH,costH]=getBestSeam(G,seams); %get best one 
       costH=costH+T1{i-1,j}.cost;
       if costV<costH
           %take left, so now you drop vertical seam
           T1{i,j}.cost=costV;
           T1{i,j}.seamPixels=T1{i,j-1}.seamPixels;
           T1{i,j}.seamPixels{length(T1{i,j}.seamPixels)+1}=sV;
           T1{i,j}.seamTypes=[T1{i,j-1}.seamTypes,typeV];    
       else
           %take up
           T1{i,j}.cost=costH;
           T1{i,j}.seamPixels=T1{i-1,j}.seamPixels;
           T1{i,j}.seamPixels{length(T1{i,j}.seamPixels)+1}=sH;
           T1{i,j}.seamTypes=[T1{i-1,j}.seamTypes,typeH];
       end
       filled_map(i,j)=true;
    end
end


%% 
%Calculate T2
for i=2:size(img,1)
    for j=2:size(img,2)
       if filled_map(i,j-1)==false %left did not calculated yet
           %calculate it
           type='h'; %horizontal
           totalCost=0;
           I_left=img;
           I_left2=I_left;
           for k=1:j-1
               G=getGradient(I_left2); %calc gradient for I
               seams = getSeams(G,type); %calc all seams
               [s,cost]=getBestSeam(G,seams); %get best one 
               [I_left,I_left2]=addSeam(I_left,s,type,I_left2); %add seam, here we receive I_left (new image) and I_left2 which is the seam images
               totalCost=totalCost+cost; %accumulated cost
               T2{i,j-1}.seamPixels{k}=s;
               T2{i,j-1}.seamTypes(k)=type;
               T2{i,j-1}.cost=totalCost;
           end
           filled_map(i,j-1)=true;
       else
           [I_left,I_left2]=addSeams(img,T2{i,j-1}.seamPixels,T2{i,j-1}.seamTypes);
       end
       if filled_map(i-1,j)==false %up did not calculated yet
           %calculate it
           type='v'; %vertical
           totalCost=0;
           I_up=img;
           I_up2=I_up;
           for k=1:j-1
              G=getGradient(I_up2); %calc gradient for I
               seams = getSeams(G,type); %calc all seams
               [s,cost]=getBestSeam(G,seams); %get best one 
               [I_up,I_up2]=addSeam(I_up,s,type,I_up2); %add seam, here we receive I_up (new image) and I_up2 which is the seam images
               totalCost=totalCost+cost; %accumulated cost
               T2{i-1,j}.seamPixels{k}=s;
               T2{i-1,j}.seamTypes(k)=type;
               T2{i-1,j}.cost=totalCost;
           end
           filled_map(i-1,j)=true;
       else
           [I_up,I_up2]=addSeams(img,T2{i-1,j}.seamPixels,T2{i-1,j}.seamTypes);
       end
       %calcualte the cost of coming from left and coming from up
       %coming from left, so now you are removing the 'v' seam
       typeV='v';
       G=getGradient(I_left2); %calc gradient for I
       seams = getSeams(G,typeV); %calc all seams
       [sV,costV]=getBestSeam(G,seams); %get best one 
       costV=costV+T2{i,j-1}.cost;
       %coming from up, so now you are removing the 'h' seam
       typeH='h';
       G=getGradient(I_up2); %calc gradient for I
       seams = getSeams(G,typeH); %calc all seams
       [sH,costH]=getBestSeam(G,seams); %get best one 
       costH=costH+T2{i-1,j}.cost;
       if costV<costH
           %take left, so now you drop vertical seam
           T2{i,j}.cost=costV;
           T2{i,j}.seamPixels=T2{i,j-1}.seamPixels;
           T2{i,j}.seamPixels{length(T2{i,j}.seamPixels)+1}=sV;
           T2{i,j}.seamTypes=[T2{i,j-1}.seamTypes,typeV];    
       else
           %take up
           T2{i,j}.cost=costH;
           T2{i,j}.seamPixels=T2{i-1,j}.seamPixels;
           T2{i,j}.seamPixels{length(T2{i,j}.seamPixels)+1}=sH;
           T2{i,j}.seamTypes=[T2{i-1,j}.seamTypes,typeH];
       end
       filled_map(i,j)=true;
    end
end