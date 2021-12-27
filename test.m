% written by Lindo Ouseph
% Research scholar, Department of Electronics,CUSAT,Kochi,India
% real time face detection system using webcam
function test
global h
%--------------------------------------------------------------
h.m=20;
h.threshold=4.5e3;
%--------------------------------------------------------------
h.call=0;
h.f=figure('menubar','none','CloseRequestFcn',@Close,'position',[500 100 240 500],'resize','off','numbertitle','off','name','FaceRecognition');
h.train=uicontrol('string','New Face','position',[5 240 115 50],'callback',@trainface,'fontsize',15);
h.Identify=uicontrol('string','Find Face','position',[122 240 115 50],'callback',@Identify,'fontsize',15);
h.ax1=axes('position',[0 .6 1 .5],'box','on','xtick',[],'ytick',[]);
h.result=uicontrol('style','text','position',[0 300 240 30],'backgroundcolor',get(h.f,'color'),'horizontalalignment','center','fontsize',15,'fontweight','bold','foregroundcolor',[0 0 0]);
h.feed=uicontrol('style','listbox','position',[10 10 224 220],'backgroundcolor',[0 0 0],'horizontalalignment','right','fontsize',7,'fontweight','bold','foregroundcolor',[1 1 1],'string',{'Initialisation';' success'});
Init();
%--------------------------------------------------------------
function Init(varargin)
global h
Res=imaqhwinfo('winvideo','DeviceInfo');Res=Res.SupportedFormats;
h.faceDetector = vision.CascadeObjectDetector();
h.obj =imaq.VideoDevice('winvideo', 1, Res{10});
set(h.obj,'ReturnedColorSpace', 'rgb');
while 1
    set(h.result,'string',[])
    frame=step(h.obj);
    imshow(frame);
    msg=get(h.feed,'string');
    set(h.feed,'string',[msg;['free running mode ', datestr(now)]],'value',length(msg)+1)
    drawnow
    pause(0.05);
end
% %--------------------------------------------------------------
function Close(varargin)
close all
clear all
clc
% %--------------------------------------------------------------
function trainface(varargin)
global h
h.call= ~h.call;
if ~h.call
    set(h.train,'string','New Face');drawnow
    Train();
    msg=get(h.feed,'string');
    set(h.feed,'string',[msg;['saved ',h.newface,' in to DB']],'value',length(msg)+1);
    return
end
set(h.train,'string','Stop');drawnow
h.newface=char(inputdlg('Name of the Person'));
mkdir('Faces')
cd('Faces')
mkdir(h.newface)
cd(h.newface);
delete('*jpg');
i=1;
while (h.call)
    try
        frame=step(h.obj);
        bbox=step(h.faceDetector,frame);
        boxInserter  = vision.ShapeInserter('BorderColor','Custom',...
            'CustomBorderColor',[255 255 0]);
        videoOut = step(boxInserter, frame,bbox);
        imshow(videoOut,'border','tight');drawnow
        
        rectangle('Position',bbox,'EdgeColor','r','LineWidth',1)
        faceImage    = imcrop(frame,bbox);
        faceimageresize=imresize(faceImage, [200 180]);
        imwrite(faceimageresize,[num2str(i),'.jpg']);
        
        msg=get(h.feed,'string');
        set(h.feed,'string',[msg;[num2str(i),' recording faces for ',h.newface]],'value',length(msg)+1)
        
        i=i+1;
        if i>h.m
            trainface();
            break
        end
        pause(0.05)
    catch
        continue;
    end
end
%--------------------------------------------------------------
function Identify(varargin)
global h
h.call= ~h.call;
i=1;
load DB
threshold=0.4568;
if h.call
    set(h.Identify,'string','Stop');
else
    set(h.Identify,'string','Find Face');
end
drawnow
um=100;ustd=80;
while (h.call)
    try
        frame=step(h.obj);
        bbox=step(h.faceDetector,frame);
        imshow(frame);
        rectangle('Position',bbox,'EdgeColor','r','LineWidth',1)
        faceImage    = imcrop(frame,bbox);
        faceimageresize=imresize(faceImage, [200 180]);
        
        I=rgb2gray(faceimageresize);
        [r,c]=size(I);
        I=reshape(double(I'),c*r,1);
        me=mean(I);
        st=std(I);
        I=(I-me)*ustd/st+um;
        
        load DB
        Min=[];
        for i=1:length(DB)
            u=DB(i).u;
            m=DB(i).m;
            omega=DB(i).omega;
            p = [];
            for i = 1:size(u,2)
                p = [p; dot(I,u(:,i))];
            end
            Im=double(m) + u(:,1:size(u,2))*p;
            Im=reshape(Im,c,r)';
            I=I';W=[];
            for i=1:size(u,2)
                W=[W;dot(u(:,i)',I)];
            end
            
            e=[];
            for i=1:size(omega,2)
                e = [e,norm(W-omega(:,i))];
            end
            Min=[Min min(e)];
        end
        [value,index]=min(Min);
        if value>h.threshold;
            name='who are you?'
        else
            name=DB(index).name
            %
%             Issue serial port command from here
            %
        end
        %--------------------------------------------
        set(h.result,'string',name)
        msg=get(h.feed,'string');
        set(h.feed,'string',[msg;['returned face is : ',name]],'value',length(msg)+1)
        
        drawnow
    catch
        continue;
    end
end
%--------------------------------------------------------------
function Train(varargin)
global h
h.m=20;um=100;ustd=80;
I = rgb2gray(imread('1.jpg'));
[r,c]=size(I);D=r*c;
S=[];
for i=1:h.m
    img = rgb2gray(imread([num2str(i),'.jpg']));
    S=[S reshape(img',D,1)];
end
%--------------------------------------------------------------
S=double(S);
for i=1:size(S,2)
    temp=S(:,i);
    m=mean(temp);
    st=std(temp);
    S(:,i)=(temp-m)*ustd/st+um;
end
%--------------------------------------------------------------
m=mean(S,2);
%--------------------------------------------------------------
[v,d]=eig(S'*S);
indx=(diag(d)<1e-4);
v(:,indx)=[];
[b,index]=sort(d);
d=b(M:-1:1)';
ind=M-index(1:10)'+1;
v(:,ind)=v(:,[1:M]');
v=v./repmat(sqrt(sum(v.^2)),M,1);
u=zeros(size(S,1),M);
for i=1:M    
    u(:,i)=(S*v(:,i))./sqrt(d(i));
end
u=u./repmat(sqrt(sum(u.^2)),size(u,1),1);
omega = zeros(M,1);
for h=1:M
    W=[];
    for i=1:M        
        W = [W; dot(u(:,i)',S(:,h)')];
    end
    omega(:,h) = W;
end
%--------------------------------------------------------------
cd ..
cd ..
try
    load DB
end
if exist('DB')==2
    DB.name=h.newface;
    DB.omega=omega;
    DB.u=u;
    DB.m=m;
else
    L=length(DB);
    DB(L+1).name=h.newface;
    DB(L+1).omega=omega;
    DB(L+1).u=u;
    DB(L+1).m=m;
end
save DB DB;
%--------------------------------------------------------------
