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
%%% This function runs ViCoNet and weights the scores 			     %%%
%%% of HMAX-ESVM pipeline (under review)	    					 %%%
%%% Context switch is dynamic 								         %%%
%%% 06/19/2015											      		 %%% 
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
function [accuracy, k, temporal_context_score, test_analysis] = simulateViCoNetWeight(params)

[VCOM, VSOM, Key, Map] = buildVCOM(params);

accuracy_count = 0;
num_total = 0;
kavg = 0;

ESVM_VALID = ones(102,1);

for i = 0:101
    if (ismember(i, [3, 5, 7, 13, 14, 16, 17, 22, 24, 25, 27, 30, 32, 35, 36, 37, 38, 47, 49, 51, 53, 54, 56, 58, 62, 63, 65, 66, 67, 68, 70, 81, 84, 89, 94, 95, 96, 97, 98, 99]))
        ESVM_VALID(i+1) = 0;
    end
end

ESVM_VALID = logical(ESVM_VALID);

numValidClasses = numel(find(ESVM_VALID==1));
fprintf('Total number of valid classes = %d\n', numValidClasses);

test_analysis = zeros(1,numValidClasses);  

%% need to encode all of this in Mapping so we can get rid of all this 
fid_num_class = fopen(params.NUM_TEST_CLASS_DATA, 'r');
if fid_num_class == -1, error('Cannot open number test class data file'), end 
num_test_classes = textscan(fid_num_class, '%s', 'delimiter', '\n', 'whitespace', '');
fclose(fid_num_class);

fid_mapping = fopen(params.CLASS_ID_MAPPING,'r');
if fid_mapping == -1, error('Cannot open mapping file'); end

classMappings = textscan(fid_mapping, '%s%s%s', 'delimiter', ',');
fclose(fid_mapping);

class_ids = classMappings{1};
class_names = classMappings{2};
max_esvm_scores = classMappings{3};

