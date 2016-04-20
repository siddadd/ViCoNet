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
%%% This function builds ViCoNet with weights based on spatial 		 %%%	
%%% constraints        												 %%%
%%% 06/17/2015											      		 %%% 
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
function V = buildViCoNet(params)

fprintf('Building ViCoNet ... \n')

if ~exist(params.resultpath, 'dir')
    mkdir(params.resultpath);
    A = getAisles(params);
else    
    fprintf('Loading Aisle Information ... \n')
    load([params.resultpath, 'AisleData', params.cachefiletype]);
end

products = unique(A(:,3));
products_entered_into_V = cell(numel(products),1);

% ViCoNet is a cell with 4 entries:
% 1. the source node 
% 2. the target node 
% 3. is 1 if 1 and 2 are from the same aisle else is 0 and
% 4. the corresponding weight on the edge
% Initializing since there will be atleast as many nodes as there are
% products
V = cell(numel(products), 4);
vcount = 0; %vertex count
ecount = 0; %edge count

for i = 1:size(A,1)
    source_aisle = A{i,2};
    source_node = A{i,3};    
    source_position = A{i,4};
    if ~any(strcmp(products_entered_into_V, source_node))        
        vcount = vcount + 1;         
        products_entered_into_V{vcount} = source_node;
        ecount = ecount + 1;
        V{ecount,1} = source_node; 
        V{ecount,2} = source_node; 
        V{ecount,3} = 1; % same aisle 
        V{ecount,4} = sum(strcmp(A(:,3),source_node)); % count is as many self-occurrences
    else
        % added at one shot above
        continue; 
    end
    
    for j = i+1:size(A,1)             
        target_aisle = A{j,2};
        target_node = A{j,3};
        target_position = A{j,4};
                        
        if strcmp(source_node, target_node)
            continue % same product => no self loop
        else    
            [seen, loc] = seenBefore(source_node, target_node, V);
            
            if ~seen
                ecount = ecount + 1;
                edge = ecount;  
                V{edge,1} = source_node; 
                V{edge,2} = target_node; 
            else
                edge = loc;
            end
                
            % will overwrite if first time not seen in the same aisle but seen the second time 
            % in the same aisle but
            % that should not happen with current dataset
            if strcmp(source_aisle, target_aisle) % same aisle
                
                V{edge,3} = 1;  % add an edge with default weight 1 
                
                if areSeenTogether(source_position, target_position, params.SPATIAL)                    
                    if ~seen                                                                     
                        V{edge,4} = 1;                    
                    else
                        V{edge,4} = V{edge,4} + 1;                    
                    end
                end
            else
                V{edge,3} = NaN;                                  
            end
        end
    end
end

end