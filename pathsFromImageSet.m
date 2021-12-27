function [paths,allIms,allPaths] = pathsFromImageSet(imgSet)
% Helper 'method' for imageSet objects
% Brett Shoelson, PhD
% brett.shoelson@mathworks.com
%
% See also: imageSet, appendImageToImageSet, appendPathToImageSet,
% imageSetFromPaths, imageSetViewer, removeImageFromImageSet,
% removePathFromImageSet, subplotMontageFromImageSet

% Copyright 2015 The MathWorks, Inc.
if isa(imgSet,'imageSet')
	allIms = [imgSet.ImageLocation]';
	allPaths = [];
elseif isa(imgSet,'matlab.io.datastore.ImageDatastore')
	allIms = imgSet.Files;
end
if isempty(allIms)
	paths = [];
else
	fcn = @(x) fileparts(x);
	allPaths = cellfun(fcn,allIms,'UniformOutput',false);
	paths = unique(allPaths,'stable');
end