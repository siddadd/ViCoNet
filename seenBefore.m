function [yes,row,col] = seenBefore(source_node, target_node, Key)
% This function checks to see if two rois are seen together before
% if seen then returns the row number
% 05/17/2016
% Siddharth Advani
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

yes = 0; % assume never seen
row = 1; % initialize
col = 1; % initialize

if isempty(Key)
    return;
else
    for i = 1:size(Key,1)
        scheck = strcmp(Key(i,i), source_node);
        if scheck
            tcheck = strcmp(Key(i,:), target_node);
            if any(tcheck)
                row = i;
                col = find(tcheck == 1);
                yes = 1;
                
            end
            return;
        end
    end
end
end