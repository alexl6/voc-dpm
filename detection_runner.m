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

% Disable compilation after first run

% fprintf('compiling the code...');
% compile;
% fprintf('done.\n\n');

% load model
load('VOC2010/person_final');

% Process a single image
% detect('/Users/alex/Research/Data/0000000003.jpg', model, 1, '3.jpg');


% Process all images in a folder
% files = dir('/Users/alex/Research/Data/thres_samples/*.jpg');
% fileID = join(['/Users/alex/Research/thres_output', '/bbox.csv'], '');
% % disp(repmat([5],[3 1]));
% for k = 1:length(files)
% %     writematrix(files(k).name, fileID, 'WriteMode', 'append');
%     box = detect(join(['/Users/alex/Research/Data/thres_samples/',files(k).name]), model, 1, files(k).name);
%     % Append a column in front representing the file name
%     first_col = repmat(str2num(files(k).name(1:end-4)), [height(box) 1]);
%     writematrix([first_col, round(box, 3)], fileID, 'WriteMode', 'append');
%     disp("### "+ k + "/" + length(files) + "    " + files(k).name);
% end

% Process images for a given date
    samples_dir = "/Users/alex/Research/Image Tests/";
    samples_list = dir(join(samples_dir, "*"));
    % Match directories with name matching 
    % YYYY_MM_DD_{{specific description of the entry}}
    entry_pattern = digitsPattern(4) + "_" + digitsPattern(2) + "_" + digitsPattern(2) + "_" + wildcardPattern;
    match_entry = matches({samples_list.name}, entry_pattern);
    for j = 1:length(samples_list)
        if match_entry(j)
            % Build the full for the directory of a specific data entry
            entry_dir = join([samples_dir, samples_list(j).name, '/'], '');
            disp(join(["Processing: ", entry_dir], ''));
            images_list = dir(join([entry_dir, '*.jpg'], ''));
            fileID = join([entry_dir, '/bbox.csv'], '');
            for l = 1:length(images_list)
                box = detect(join([entry_dir, '/',images_list(l).name], ''), model, entry_dir, images_list(l).name);
                % Append a column in front representing the file name
                first_col = repmat(str2double(images_list(l).name(1:end-4)), [height(box) 1]);
                writematrix([first_col, round(box, 3)], fileID, 'WriteMode', 'append');
            end
            fclose('all');
        end
    end

fclose('all');

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
function out = detect(imname, model, out_dir, name)
cls = model.class;

im = imread(imname);
im = imresize(im, [480 NaN]);

clf;
image(im);
axis equal; 
axis on;

% output file name
fname = extractBefore(name,'.jpg');
folder = join([out_dir, "with_box"], '');
if ~exist(folder, 'dir')
  mkdir(folder);
end

% detect objects
[ds, bs] = imgdetect(im, model, -0.5); %was -0.5


% draw bounding box if there are valid detections
if ~isempty(ds)
    top = nms(ds, 0.5);
    top = top(1:min(length(top), 5));
    ds = ds(top, :);
    bs = bs(top, :);
    clf;
    
    if model.type == model_types.MixStar
      % get bounding boxes
      bbox = bboxpred_get(model.bboxpred, ds, reduceboxes(model, bs));
      bbox = clipboxes(im, bbox);
      top = nms(bbox, 0.3);
      clf;
      
      % size check
      w = bbox(:,3) - bbox(:,1);
      h = bbox(:,4) - bbox(:,2);
      
      % top2 holds the filtered list of top boxes
      top2 = [];
      
      % check confidence level (threshold depends on box size)
      for i = 1:length(top)
          j = top(i);
          if (bbox(j,5) < -0.35) || ((bbox(j,5) < 0.6) && (h(j) < 300) && (w(j) < 80))
              disp(bbox(j,:));
              continue;
          end
          top2 = [top2 j];
      end
        
      % output images
      showboxes(im, bbox(top2,:), join([folder,'/',fname], ''));
      out = bbox(top2,:);

    end
% otherwise just export the image
else
    clf;
    % output original image
    showboxes(im,[], [join([folder,'/',fname])]);
    out = [-1 -1 -1 -1 -1];
    disp("no detection in " + fname);
end


