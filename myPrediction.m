function detected = myPrediction(testImage,sceneFeatures,nFaces)
% Companion file for streamingFaceRecognition demo
% Brett Shoelson, PhD
% brett.shoelson@mathworks.com
% 3/3/2015

% Copyright The MathWorks, Inc. 2015

fcnHandle = @(x) detectFASTFeatures(x,...
	'MinQuality',0.025,...
	'MinContrast',0.025); %#ok
extractorMethod = 'SURF'; %#ok
metric = 'SAD'; %#ok
% adjustHistograms = false;
% if adjustHistograms
% 	testImage = histeq(testImage);
% end
%
boxPoints = fcnHandle(testImage);
[boxFeatures, boxPoints] = extractFeatures(testImage, boxPoints,...
	'Method',extractorMethod,...
	'BlockSize',3,...
	'SURFSize',64);
matchMetric = zeros(size(boxFeatures,1),nFaces);
for ii = 1:nFaces
	[~,matchMetric(:,ii)] = matchFeatures(boxFeatures,sceneFeatures{ii},...
		'MaxRatio',1,...
		'MatchThreshold',100,...
		'Metric',metric);
end
% if min(mean(matchMetric)) > 1.5
% 	detected = 0;
% else
	[~,detected] = min(mean(matchMetric));
% end