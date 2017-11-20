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
function  [xc ,yc, Amp, wx,wy] = gaussian_fit_2d(im)

width=size(im,2);
height=size(im,1);

z=im; k=1;
media=median(reshape(im,width*height,1));
mmin=min(reshape(im,width*height,1));
x=double(zeros(height,width));
y=double(zeros(height,width));
for i=1:height
for j=1:width
x(i,j)=j;
y(i,j)=i;
if im(i,j)<media
    noise(k)=im(i,j);
    k=k+1;
end
end
end

z0=z-mmin;
[xc,yc,Amp,wx]=gauss2dcirc(z0,x,y,std(noise));
wy=wx;

end
% im(round(yc),round(xc))=0;
% imagesc(im);


% xpos=width-xc
% ypos=height-yc
% Amp
% std
