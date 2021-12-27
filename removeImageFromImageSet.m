function imgSet = removeImageFromImageSet(imgSet,imagePath)
% Helper 'method' for imageSet objects
% Brett Shoelson, PhD
% brett.shoelson@mathworks.com
%
% See also: imageSet, appendImageToImageSet, appendPathToImageSet,
% imageSetFromPaths, imageSetViewer, pathsFromImageSet,
% removePathFromImageSet, subplotMontageFromImageSet

% Copyright 2015 The MathWorks, Inc.
paths = pathsFromImageSet(imgSet);
pathToAmmend = fileparts(imagePath);
index = find(strcmp(paths,pathToAmmend));
imagesOnPath = [imgSet(index).ImageLocation];
newImagesOnPath = setdiff(imagesOnPath,imagePath);
description = imgSet(index).Description;
imgSet(index) = [];
if ~isempty(newImagesOnPath)
	tmpImgSet = imageSet(newImagesOnPath);
	tmpImgSet.Description = description;
	imgSet = [imgSet,tmpImgSet];
	reorderInds = [1:index-1,numel(imgSet),index:numel(imgSet)-1];
	imgSet = imgSet(reorderInds);
else
	beep
	pn = fileparts(imagePath);
	sep = strfind(fileparts(imagePath),filesep);
	desc = pn(sep(end)+1:end);
	disp(['Empty image set for ', desc, ' has been removed'])
	%disp('Image set is empty, and has been removed.')
end