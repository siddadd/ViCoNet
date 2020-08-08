%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%	  														     	 %%%	
%%%	  %%	   %%  %%   %%%%%%  %%%%%%  %%%   %%  %%%%%%  %%%%%%%%   %%%
%%%	   %%	  %%   %%   %% 	    %%  %%  %%%%  %%  %%		 %%		 %%%
%%%	    %%   %%	   %%   %%	    %%  %%  %% %% %%  %%%%%%	 %%      %%%
%%%	     %% %%	   %%   %%	    %%  %%  %%  %%%%  %%		 %%		 %%%	
%%%	      %%%      %%   %%%%%%  %%%%%%  %%  %%%%  %%%%%%     %%		 %%%
%%%                                                               	 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%																	 %%%			 
%%% This function runs the baseline HMAX-ESVM pipeline simulation on %%%
%%% test data (ICCAD)               							     %%%
%%% 06/18/2015											      		 %%% 
%%% Siddharth Advani										      	 %%%
%%%																	 %%%		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 																 %%%		
%%% Copyright (c) 2015 Siddharth Advani                              %%%
%%% Distributed under the MIT License                                %%%
%%% See MITlicense.txt file in the distribution folder.              %%%
%%%                                                                  %%%
%%% Contact: Siddharth Advani at <ska130@cse.psu.edu>                %%%
%%%																	 %%% 		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [accuracy, k ] = simulateBaseline(params)

accuracy_count = 0; 
num_total = 0; 
    
ESVM_VALID = ones(102,1);

for i = 0:101
   if (ismember(i, [3, 5, 7, 13, 14, 16, 17, 22, 24, 25, 27, 30, 32, 35, 36, 37, 38, 47, 49, 51, 53, 54, 56, 58, 62, 63, 65, 66, 67, 68, 70, 81, 84, 89, 94, 95, 96, 97, 98, 99]))
    ESVM_VALID(i+1) = 0;
   end
end

ESVM_VALID = logical(ESVM_VALID); 

numValidClasses = numel(find(ESVM_VALID==1));
fprintf('Total number of valid classes = %d\n', numValidClasses);

fid_mapping = fopen(params.CLASS_ID_MAPPING,'r');
if fid_mapping == -1, error('Cannot open mapping file'); end
    
classMappings = textscan(fid_mapping, '%s%s%s', 'delimiter', ',');
fclose(fid_mapping);

class_ids = classMappings{1};
class_names = classMappings{2};
max_esvm_scores = classMappings{3};

fid_aisle = fopen(params.AISLE_ID_MAPPING, 'r');
if fid_aisle == -1, error('Cannot open aisle mapping file'); end
    
aisleMappings = textscan(fid_aisle, '%s');
fclose(fid_aisle);

aisleInfo = aisleMappings{1};

% Evaluation for each aisle starts here 
for a = 1:size(aisleInfo,1)         
    
    aisle_str = aisleInfo{a};
    
    aisle_data = strsplit(aisle_str, ',');
    
    aisle_id = aisle_data{1};
    aisle_name = aisle_data{2};
    
    fprintf('Evaluating %s\n', aisle_name);
    
    hmax_annotations = dir([params.INPUT_ANNOTATION_FILES,'/', aisle_name, '_hmax', '*' , params.ANNOTATION_FILE_TYPE]);
    esvm_annotations = dir([params.INPUT_ANNOTATION_FILES,'/', aisle_name, '_esvm', '*' , params.ANNOTATION_FILE_TYPE]);
	gt_annotations = dir([params.INPUT_ANNOTATION_FILES,'/', aisle_name, '_gt', '*' , params.ANNOTATION_FILE_TYPE]);
    
    perm = randperm(numel(hmax_annotations));
    
    for p = 1:numel(perm)        
        
        fid_hmax_ann = fopen(fullfile(params.INPUT_ANNOTATION_FILES,hmax_annotations(perm(p)).name));
        if fid_hmax_ann == -1
            fprintf('Cannot open annotation file for %s\n', hmax_annotations(perm(p)).name);
            return; 
        end                                   
        
        % Get HMAX scores
        hmax_data = textscan(fid_hmax_ann, '%s%f', 'delimiter', ',');
        hmax_ids = hmax_data{1};
        hmax_scores = hmax_data{2};
        fclose(fid_hmax_ann);
        
        % Select Top 20 candidates
        [hmax_sorted_scores, hmax_indices] = sort(hmax_scores, 'descend'); 
                
        hmax_top_k = hmax_ids(hmax_indices(1:params.K));
        
        % Get ESVM scores
        fid_esvm_ann = fopen(fullfile(params.INPUT_ANNOTATION_FILES,esvm_annotations(perm(p)).name));
        esvm_data = textscan(fid_esvm_ann, '%s%f', 'delimiter', ',');
        esvm_ids = esvm_data{1};
        esvm_scores = esvm_data{2};
        
        esvm_ids = hmax_ids; % ESVMs are 102 and HMAX are 62, just making ESVMs match HMAX
        esvm_scores = esvm_scores(ESVM_VALID);
        
        fclose(fid_esvm_ann);
                      
        esvm_max_score = 0; 
        
        for h = 1:numel(hmax_top_k)
           str2Find = hmax_top_k{h};
           matches = strcmp(str2Find, esvm_ids);
           index = find(matches==1,1);
           esvm_top_score = esvm_scores(index);
           esvm_top_id = esvm_ids(index);
           if esvm_top_score >= esvm_max_score
              esvm_max_score = esvm_top_score;
              esvm_winner = esvm_top_id;
           end
        end                               
        
        % Compare with ground truth		
		fid_gt_ann = fopen(fullfile(params.INPUT_ANNOTATION_FILES,gt_annotations(perm(p)).name));
		gt_data = textscan(fid_gt_ann, '%s%f', 'delimiter', ',');
		gt = gt_data{1};
		fclose(fid_gt_ann);		
        
        %bool_idx = strcmp(['<Object Tag="' object_tag '">'], GT);
        %idx = find(bool_idx);
        %gt_str = GT{idx+9};
        %
        %[s, f, t] = regexp(gt_str, '"'); 
        %
        %gt = gt_str(s(1)+1:s(2)-1);
       
        if strcmp(gt, esvm_winner{1})
            accuracy_count = accuracy_count + 1;             
        end
        
        num_total = num_total + 1; 
        
    end
end

avg_accuracy = accuracy_count/num_total * 100  ;

fprintf('Average Baseline Accuracy = %f\n', avg_accuracy);
fprintf('Average K = %f\n', params.K);

accuracy = avg_accuracy;  
k = params.K; 
