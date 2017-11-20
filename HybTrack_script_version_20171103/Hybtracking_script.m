% HybTrack: A hybrid single-particle tracking software using manual and automatic detection of dim signals
%
%     Copyright (C) 2017  Byung Hun Lee, bhlee1117@snu.ac.kr
%     Copyright (C) 2017  Hye Yoon Park, hyeyoon.park@snu.ac.kr
%
%     Website : http://neurobiophysics.snu.ac.kr/
%
% HybTrack is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     HybTrackis distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with HybTrack.  If not, see <http://www.gnu.org/licenses/>.
%% Load Image and Parameter Setting 
[FileName, PathName] = uigetfile('*.tif', 'Choose the mRNA image(.tif) file');
PathFileName=[PathName,FileName];
RNA_number=3;
Scan_row=5;
Scan_col=5;
window_size=9;
Threshold=80;
SaveAVI=1;
swch_input.tp=2; % 1 = Linear motion, 2 = Manual
swch_input.fit=1; % 1 = Gaussian fitting, 2 = Centroid fitting
kk=1; deno=PathName(1,1);
while deno~='\' && deno~='/'
    kk=kk+1;
    deno=PathName(1,kk);
end
outputpath=[uigetdir(PathName,'Choose the output path'),deno];
%% Default
Colorset=[1 0 1;0.3 0.2 0.1;0 1 0;0 0 1;1 0 0; 0 1 1; 0.2 0 0.8;0.4 0 0.6; 0.6 0 0.4; 0.8 0 0.2;0 0.2 0.8;0 0.4 0.6;0 0.6 0.4;0 0.8 0.2]; 
maxima_avg=3;
man_scan=1;
imginfo=imfinfo([PathFileName]);
frmmax=numel(imginfo);
frm_i=1; frm_f=frmmax;
%% Tracking Start
if SaveAVI==1
imaverage = averagestack([PathFileName],frmmax);
end
%% Particle selection from first frame
figure(1);
LBH = imagesc(imread([PathFileName],'tif',1));
axis equal
pts = ginput(RNA_number);
close;
%%
Name=split(PathFileName,deno);
filename=split(FileName,'.');
 if SaveAVI==1
aviobj = VideoWriter([outputpath,char(filename(1,1)),'.avi']);
 fig=figure(2);
 hold all;
colormap('gray')
open(aviobj);
 end
tr=zeros(1,3*RNA_number);
 for i=frm_i:frm_f
     im = imread([PathFileName],'tif',i);
     if i==1
         [fitted, temp1(:,:,i) , swch,error]= Hybtrack_localization_script(im,pts,Scan_col,Scan_row,window_size,Threshold,zeros(1,3*RNA_number),man_scan,swch_input);
     else
         
     [fitted, temp1(:,:,i) , swch,error]= Hybtrack_localization_script(im,pts,Scan_col,Scan_row,window_size,Threshold,tr(1:i-1,:),man_scan,swch_input);
     end
     if error.swch==1
        error.message;
     end
      if swch==1
        
        break;
     end
      for k=1:RNA_number
      tr(i,3*k-2:3*k)=[ fitted(k,2) fitted(k,1) fitted(k,3)]; 
if abs(isnan(temp1(k,2,i))-1)
      pts(k,1)=temp1(k,2,i); pts(k,2)=temp1(k,1,i);
     prm_pts(1,1)=floor(fitted(k,1)); prm_pts(1,2)=floor(fitted(k,2));
end
end
if SaveAVI==1   
outputimage=im;
subplot(2,1,1);
colormap('gray')
h=imagesc(outputimage);
hold all;
for k=1:RNA_number
    plot(tr(i,3*k-2),tr(i,3*k-1),'o','Color',Colorset(k+2,:))
end
%title(char(Name(size(Name,1),1)))
subplot(2,1,2);
colormap('gray')
xlim([0,size(im,2)])
ylim([0,size(im,1)])
imagesc(imaverage);
hold all;
for k=1:RNA_number
    plot(tr(:,3*k-2),tr(:,3*k-1),'Color',Colorset(k+2,:));
end
 axis off
 writeVideo(aviobj,getframe(fig));
  if mod(i,100)==0
     close(fig)
     fig=figure(2);
 hold all;
colormap('gray')
open(aviobj);
 end
end

 end
 
if SaveAVI==1 
  close(fig);
 close(aviobj);
end

%% Plot kymograph
% Hybtrack_kymooverlap_script(PathFileName,tr,'x');
% hold all;
figure(4)
imagesc(imaverage);
colormap('gray');
axis equal
hold all
position=tr;
for i=1:size(position,2)/3
    plot(position(:,3*i-2),position(:,3*i-1),'Color',Colorset(i,:));
    hold all
end
%% Save
Name=split(FileName,'.');
tmpname=strcat(outputpath,char(Name(1,1)),'.txt'); 
save(char(tmpname),'position','-ascii');
type(char(tmpname));