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
function Hybtrack_kymooverlap(PathFilename,position,dir)
% -------------
% BEGIN CODE
% -------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Colorset=[1 0 1;0.3 0.2 0.1;0 1 0;0 0 1;1 0 0; 0 1 1; 0.2 0 0.8;0.4 0 0.6; 0.6 0 0.4; 0.8 0 0.2;0 0.2 0.8;0 0.4 0.6;0 0.6 0.4;0 0.8 0.2]; 
%     clear position;

    clear imstack kym;
imginfo=imfinfo([PathFilename]);
frmmax=numel(imginfo);
for a=1:frmmax
    imstack(:,:,a)=imread([PathFilename],a);
end
kym=Hybtrack_kymograph(imstack,'x');
kymy=Hybtrack_kymograph(imstack,'y');
figure(999)
switch dir
    case 'x' 
 subplot(2,1,1)
 imagesc(kym)
 colormap('gray');
 
title('Frame number');
 ylabel('X Position (Pixel)')
xlim([0,size(kym,2)])
ylim([0,size(kym,1)])
hold all;
for j=1:floor(size(position,2)/3)
plot(position(:,3*j-2),'.','Color',Colorset(j+2,:))
end
    case'y'
subplot(2,1,2)
imagesc(kymy) 
title('Frame number');
 ylabel('Y Position (Pixel)')
xlim([0,size(kymy,2)])
ylim([0,size(kymy,1)])
hold all;
for j=1:floor(size(position,2)/3)
plot(position(:,3*j-1),'.','Color',Colorset(j+2,:))
end

end
end