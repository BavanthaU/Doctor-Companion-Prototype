function imgOut = createMontage(cellArrayOfImages,varargin)
% Creates, but does not display, a UINT8 montage image comprising the
% images named in cellArrayOfImages. Images may be of different sizes and
% classes.
%
% SYNTAX:
% imgOut = createMontage(cellArrayOfImages)
% imgOut = createMontage(cellArrayOfImages,PVs)
%
% INPUTS:
% cellArrayOfImages: N-by-1 or 1-by-N cell array of image names.
%
% PVs: Any valid Parameter-Value pair, in any order, from this list:
%
%  'thumbSize'
%   The size to which subimages will be resized prior to concatenation.
%   Specified as [NROWS NCOLS].
%   ALTERNATIVELY: specify a scalar as a scale value for imresize.
%      TO SUPPRESS RESIZE: use thumbSize = [];
%      NOTE: This will error out if all images are not the same size!!
%   DEFAULT: [200 200]
%
%  'montageSize'
%   Two-element vector, [NROWS NCOLS], specifying the number of rows and
%   number of columns in the montage. Use NaNs in the size vector to
%   indicate that montage should calculate size in a particular dimension.
%   DEFAULT: Calculated so the images in the montage roughly form a
%   square. montage considers the aspect ratio when calculating the number
%   of images to display horizontally and vertically. See the 'size'
%   parameter for |montage| for more information.
%
%  'maintainAspectRatio'
%   T/F. If true, subimages will be padded to maintain their aspect ratios,
%   matching the 'thumbSize'. If false, subimages will be resized to the
%   specified 'thumbSize'. DEFAULT: true
%
%  'burnNames'
%   T/F. If true, and if the Computer Vision System Toolbox is on the
%   current license, image names will be burned in the output image.
%   DEFAULT: false.
%
%  'textProperties'
%   A cell array of text parameter-value pairs supported by insertText
%   (Computer Vision System Toolbox). This is ignored if 'burnNames' is
%   false or if the Computer Vision System Toolbox is not on the license in
%   use. Note that in this usage of 'insertText', 'Position' is specified
%   as a parameter-value pair. 'Position' is the [x y] coordinate for the
%   'AnchorPoint' of the text bounding box(See doc for insertText, and
%   Example 2 below.)
%
%  'includePathnames'
%   T/F. Indicates whether pathnames are included in image names that are
%   burned into the output image if 'burnNames' is true. If pathnames are
%   included, strings will be automatically wrapped to facilitate display.
%   DEFAULT: false.
%
%  'customLabels'
%   A cell array of strings to burn, in lieu of auto-recognized
%   names/paths. (Note that providing customLabels will ignore 'burnImages'
%   and 'includePathnames'. Also, this option requires the Computer Vision
%   System Toolbox.)
%
% % EXAMPLES:
% % Example 1: Create an image of all sample PNG images in the Image
% %            Processing Toolbox collection:
% imLoc = fullfile(matlabroot,'toolbox','images','imdata');
% imNames = dir(fullfile(imLoc,'*.png'));
% imNames = {imNames.name};
% imgOut = createMontage(imNames);
% figure,imshow(imgOut)
%
% % Example 2: Re-create an image of all sample TIFF images in the Image
% %            Processing Toolbox collection using non-default values,
% %            burning image names.
% imLoc = fullfile(matlabroot,'toolbox','images','imdata');
% imNames = dir(fullfile(imLoc,'*.tif'));
% imNames = {imNames.name};
% imgOut = createMontage(imNames,...
%    'maintainAspectRatio',false,...
%    'thumbSize',[300 300],...
%    'montageSize',[5 7],...
%    'burnNames',true,...
%    'textProperties',{'TextColor', 'r',...
%                      'Fontsize', 22,...
%                      'BoxOpacity',0,...
%                      'Position',[5 10]},...
%    'includePathnames',true);
% figure,imshow(imgOut)
%
% % Example 3: Same as Example 2, but using custom labels (image names,
% % with extensions stripped):
%   imLoc = fullfile(matlabroot,'toolbox','images','imdata');
%   imNames = dir(fullfile(imLoc,'*.tif'));
%   imNames = {imNames.name};
%   stripExtensions = @(x) x(1:strfind(x,'.')-1);
%   customNames = cellfun(stripExtensions,imNames,'UniformOutput',false);
%   imgOut = createMontage(imNames,...
%      'maintainAspectRatio',false,...
%      'thumbSize',[300 300],...
%      'montageSize',[5 7],...
%      'customLabels',customNames,...
% 	 'textProperties',{'TextColor', 'r',...
%                        'Fontsize', 64,...
%                        'BoxOpacity',0,...
%                        'Position',[5 10]});
%   figure,imshow(imgOut)
%
% NOTE: A dependency analysis will show that this function requires the
% Computer Vision System Toolbox. However, everything _except burning
% filenames_ will work just fine without that Toolbox. The Image Processing
% Toolbox is required. Special thanks to Steve Eddins for the use of his
% linewrap function.
%
% By Brett Shoelson, PhD.
% brett.shoelson@mathworks.com
% 12/16/2014
%
% See also: montage, imresize, insertText

% Copyright 2014 The MathWorks, Inc.
% Revisions:
%   1/26/2015: Facilitates passing in an array of labels--so you can burn
%   any label-- not just auto-recognized image names.
%   
%   4/7/2015:  Facilitates NOT resizing subimages (using an empty array for
%   thumbSize). This can be useful if no resizing is desired, but will
%   trigger an error unless all images are the same size!
%
%   4/19/2015: May now specify a scalar for thumbsize, to indicate imresize
%   by a scalar factor.

