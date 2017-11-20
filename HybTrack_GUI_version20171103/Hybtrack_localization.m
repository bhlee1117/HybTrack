% HybTrack: A hybrid single-particle tracking software using manual and automatic detection of dim signals
%
%     Copyright (C) 2017  Byung Hun Lee, bhlee1117@snu.ac.kr
%     Copyright (C) 2017  Hye Yoon Park, hyeyoon.park@snu.ac.kr
%
%     Website : http://neurobiophysics.snu.ac.kr/

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
function [fitted ,temp ,swch,error] = Hybtrack_localization(im,pts,scan_col,scan_row,ptl_sz,thres,tr,man_scan,swch_input)
%scan_row는 세로로 얼마나 scan할것인가
%scan_col는 가로로 얼마나 scan할것인가
%%
N=round(sqrt(ptl_sz));
fit_x=2*N+3;
fit_y=2*N+3;
tp=0; wx=0; wy=0;
%%%%%%%%%%%%%%%%%%%%
if tr(1,1)==0 %First frame error prevention
    tr_t=pts;
    tr_t(:,3)=10000;
    tr=reshape(tr_t',1,3*size(pts,1));
end
n=size(pts,1);
swch=0;
error.swch=0;
%%
for i=1:n %n = detect 하고자 하는 RNA_갯수
    cc=floor(pts(i,1)); rr=floor(pts(i,2));
    fitted(i,1)=pts(i,2);
    fitted(i,2)=pts(i,1);
    max=0; max2=0;
    for j=1:(scan_col*scan_row)  %포인트에서 행 열만큼 스캔
        
        [rr2,cc2]=ind2sub(scan_row,j);
  tmp=im(floor(rr-rr2+1+(scan_row-1)/2)+(N-1)/2-2:floor(rr-rr2+1+(scan_row-1)/2)+(N-1)/2,floor(cc-cc2+1+(scan_col-1)/2)+(N-1)/2-2:floor(cc-cc2+1+(scan_col-1)/2)+(N-1)/2); %tmp is croped square image
m=mean(mean(tmp));
        if m>=max
            max=m;
            temp(i,1)=floor(rr-rr2+1+scan_row/2); temp(i,2)=floor(cc-cc2+1+scan_col/2);
        else if m<max && m>=max2 && (temp(i,1)-floor(rr-rr2+1+scan_row/2))^2+(temp(i,2)-floor(cc-cc2+1+scan_col/2))^2>=ptl_sz
                max2=m;
            end
        end
    end
    %%
    if i>=2        %앞에서 detect 한 RNA 위치와 겹치지 않게
        if size(find(temp(:,2)==temp(i,2),2),1)>1 && size(find(temp(:,1)==temp(i,1),2),1)>1
            nott=find(temp(:,2)==temp(i,2),2);
            if swch_input.tp==1 
               v=tp_discriminate(tr(:,3*i-5:3*i),10);
temp(i-1,1)=round(tr(size(tr,1),3*i-4))+round(v(1,2)); temp(i-1,2)=round(tr(size(tr,1),3*i-5))+round(v(1,1));
temp(i,1)=round(tr(size(tr,1),3*i-1))+round(v(2,2)); temp(i,2)=round(tr(size(tr,1),3*i-2))+round(v(2,1));
            else
                error.swch=1;
                numbering={'1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th' ,'9th', '10th','11th','12th','13th','14th','15th','16th','17th','18th','19th','20th','21st','22nd','23rd'};

                error.message=[char(numbering(1,nott(1,1))),' particle and ',char(numbering(1,nott(2,1))),' particle cannot be discriminated.'];
               
           swch =menu ([error.message,'Do you want to stop at this frame?'],'Stop','Manual detection','Gap');

            %%
            if swch==1
                break;
             end
            %%
            if swch==3
                    temp(i,:)=NaN; temp(i-1,:)=NaN;
            end
            %%
            if swch==2
            figure(99)
            hold all;
            subplot(2,1,1);
            colormap('gray')
            imagesc(im);    
            hold all;
            plot(tr(size(tr,1),3*i-2),tr(size(tr,1),3*i-1),'ro')
            temp2 = ginput(2);
            close;
            
            c=floor(temp2(1,1)); r=floor(temp2(1,2));
            max=0;
            for aa=1:2
            for a=1:man_scan*man_scan
                
                [r2,c2]=ind2sub(man_scan,a);
                m=0;
                for b=1:ptl_sz
                    
                    [r3,c3]=ind2sub(N,b);
                    tmp(r3,c3)=im(floor(floor(temp2(aa,2))-r2+1+(scan_row-1)/2)-r3+1+(N-1)/2,floor(floor(temp2(aa,1))-c2+1+(scan_col-1)/2)-c3+1+(N-1)/2);
                    m=mean(mean(tmp));
                end
                if m>=max
                    max=m;
                    temp(i-(2-aa),1)=floor(floor(temp2(aa,2))-r2+1+3/2); temp(i-(2-aa),2)=floor(floor(temp2(aa,1))-c2+1+3/2);
                end
            end
            end
            end
            end
            end
    end
    %%
    if abs(max2/max)>=thres %두번째로 밝은 점과 값이 별로 차이 안나면 창을 띄워 사용자에게 고르게 한다
         error.swch=1;
         numbering={'1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th' ,'9th', '10th','11th','12th','13th','14th','15th','16th','17th','18th','19th','20th','21st','22nd','23rd'};
                error.message=[char(numbering(1,i)),' particle cannot be detected.'];
        swch =menu ([error.message,' Do you want to stop at this frame?'],'Stop','Manual detection','Gap');
        if swch==1
             temp(i,:)=NaN;
            break;
        end
        if swch==3
            if i==1
                    temp(i,:)=NaN; 
            else
                temp(i,:)=NaN; temp(i-1,:)=NaN;
            end
        end
%         im_blur=gaussian_blur_bh(im,1,5);
%             im_mod=(im_blur+im)./2;
       if swch==2       
            figure(99)
            hold all;
            subplot(2,1,1);
            colormap('gray')
            imagesc(im);     
            hold all;
            plot(tr(size(tr,1),3*i-2),tr(size(tr,1),3*i-1),'ro')
        temp2 = ginput(1);
        close;
        c=floor(temp2(1,1)); r=floor(temp2(1,2));
        max=0;
        for a=1:(man_scan*man_scan)
            [r2,c2]=ind2sub(man_scan,a);
            m=0;
            for b=1:ptl_sz
                
                [r3,c3]=ind2sub(N,b);
                tmp(r3,c3)=im(floor(r-r2+1+(scan_row-1)/2)-r3+1+(N-1)/2,floor(c-c2+1+(scan_col-1)/2)-c3+1+(N-1)/2);
                m=mean(mean(tmp));
            end
            if m>=max
                max=m;
                temp(i,1)=floor(r-r2+1+3/2); temp(i,2)=floor(c-c2+1+3/2);
                
            end
        end
    end
    end
    close(figure);
end
    %%
    for i=1:n 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 2D GAUSSIAN FITTING %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if i>size(temp,1)
    nt=size(temp,1);
    for j=nt+1:n
    temp(j,:)=NaN;
    end
    
    else
    if isnan(temp(i,1))
        fitted(i,1:3)=NaN;
    else
    for c=1:fit_x*fit_y
        
        [r4,c4]=ind2sub(fit_y,c);
        crop(r4,c4)=im(temp(i,1)+r4-round(fit_y/2),temp(i,2)+c4-round(fit_x/2));
    end
    crop=double(crop);
    
    switch swch_input.fit
        case 1  % 2d Gaussian fitting
            
    [xc , yc, Amp ,wx ,wy] = gaussian_fit_2d(crop);
    if tr(1,3*i)==10000
        tr(size(tr,1),3*i)=Amp*pi*wx*wy;
    end
    background=median(reshape(crop,fit_x*fit_y,1));
       if yc<N-1 || xc<N-1  || xc>fit_x-N+1 || yc>fit_y-N+1 || isnan(xc) || isnan(yc) %fitting error -> centroid
       
        cent_x=0; cent_y=0;             %
        
        for h=1:size(crop)       % Centroid
            for g=1:size(crop)
                cent_x=cent_x + crop(h,g)*h;
                cent_y=cent_y + crop(h,g)*g; 
            end
        end
        xc=cent_x/sum(sum(crop));
        yc=cent_y/sum(sum(crop));  %Centroid fitting end
         if yc<N-1 || xc<N-1 || xc>fit_x-N+1 || yc>fit_y-N+1 || isnan(xc) || isnan(yc) % Centroid error -> Local maxima // rarely happen
        yc=round(fit_y/2);
        xc=round(fit_x/2);
         end  
           fitted(i,3)=sum(sum(im(round(fitted(i,1))-ceil(N/2):round(fitted(i,1))+ceil(N/2),round(fitted(i,2))-ceil(N/2):round(fitted(i,2))+ceil(N/2))))-background*(2*ceil(N/2)+1)^2;
       else 
        fitted(i,3)=Amp*2*pi*wx*wy;
       end
       
    fitted(i,1)=temp(i,1)-round(fit_y/2)+yc;
    fitted(i,2)=temp(i,2)-round(fit_x/2)+xc;
        case 2 % Centroid Fitting
           
          cent_x=0; cent_y=0;            
        background=min(reshape(crop,fit_x*fit_y,1));
        for h=1:size(crop)       
            for g=1:size(crop)
                cent_x=cent_x + crop(h,g)*h;
                cent_y=cent_y + crop(h,g)*g; 
            end
        end
        xc=cent_x/sum(sum(crop));
        yc=cent_y/sum(sum(crop));
         if yc<N-1 || xc<N-1 || xc>fit_x-N+1 || yc>fit_y-N+1 || isnan(xc) || isnan(yc) 
        yc=round(fit_y/2);
        xc=round(fit_x/2);
         end
    fitted(i,1)=temp(i,1)-round(fit_y/2)+yc;
    fitted(i,2)=temp(i,2)-round(fit_x/2)+xc;
    fitted(i,3)=sum(sum(im(round(fitted(i,1))-ceil(N/2):round(fitted(i,1))+ceil(N/2),round(fitted(i,2))-ceil(N/2):round(fitted(i,2))+ceil(N/2))))-background*(2*ceil(N/2)+1)^2;
    end
    end

    end
    end
end

function gcbf=menucallback2(btn, evd, index)                                 %#ok
set(gcbf,swch, index);
end
