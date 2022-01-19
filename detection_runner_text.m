function detection_runner_text()

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

% fprintf('compiling the code...');
% compile;
% fprintf('done.\n\n');

% load model
load('VOC2010/person_final');


% Process a single image
% detect('/home/alex/Pictures/0000000146.jpg', model, 1, '146.jpg');


% Process all images in a folder
% files = dir('/Users/alex/Research/Data/images_2/*.jpg');
% fileID = '/Users/alex/Research/Data/images_2/exp.txt';
% for k = 1:length(files)
%     box = detect(join(['/Users/alex/Research/Data/images_2/',files(k).name]), model, 1);
%     writematrix(box, fileID, 'WriteMode', 'append')
% %     disp("### "+ k + "/" + length(files) + "    " + files(k).name);
% end
% fclose('all');


% % Process data


% Base directory (RawData)
base_dir = '/Users/alex/Research/Data/RawData/';
cam_dirs = ["images_0", "images_1"];


base_dir_list = dir(join([base_dir, '*']));

% Match directories with name matching the YYYY_MM_DD date pattern
date_pattern = digitsPattern(4) + "_" + digitsPattern(2) + "_" + digitsPattern(2);
match_date = matches({base_dir_list.name}, date_pattern);
date_dirs = strings;
for i = 1:length(base_dir_list)
    if match_date(i)
        date_dirs(end+1) = base_dir_list(i).name;
    end
end
date_dirs = date_dirs(2:end);

% Process by date
for i = 1: length(date_dirs)
    % Build the full path for a give date directory
    date_dir = join([base_dir, date_dirs(i),'/'], '');
    date_dir_list = dir(join([date_dir,'*'], ''));
    % Match directories with name matching 
    % YYYY_MM_DD_{{specific description of the entry}}
    entry_pattern = digitsPattern(4) + "_" + digitsPattern(2) + "_" + digitsPattern(2) + "_" + wildcardPattern;
    match_entry = matches({date_dir_list.name}, entry_pattern);
    for j = 1:length(date_dir_list)
        if match_entry(j)
            % Build the full for the directory of a specific data entry
            entry_dir = join([date_dir, date_dir_list(j).name, '/'], '');
            disp(entry_dir);
            
            for k = 1:length(cam_dirs)
                disp(join(["Processing: ", entry_dir, cam_dirs(k)], ''));
                images_list = dir(join([entry_dir, cam_dirs(k), '/*.jpg'], ''));
                fileID = join([entry_dir, cam_dirs(k), '/bbox.txt'], '');
                for l = 1:length(images_list)
                    box = detect(join([entry_dir, cam_dirs(k), '/',images_list(l).name], ''), model, 1);
                    writematrix(box, fileID, 'WriteMode', 'append')
                end
                fclose('all');
            end
        end
    end

end





% detection runner
function out = detect(imname, model, num_dets)
cls = model.class;

im = imread(imname);
im = imresize(im, [480 NaN]);

clf;
image(im);

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
    end
    

    if model.type == model_types.MixStar
      % get bounding boxes
      bbox = bboxpred_get(model.bboxpred, ds, reduceboxes(model, bs));
      bbox = clipboxes(im, bbox);
      top = nms(bbox, 13.5);
      clf;
      
      out = output_box(im, bbox(top,:));
    end
% otherwise just export the image
else
    clf;

    out = [-1 -1 -1 -1];
%     disp("no detection in " + fname);
end


