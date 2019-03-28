% %test code .. here we don't use the map; it is just a simple test.
clear all
clc
close all

fileName='van.bmp';
% %read image
I=imread(fileName);
%n is the number of seams (removed)
n=120;

%SHRINK
%remove n seams 'v' ...
for i=1:n
    G=getGradient(I); %calc gradient for I
    seams = getSeams( G, 'v'); %calc all seams
    s=getBestSeam(G,seams); %get best one
    I=removeSeam(I,s,'v'); %remove it and receive new image I
    imshow(I); %show it
end

%remove n seams 'h'
n=20;
for i=1:n
    G=getGradient(I);
    seams = getSeams( G, 'h');
    s=getBestSeam(G,seams);
    I=removeSeam(I,s,'h');
    imshow(I);
end
imwrite(I,strcat(fileName(1:end-4),'_shrinked.jpg'));

%ENLARGE
%add n seams 'v'
I=imread(fileName);  %read image
I2=I; %I2 to avoid add same seams
n=20; %number of seams to be added
f1 = figure('IntegerHandle','off'); %new image figure
f2 = figure('IntegerHandle','off'); %seam image figure
for i=1:n
    G=getGradient(I2); %calc gradient for I2 (not I)
    seams = getSeams( G, 'v'); %get seams
    s=getBestSeam(G,seams); %get best seam
    [I,I2]=addSeam(I,s,'v',I2); %add seam, here we receive I (new image) and I2 which is the seam images
    figure(f1);
    imshow(I); %show new image after adding i(th) seams on it
    figure(f2);
    imshow(I2); %show I2
end

% I2=I;
%remove n seams 'h'
n=20;
for i=1:n
    G=getGradient(I2);
    seams = getSeams( G, 'h');
    s=getBestSeam(G,seams);
    [I,I2]=addSeam(I,s,'h',I2);
    figure(f1);
    imshow(I);
    figure(f2);
    imshow(I2);
end

imwrite(I,strcat(fileName(1:end-4),'_enlarged.jpg'));
imwrite(I2,strcat(fileName(1:end-4),'_seams.jpg'));