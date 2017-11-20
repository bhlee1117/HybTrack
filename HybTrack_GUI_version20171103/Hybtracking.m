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
function position = Hybtracking(PathFileName,RNA_number,Scan_row,Scan_col,window_size,Threshold,SaveAVI,outputpath,swch_input,handles)
%% Default
Colorset=[1 0 1;0.3 0.2 0.1;0 1 0;0 0 1;1 0 0; 0 1 1; 0.2 0 0.8;0.4 0 0.6; 0.6 0 0.4; 0.8 0 0.2;0 0.2 0.8;0 0.4 0.6;0 0.6 0.4;0 0.8 0.2]; 
maxima_avg=3;
man_scan=1;
imginfo=imfinfo([PathFileName]);
frmmax=numel(imginfo);
frm_i=1; frm_f=frmmax;
%% Tracking

imaverage = averagestack([PathFileName],frmmax);

%% First Frame particle selection
subplot(3,1,1);
figure(1);
LBH = imagesc(imread([PathFileName],'tif',1));
axis equal
pts = ginput(RNA_number);
close;
%%
deno=outputpath(1,size(outputpath,2));
Name=split(PathFileName,deno);
filename=split(Name(size(Name,1),1),'.');
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
         [fitted, temp1(:,:,i) , swch,error]= Hybtrack_localization(im,pts,Scan_col,Scan_row,window_size,Threshold,zeros(1,3*RNA_number),man_scan,swch_input);
     else
         
     [fitted, temp1(:,:,i) , swch,error]= Hybtrack_localization(im,pts,Scan_col,Scan_row,window_size,Threshold,tr(1:i-1,:),man_scan,swch_input);
     end
     set(handles.E15,'string',['frame is ',num2str(i)]);
     if error.swch==1
         set(handles.E15,'string',error.message);
     end
      if swch==1
        
        break;
     end
      for k=1:RNA_number
%      %im,���콺������ �Է�,col scan,row scan,ptl size(must be square of odd integer)
      tr(i,3*k-2:3*k)=[ fitted(k,2) fitted(k,1) fitted(k,3)]; %1���� x, 2���� y
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
% Hybtrack_kymooverlap(PathFileName,tr,'x');
% hold all;
% Hybtrack_kymooverlap(PathFileName,tr,'y');
set(handles.E16,'string',size(tr,1));
frm_extract=str2num(get(handles.E16,'string'));
numb=get(handles.E17,'string');
position=tr(1:frm_extract,:);
figure(4)
imagesc(imaverage);
colormap('gray');
axis equal
hold all
for i=1:size(position,2)/3
    plot(position(:,3*i-2),position(:,3*i-1),'Color',Colorset(i,:));
    hold all
end

 
end