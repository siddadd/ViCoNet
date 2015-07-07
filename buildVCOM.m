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
%%% This function builds the Visual Co-occurrence and 				 %%%
%%% Self-occurrence Matrices			 						     %%%
%%% 06/20/2015											      		 %%% 
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
function [VCOM, VSOM, Key, Map] = buildVCOM(params)

fprintf('Building Visual Co-occurrence Matrix ... \n')

if ~exist(params.resultpath, 'dir')
    mkdir(params.resultpath);
    [~, A] = getAisles(params); % get only test data
else    
    fprintf('Loading Aisle Information ... \n')
    load([params.resultpath, 'AisleData', params.cachefiletype]);
    A = At; 
end

aisles = unique(A(:,2));

% Check to make sure that we are evaluating on valid aisles only 
assert(numel(aisles) == sum(params.validclasses));

products = unique(A(:,3));

% Check to make sure that we are evaluating on valid products only (double
% check)
assert(numel(products) == params.numvalidproducts);

% Map is a cell with 2 entries:
% 1. the aisle name
% 2. the products in that aisle
Map = cell(numel(aisles),2);

for a = 1:numel(aisles)        
    Map{a,1} = aisles{a};    
    match = strcmp(aisles(a), A(:,2));
    Map{a,2} = unique(A(match,3));        
end

products_entered_into_V = cell(numel(products),1);

% VSOM is a Nx1 symmetric matrix where
% 1. each element correponds to the probability of that node occurring
% in the network
% VCOM is a NxN symmetric matrix where
% 1. VCOM(i,i) corresponds to the joint probability of i and i co-occurring
% 2. VCOM(i,j) corresponds to the joint probability of i and j 
% co-occurring. If two products from two different aisles they are by
% default not seen together
% 3. Key contains link names between products
% 4. Since VCOM is symmetric, only the upper triangular portion needs to be
% saved in memory. 
% Initializing
VSOM = zeros(numel(products),1); %nx1 matrix
VCOM = zeros(numel(products)); %nxn matrix
SelfCount = zeros(numel(products),1); 
Key = cell(numel(products),1);

vcount = 0; %vertex count

for i = 1:size(A,1)                
    %% Get source    
    source_node = A{i,3};            
    %% Diagonal elements
    if ~any(strcmp(products_entered_into_V, source_node))        
        vcount = vcount + 1;         
        products_entered_into_V{vcount} = source_node;        
        Key{vcount} = source_node;
        SelfCount(vcount) = sum(strcmp(A(:,3),source_node)); 
        VSOM(vcount) = sum(strcmp(A(:,3),source_node)) / size(A,1);
        VCOM(vcount,vcount) = (SelfCount(vcount)*(SelfCount(vcount)-1)) / ((size(A,1))*(size(A,1)-1));  % probability of self - occurrence i.e. P(A) = ((num(A)*(num(A)-1))/(num(All)*num(All)-1)
    else
        % added at one shot above
        continue; 
    end
end

%% Non Diagonal elements (This needs some rework since we always compare spatial positions of first instants of two different products)
for i = 1:size(VCOM,1)
    for j = 1:size(VCOM,2)
        if (i == j)
            continue;
        else
            source_node = Key{i};
            target_node = Key{j};
            
            source_aisle_idx = strcmp(source_node, A(:,3));
            target_aisle_idx = strcmp(target_node, A(:,3));
            
            source_aisle = A{source_aisle_idx,2};
            source_position = A{source_aisle_idx,4};
    
            target_aisle = A{target_aisle_idx,2};            
            target_position = A{target_aisle_idx,4};
            
            if strcmp(source_aisle, target_aisle) % same aisle
             
                 if areSeenTogether(source_position, target_position, params.SPATIAL)               
                    VCOM(i,j) = (SelfCount(i) * SelfCount(j)) / (size(A,1)*(size(A,1)-1)); % probability of joint - occurrence i.e. P(A,B) = P(A) * P (B|A) = num(A)/num(All) * num(B)/num(All)-1                  
                 end
                 
            end
            
        end
    end
end
end