narginchk(1,13)
[thumbSize, montageSize, maintainAspectRatio, burnNames, textProperties, includePathnames, customLabels] = parseInputs(varargin{:});
hasCVST = ~isempty(ver('vision'));
% If any image is truecolor, all must be truecolor!
includesTruecolor = false;
for ii = 1:numel(cellArrayOfImages)
	testval = imfinfo(cellArrayOfImages{ii});
	if strcmp(testval(1).ColorType,'truecolor')
		includesTruecolor = true;
		break
	end
end
%
thumbnails = [];
if burnNames || ~isempty(customLabels)
	if hasCVST
		Position = [10 10]; % Default
		Fontsize = 18; % Default
		% Was 'Position' specfied?
		tmp = cellfun(@(x) strfind(x,'Position'),textProperties,'UniformOutput',false);
		tmp = find(~cellfun(@isempty,tmp));
		if ~isempty(tmp)
			Position = textProperties{tmp+1};
			textProperties([tmp,tmp+1]) = [];
		end
		% Was 'Fontsize' specfied?
		tmp = cellfun(@(x) strfind(x,'Fontsize'),textProperties,'UniformOutput',false);
		tmp = find(~cellfun(@isempty,tmp));
		if ~isempty(tmp)
			Fontsize = textProperties{tmp+1};
		end
		Linespace = Fontsize + 10;
	else
		warning('createMontage: Burning of names requires a license for Computer Vision System Toolbox.')
	end
end
%
for ii = 1:numel(cellArrayOfImages)
	[img,map] = imread(cellArrayOfImages{ii});
	if ~isempty(map)
		img = ind2rgb(img,map);
	end
	img = im2uint8(img);
	subImg = makeSubimage(img,maintainAspectRatio,thumbSize);
	%size(subImg)
	if includesTruecolor
		[~,~,p] = size(subImg);
		if p~=3, subImg = repmat(subImg,[1 1 3]);end
	end
	if (burnNames || ~isempty(customLabels)) && hasCVST
		%warning('on','MATLAB:system:nonRelevantProperty');
		tmpName = cellArrayOfImages{ii};
		if includePathnames && isempty(customLabels)
			tmpName = which(tmpName);
			% NOTE: That could return empty if file is not on the ML
			% path!!!
			if isempty(tmpName)
				tmpName = cellArrayOfImages{ii};
			end
			tmpName = regexprep(tmpName,'\','\\ ');
			tmpName = linewrap(tmpName,25);
			tmpName = regexprep(tmpName,'\\ ','\\');
			newPosition = [repmat(Position(1),size(tmpName,1),1),...
				Position(2)+(0:size(tmpName,1)-1)'*Linespace];
			subImg = insertText(subImg,newPosition,tmpName,textProperties{:});
		else
			if ~isempty(customLabels)
				tmpName = customLabels{ii};
			else
				[~,tmpName,ext] = fileparts(tmpName);
				tmpName = [tmpName,ext];%#ok
			end
			subImg = insertText(subImg,Position,tmpName,textProperties{:});
		end
	end
	thumbnails = cat(4, thumbnails, subImg);
end
tmi = figure('visible','off');
if isempty(montageSize)
	imgOut = montage(thumbnails);
else
	imgOut = montage(thumbnails,'size',montageSize);
end
imgOut = get(imgOut,'cdata');
delete(tmi)
end

function subimg = makeSubimage(I,maintainAspectRatio,thumbSize)
if numel(thumbSize) == 1
	% scalar passed in
	maintainAspectRatio = false;
end
if ~isempty(thumbSize)
	if maintainAspectRatio
		[m,n,~] = size(I);
		pcts = thumbSize./[m,n];
		subimg = imresize(I,min(pcts));
		%Pad to thumbSize:
		[m,n,~] = size(subimg);
		% Defensive programming; pcts is floating point, and subimg may end up
		% being 1 pixel too big in either direction. That triggers an error in
		% my call to padarray
		if any([m>thumbSize(1),n>thumbSize(2)])
			subimg = subimg(1:min(m,thumbSize(1)),1:min(n,thumbSize(2)),:);
			[m,n,~] = size(subimg);
		end
		subimg = padarray(subimg,[round((thumbSize(1)-m)/2) ceil((thumbSize(2)-n)/2)]);
		subimg = subimg(1:thumbSize(1),1:thumbSize(2),:);
	else
		subimg = imresize(I,thumbSize);
	end
else
	subimg = I;
end
end

function [thumbSize, montageSize, maintainAspectRatio, burnNames, textProperties, includePathnames, customLabels] = parseInputs(varargin)
% Setup parser with defaults
parser = inputParser;
parser.CaseSensitive = true;
parser.FunctionName  = 'createMontage';
parser.addParameter('thumbSize', [200 200]);
parser.addParameter('montageSize', []);
parser.addParameter('maintainAspectRatio', true);
parser.addParameter('burnNames', false);
parser.addParameter('customLabels',{});
parser.addParameter('textProperties',...
	{'TextColor', 'w',...
	'FontSize', 18,...
	'BoxColor','blue',...
	'BoxOpacity',0.8,...
	'Position', [10 10]});
parser.addParameter('includePathnames',false);
% Parse input
parser.parse(varargin{:});
% Assign outputs
r = parser.Results;
[thumbSize, montageSize, maintainAspectRatio, burnNames,...
	textProperties, includePathnames, customLabels] = ...
	deal(r.thumbSize, r.montageSize, r.maintainAspectRatio, ...
	r.burnNames, r.textProperties, r.includePathnames, r.customLabels);
end

