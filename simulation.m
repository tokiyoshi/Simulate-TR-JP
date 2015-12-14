% import raw data
%%This will be the path that refers to the directory above the Entire Image
%%folder
function simulation(a)
EntireIMpath = 'C:\Campbell Labs\Human Analysis\831AD\Set 2 Location 4';
saveIMpath = '\\files\students$\mthamel\Desktop\savedpictures';
try
    home = cd([EntireIMpath,'\Entire Image\MM - Max m_00 Norm']);
catch
    error('Invalid path');
end
%finding all of the text files in this folder which have an _m in them
findtext = '*_m*.txt';
DIRinfo = dir (findtext);
cd(home);
dirlength = size(DIRinfo,1);
if dirlength == 16;
else
    if dirlength >16
        error('More text files have been found than should exist'); 
    %This error should only occur if the name of the file has an _m in it
    %if it does, simply add more text before the _m to be selective
    else
        error(['Incorrect directory or ',findtext,' did not match 16 files']);
    end
end
counter = 0;
MM = zeros(4);
%creating the Muller Matrix
while counter < dirlength;
    counter = counter + 1;
    entries = ['00';'01';'02';'03';'10';'11';'12';'13';'20';'21';'22';'23';'30';'31';'32';'33'];
    MMent = csvread([EntireIMpath,'\Entire Image\MM - Max m_00 Norm\',DIRinfo(counter).name]);
    %creating the blank muller matrix after finding the dimentions of the
    %picture
    if counter==1;
        [h,w] = size(MMent);
        MM = zeros(h,w,4,4);
    end
    matrixvals = [(str2num(entries(counter,1))+1),(str2num(entries(counter,2))+1)];
    MM(:,:,matrixvals(1),matrixvals(2)) = MMent;
end

%unpolarized light Stokes vector
S = [1; 0; 0; 0;];

%Here are all the elemnets we use in the transmission microscope
qwp_45 = [1 0 0 0; 0 0 0 -1; 0 0 1 0; 0 1 0 0];
qwp_00 = [1 0 0 0; 0 1 0 0; 0 0 0 -1; 0 0 1 0];
qwp_30 = [1 0 0 0; 0 0.25 0.433 0.866; 0 0.433 0.75 -0.5; 0 -0.866 0.5 0];
qwp_60 = [1 0 0 0; 0 0.25 -0.433 0.866; 0 -0.433 0.75 0.5; 0 -0.866 -0.5 0];

hlpangles = [0;45;90;135;180;225;270];
anglecount = 0;
hlp = cell(size((hlpangles),1),2);

while anglecount < size(hlpangles,1)
    anglecount = anglecount +1;
    theta = degtorad(hlpangles(anglecount));
    hlp{anglecount,2} = 0.5 .* [1,cos(2*theta),sin(2*theta),0;...
        cos(2*theta),(cos(2*theta))^2,sin(2*theta)*cos(2*theta),0;...
        sin(2*theta),sin(2*theta)*cos(2*theta),(sin(2*theta))^2,0;...
        0,0,0,0;];
    hlp{anglecount,1} = hlpangles(anglecount);
end
%Now I will create the images hlpsetting1=PSG hlpsetting2=PSA
function out = simulateJP(hlpsetting1,hlpsetting2)
hcount = 0;
out = zeros(h,w);
    while hcount < h;
        hcount = hcount+1;
        wcount = 0;
        while wcount < w;
            wcount = wcount + 1;
             temp = cell2mat(hlp(hlpsetting2,2))*reshape(MM(hcount,wcount,:,:),[4,4])*cell2mat(hlp(hlpsetting1,2))*S;
             out(hcount,wcount) = temp(1);
        end
    end
end
%Now I will create the TR images
function out = simulateTR(qwp)
hcount = 0;
out = zeros(h,w);
    while hcount < h;
        hcount = hcount+1;
        wcount = 0;
        while wcount < w;
            wcount = wcount + 1;
             temp = reshape(MM(hcount,wcount,:,:),[4,4])*qwp*cell2mat(hlp(1,2))*S;
             out(hcount,wcount) = temp(1);
        end
    end
end
%%lazy saving -- Settings can easily be found by looking at the variable hlp
JP90P = simulateJP(3,3);
imwrite(JP90P,[saveIMpath,'\JP90P.bmp']);
clear JP90P

JP90C = simulateJP(3,1);
imwrite(JP90C,[saveIMpath,'\JP90C.bmp']);
clear JP90C

JP00P = simulateJP(1,1);
imwrite(JP00P,[saveIMpath,'\JP00P.bmp']);
clear JP00P

JP00C = simulateJP(1,3);
imwrite(JP00C,[saveIMpath,'\JP00C.bmp']);
clear JP00C

JP180P = simulateJP(5,5);
imwrite(JP180P,[saveIMpath,'\JP180P.bmp']);
clear JP180P

JP180C = simulateJP(5,7);
imwrite(JP180C,[saveIMpath,'\JP180C.bmp']);
clear JP180C

JP45P = simulateJP(2,2);
imwrite(JP45P,[saveIMpath,'\JP45P.bmp']);
clear JP45P

JP45C = simulateJP(2,4);
imwrite(JP45C,[saveIMpath,'\JP45C.bmp']);
clear JP45C

JP135P = simulateJP(4,4);
imwrite(JP135P,[saveIMpath,'\JP135P.bmp']);
clear JP135P

JP135C = simulateJP(4,6);
imwrite(JP135C,[saveIMpath,'\JP135C.bmp']);
clear JP135C

TR00 = simulateTR(qwp_00);
imwrite(TR00,[saveIMpath,'\TR00.bmp']);
clear TR00

TR30 = simulateTR(qwp_30);
imwrite(TR30,[saveIMpath,'\TR30.bmp']);
clear TR30

TR45 = simulateTR(qwp_45);
imwrite(TR45,[saveIMpath,'\TR45.bmp']);
clear TR45

TR60 = simulateTR(qwp_60);
imwrite(TR60,[saveIMpath,'\TR60.bmp']);
clear TR60

end