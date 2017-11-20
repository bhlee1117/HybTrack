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
function v=tp_discriminate(tr,nsize)


% tr= 2 particle, 10 column vector
if nsize>size(tr,1)
    nsize=size(tr,1);
end
Data=tr(size(tr,1)-nsize+1:size(tr,1),:);
for i=1:size(tr,2)/3
fittnessx= fit([1:nsize]',Data(:,3*i-2),'poly1'); % Linear Fit log MSD
fittnessy= fit([1:nsize]',Data(:,3*i-1),'poly1');
 v(i,1)=fittnessx.p1;
 v(i,2)=fittnessy.p1;
end
%%
% for k=1:size(Data,2)/5
% %ax+D(1:3*k-4)
% maxx=0;
% maxy=0;
% for i=1:100000
% a=(rand-0.5)*6;
% b=(rand-0.5)*6;
% Hx(1)=Data(1,3*k-4);
% Hy(1)=Data(1,3*k-3);
% for j=2:nsize
%     Hx(j)=Hx(j-1)+a;
%     Hy(j)=Hy(j-1)+b;
% end
%     mx=exp(-sum((Hx(:)-Data(:,3*k-4)).^2));
%     my=exp(-sum((Hy(:)-Data(:,3*k-3)).^2));
%     if mx>maxx
%         mx=maxx;
%         v(k,1)=a;
%     end
%     if my>maxx
%         my=maxx;
%         v(k,2)=b;
%     end
% end
% end