fid_aisle = fopen(params.AISLE_ID_MAPPING', 'r');
if fid_aisle == -1, error('Cannot open aisle mapping file'); end

aisleMappings = textscan(fid_aisle, '%s');
fclose(fid_aisle);

aisleInfo = aisleMappings{1};

permaisle = randperm(size(aisleInfo,1));

% use this as a queue (fifo)
ConQueue = cell(params.BUILD_CONTEXT_TIME, 1);
%use this to track baseline scores (first col tracks HMAX-RLS score and second col tracks ESVM score
ConQueueConfidence = zeros(params.BUILD_CONTEXT_TIME,2);
%use this to take running averages
vcom_scores = zeros(params.BUILD_CONTEXT_TIME, numValidClasses);
    
%ViCoNet score vector
VScores = zeros(numValidClasses,1);

noconfidence_count = 0;
roi_count = 0;
build_context = 1;
num_bc_count = 0;
    
%% Navigate through each aisle
for a = 1:numel(permaisle)  
    
%     % use this as a queue (fifo)
%     ConQueue = cell(params.BUILD_CONTEXT_TIME, 1);
%     %use this to take running averages
%     vcom_scores = zeros(params.BUILD_CONTEXT_TIME, numValidClasses);
%     
%     %ViCoNet score vector
%     VScores = zeros(numValidClasses,1);
    
    %pred_aisle_id = zeros(params.BUILD_CONTEXT_TIME,1);
    %pred_aisle_class = {};
    
%     build_context = 1;
%     num_bc_count = 0;
    
    aisle_str = aisleInfo{permaisle(a)};
    
    aisle_data = strsplit(aisle_str, ',');
    
    %aisle_id = aisle_data{1};
    aisle_name = aisle_data{2};
    
    fprintf('Evaluating items in %s\n', aisle_name);
    
    hmax_annotations = dir([params.INPUT_ANNOTATION_FILES,'/', aisle_name, '_hmax', '*' , params.ANNOTATION_FILE_TYPE]);
    esvm_annotations = dir([params.INPUT_ANNOTATION_FILES,'/', aisle_name, '_esvm', '*' , params.ANNOTATION_FILE_TYPE]);
    gt_annotations = dir([params.INPUT_ANNOTATION_FILES,'/', aisle_name, '_gt', '*' , params.ANNOTATION_FILE_TYPE]);
    
    permprod = randperm(numel(hmax_annotations));
    
    % Iterate through the aisle randomly
    for p = 1:numel(permprod)        

        roi_count = roi_count + 1; 
        
        if (num_bc_count == params.BUILD_CONTEXT_TIME)
            %fprintf('Start Querying\n');
            build_context = -1;
        end
        
        fid_hmax_ann = fopen(fullfile(params.INPUT_ANNOTATION_FILES,hmax_annotations(permprod(p)).name));
        if fid_hmax_ann == -1, error('Cannot open annotation file'); end
        
        % Get HMAX scores
        hmax_data = textscan(fid_hmax_ann, '%s%f', 'delimiter', ',');
        hmax_ids = hmax_data{1};
        hmax_scores = hmax_data{2};
        fclose(fid_hmax_ann);
        
        % Select Top 20 candidates
        [hmax_sorted_scores, hmax_indices] = sort(hmax_scores, 'descend');
        
        hmax_top_k = hmax_ids(hmax_indices(1:params.K));
        
        % Get ESVM scores
        fid_esvm_ann = fopen(fullfile(params.INPUT_ANNOTATION_FILES,esvm_annotations(permprod(p)).name));
        esvm_data = textscan(fid_esvm_ann, '%s%f', 'delimiter', ',');
        esvm_ids = esvm_data{1};
        esvm_scores = esvm_data{2};
        
        esvm_ids = hmax_ids; % ESVMs are 102 and HMAX are 62, just making ESVMs match HMAX
        esvm_scores = esvm_scores(ESVM_VALID);
        
        fclose(fid_esvm_ann);
        
        esvm_max_score = 0;
        
        % Base pipeline
        if build_context ~= -1
            
            % Pick winner
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
            
            % Threshold
            kavg = kavg + numel(hmax_top_k);
            if esvm_max_score > params.ESVM_CONFIDENCE_THRESH; %MAX_ESVM_SCORES(index)/10000;
                if params.verbose
                    fprintf('ESVM score for predicted winner %s is %f. Using this to build context\n', char(class_names(str2double(char(esvm_winner))+1)), esvm_max_score);
                end
                build_context = 1;
            else
                if params.verbose
                    fprintf('ESVM score too low (%f). Not Using this to build context\n', esvm_max_score);
                end    
                build_context = 0;
            end
            
        end  % end base pipeline                      
        
        % To build context or not
        if (build_context == 1)            
            num_bc_count = num_bc_count + 1; 
            ConQueue{num_bc_count} = char(esvm_winner);
            % Use VCOM to find a probability feature given the winner from HMAX - ESVM
            vcom_scores(num_bc_count,:) = getOccurrenceDistribution(VCOM, VSOM, Key, class_names(str2double(char(esvm_winner))+1)); % ids start from 0
            temporal_context_score(roi_count) = corr2(vcom_scores(1:4,:), vcom_scores(5:8,:));
            fprintf('Build: Correlation Coefficient of Context Queue = %f\n', temporal_context_score(roi_count));            
        elseif (build_context == -1)
            %fprintf('We have built context. Let us use it\n');
            
            vcom_scores_mean = mean(vcom_scores);
            
            % Find correct mapping to be in sync with HMAX-ESVM
            for id = 1 : numValidClasses   
                vmatch = strcmp(Key(id), class_names);
                VScores(vmatch) = vcom_scores_mean(id); 
            end
            
            RScores = hmax_scores; 
            
            % EXPERIMENTAL
            % Weighting the use of ViCoNet depending upon the correlation
            % coefficient of the first half of the queue with the second
            % half
            %params.VAlpha = corr2(vcom_scores(1:4,:), vcom_scores(5:8,:));
            
            myScores = (1 - params.VAlpha).*RScores + params.VAlpha.*RScores.*VScores;
            myKindices = (myScores ~= 0); 
            
            % Pick top K if more than K
            if sum((myKindices==1)) > params.K
                % Sort by scores
                [my_sorted_scores, my_indices] = sort(myScores, 'descend');
        
                myK = hmax_ids(my_indices(1:params.K));                 
            else
                myK = hmax_ids((myKindices==1)); 
            end
            
            kavg = kavg + numel(myK);
            
            % Predict Winner
            for h = 1:numel(myK)
                str2Find = myK{h};
                matches = strcmp(str2Find, esvm_ids);
                index = find(matches==1,1);
                esvm_top_score = esvm_scores(index);
                
                esvm_top_id = esvm_ids(index);
                if esvm_top_score >= esvm_max_score
                    esvm_max_score = esvm_top_score;
                    esvm_winner = esvm_top_id;
                end
                
            end
            
            % Update running context queue
            ConQueue(1:end-1) = ConQueue(2:end);
            ConQueue{end} = char(esvm_winner);
                        
            ConQueueConfidence(:,1) = hmax_scores(1+cellfun(@str2num, ConQueue)); % adding one since ids start from 0
            ConQueueConfidence(:,2) = esvm_scores(1+cellfun(@str2num, ConQueue)); % adding one since ids start from 0
                        
            vcom_scores(1:end-1,:) = vcom_scores(2:end,:);
            vcom_scores(end,:) = getOccurrenceDistribution(VCOM, VSOM, Key, class_names(str2double(char(esvm_winner))+1)); % ids start from 0
            temporal_context_score(roi_count) = corr2(vcom_scores(1:4,:), vcom_scores(5:8,:));
            fprintf('Query:Correlation Coefficient of Context Queue = %f\n', temporal_context_score(roi_count));
            
            % Decide based on base pipeline confidence whether to flush context queue
            % Allow 50% of the context time
            if (all(ConQueueConfidence(:,1) < 0) && all(ConQueueConfidence(:,2) < params.ESVM_CONFIDENCE_THRESH))
                if (noconfidence_count > 0.5*params.BUILD_CONTEXT_TIME)
                    build_context = 1;
                    num_bc_count = 0;
                    clear ConQueue;
                    clear ConQueueConfidence;
                    clear vcom_scores;
                    vcom_scores = zeros(params.BUILD_CONTEXT_TIME, numValidClasses);
                    noconfidence_count = 0;
                else
                    noconfidence_count = noconfidence_count + 1;
                end
            end
            
        end % end context
        
        % Compare with ground truth
        
        fid_gt_ann = fopen(fullfile(params.INPUT_ANNOTATION_FILES,gt_annotations(permprod(p)).name));
        gt_data = textscan(fid_gt_ann, '%s%f', 'delimiter', ',');
        gt = gt_data{1};
        fclose(fid_gt_ann);
        
        class_array = strcmp(gt, hmax_ids);
        
        %if params.verbose
            fprintf('Predicted item is %s, Groundtruth is %s\n', char(esvm_winner(1)), char(gt));
        %end
        if (strcmp(gt, esvm_winner{1}))            
            accuracy_count = accuracy_count + 1;
            test_analysis(class_array) = test_analysis(class_array) + 1;
        end
        
        num_total = num_total + 1;
        clear esvm_winner; clear esvm_top_id; clear esvm_top_score; clear esvm_max_score;
    end % end products in aisle
    %clear vcom_scores; 
end % end aisle


for k = 1 : numValidClasses
    test_analysis(k) = test_analysis(k)/str2double(num_test_classes{1}{k});
end

accuracy = accuracy_count/num_total * 100  ;
k = kavg/num_total;

if params.verbose
    fprintf('Accuracy = %f\n', accuracy);
    fprintf('K = %f\n', k);
end
end
