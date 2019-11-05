%% load parameters
clear all;clc;
Nblock=2;
Ntrial=48;% 6*8 item in total
Nexpall=Nblock*Ntrial;

% % video scale
% scale=3;
% fps1=30; % refresh rate for the movie

% load videos
folder=cd;
load('VideoMatnd.mat')
VideoMat=VideoMatnd;
expressions=fieldnames(VideoMat);
itemall=fieldnames(VideoMat.Anger);
Nrep=Nexpall/(size(expressions,1)*size(itemall,1));
ii=0;
clear exptable;
for irep=1:Nrep
    for iexp=1:size(expressions,1)
        for iitem=1:size(itemall,1)
            ii=ii+1;
            exptable(ii,1)=expressions(iexp);
            exptable(ii,2)=itemall(iitem);
        end
    end
end
%%
% redirect to data folder
cd([folder '\data1'])
datanames=dir('*_DyExp_beh.txt');
dataset1=struct;
Ns=length(datanames);
expression={'Fear','Anger','Disgust','Happiness','Sadness','Surprise'};
dataMAT=zeros(Ns,length(expression),length(expression),3);
tmp=repmat([2 3 1 4 5 6],8,1);
itemtype=repmat(tmp(:),2,1);
for is=1:Ns
    filename=datanames(is).name;
    behdata=fopen(filename);
    datamat=textscan(behdata,'%n%n%n%n%n%n%n%n%n');
    % datamat=textscan(behdata,'%n%n%n%n%n%n%n%n%n%n');
    % block=unique(datamat{10},'stable');
    trial=datamat{1};
    resp=datamat{2};
    rt=datamat{4};
    randseq=datamat{9};
    % store information of subject
    blk=strfind(filename,'_');
    dataset1(is).age=filename((blk(end-2)+2):(blk(end-1)-1));
    dataset1(is).gender=filename((blk(end-3)+2):(blk(end-2)-1));
    dataset1(is).name=filename(1:(blk(end-3)-1));
    %% create respond matrix
    respMAT=zeros(6,6,3);
    startt=find(trial==96);
    % figure;hold on
    for itask=1:3
        task=itask;
        % task=block==itask;
        blockvect=startt(task)-95:startt(task);
        respvec=[itemtype,sortrows([randseq(blockvect),resp(blockvect)])];
        for iexp=1:6
            for iresp=1:6
                numrsp=sum(respvec(:,1)==iexp&respvec(:,3)==iresp);
                respMAT(iexp,iresp,itask)=numrsp;
            end
        end
        % scatter(randseq(blockvect),resp(blockvect));
%         for iitrial=1:96
%             indx1=blockvect(iitrial);
%             exptrial=exptable{randseq(indx1),1};
%             resptrial=resp(randseq(indx1));
%             expidx=strcmp(exptrial,expression);
%             respMAT(expidx,resptrial,task)=respMAT(expidx,resptrial,task)+1;
%         end
    end
    % save matrix
    dataset1(is).respM=respMAT;
    dataMAT(is,:,:,:)=respMAT;
end
%% visualize data
taskname={'dynamic','shuffle','static'};
figure;
for task=1:3
    datatmpMAT=squeeze(dataMAT(:,:,:,task));
    % figure;bar(sum(datatmpMAT(:,:),2))
    mat=squeeze(mean(datatmpMAT,1))./16;
    % mat=squeeze(trimmean(datatmpMAT,15,'round',1))./16;
    % mat=squeeze(dataMAT(1,:,:,task));
    % mat=respMAT(:,:,task);
    subplot(1,3,task)
    %
    imagesc(mat);
    axis square;
    % display result
    textStrings = num2str(mat(:),'%0.2f');  %# Create strings from the matrix values
    textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
    [x,y] = meshgrid(1:size(mat,1));   %# Create x and y coordinates for the strings
    hStrings = text(x(~isnan(mat(:))),y(~isnan(mat(:))),textStrings(~isnan(mat(:))),...      %# Plot the strings
        'HorizontalAlignment','center');
    midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
    textColors = repmat(mat(~isnan(mat(:))) < midValue,1,3);  %# Choose white or black for the
    %#   text color of the strings so
    %#   they can be easily seen over
    %#   the background color
    set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors
    
    set(gca,'XTick',1:size(mat,1),...                         %# Change the axes tick marks
        'XTickLabel',expression,...  %#   and tick labels
        'YTick',1:size(mat,1),...
        'YTickLabel',expression,...
        'TickLength',[0 0],...
        'xdir','reverse','ydir','normal');
    xlabel('response')
    ylabel('expression')
    title(taskname{task})
end
%%
figure;
for iexp=1:6
    improve=squeeze(dataMAT(:,iexp,:,1)-dataMAT(:,iexp,:,3));
    subplot(2,3,iexp);hold on
    for ii=1:6
        if ii~=iexp
            scatter(improve(:,iexp),improve(:,ii))
        end
    end
    title(expression{iexp})
    kk=1:6;
    kk(iexp)=[];
    expresslabel=expression(kk);
    legend(expresslabel)
    lsline
end
%%
% for is=1:size(dataMAT,1)
%     improve1(is)=trace(squeeze(dataMAT(is,:,:,1))./16-squeeze(dataMAT(is,:,:,3))./16);
%     improve2(is)=norm(squeeze(dataMAT(is,:,:,1))./16-squeeze(dataMAT(is,:,:,3))./16);
% end

