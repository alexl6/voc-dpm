function detection_runner()

% AUTORIGHTS
% -------------------------------------------------------
% Copyright (C) 2011-2012 Ross Girshick
% Copyright (C) 2008, 2009, 2010 Pedro Felzenszwalb, Ross Girshick
% 
% This file is part of the voc-releaseX code
% (http://people.cs.uchicago.edu/~rbg/latent/)
% and is available under the terms of an MIT-like license
% provided in COPYING. Please retain this notice and
% COPYING if you use this file (or a portion of it) in
% your project.
% -------------------------------------------------------

startup;

fprintf('compiling the code...');
compile;
fprintf('done.\n\n');

% load model
load('VOC2010/person_final');
% model.vis = @() visualizemodel(model, ...
%                   1:2:length(model.rules{model.start})); %#ok<NODEF>
% load('VOC2010/person_grammar_final');
% model.class = 'person grammar';
% model.vis = @() visualize_person_grammar_model(model, 6);

% Process a single image
% detect('/home/alex/Pictures/0000000146.jpg', model, 1, '146.jpg');


% Process all images in a folder
files = dir('/Users/alex/Research/Data/images_2/*.jpg');
for k = 1:length(files)
    detect(join(['/Users/alex/Research/Data/images_2/',files(k).name]), model, 1, files(k).name);
     disp("### "+ k + "/" + length(files) + "    " + files(k).name);
end


% % Process data
% files2 = dir('/home/alex/Pictures/*');
% 
% % pattern for folder names that contains image data
% pattern = digitsPattern(4) + "_" + digitsPattern(2) + "_" + digitsPattern(2) + "_" + wildcardPattern;
% match = matches({files2.name}, pattern);
% 
% img_folders_date = strings;
% for k = 1:length(files2)
%     if match(k)
%         img_folders_date(end+1) = files2(k).name;
%     end
% end
% 
% disp(img_folders_date);






% detection runner
function detect(imname, model, num_dets, name)
cls = model.class;

im = imread(imname);
clf;
image(im);
axis equal; 
axis on;

% output file name
fname = extractBefore(name,'.jpg');
folder = '/Users/alex/Research/test_output/';
if ~exist(folder, 'dir')
  mkdir(folder);
end

% load and display model
% model.vis();

% detect objects
[ds, bs] = imgdetect(im, model, -0.5);



% draw bounding box if there are valid detections
if ~isempty(ds)
    top = nms(ds, 0.5);
    top = top(1:min(length(top), num_dets));
    ds = ds(top, :);
    bs = bs(top, :);
    clf;

    if model.type == model_types.Grammar
      bs = [ds(:,1:4) bs];
      % moved this inside so this will only run for Grammar models
      
%       disable image output
%       showboxes(im, reduceboxes(model, bs), [join([folder,'/',fname])]);
    end
    

    if model.type == model_types.MixStar
      % get bounding boxes
      bbox = bboxpred_get(model.bboxpred, ds, reduceboxes(model, bs));
      bbox = clipboxes(im, bbox);
      top = nms(bbox, 13.5);
      clf;
%       disable image output
%       showboxes(im, bbox(top,:), [join([folder,'/',fname])]);
      output_box(im, bbox(top,:));
    end
% otherwise just export the image
else
    clf;
%     disable image output
%     showboxes(im,[], [join([folder,'/',fname])]);
    disp("no detection in " + fname);
end


