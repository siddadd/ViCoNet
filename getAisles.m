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
%%% This function gets all valid aisle rois Aa and 					 %%%
%%% test valid aisle rois At										 %%%
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
function [Aa, At] = getAisles( params )

fprintf('Getting Aisle Information ... \n')

Aa = {};
At = {};

fid_mapping = fopen(params.CLASS_ID_MAPPING,'r');
if fid_mapping == -1, error('Cannot open mapping file'); end
    
classMappings = textscan(fid_mapping, '%s%s%s', 'delimiter', ',');
fclose(fid_mapping);
    
class_names = classMappings{2};

roi_count = 0;
test_roi_count = 0;

imageList = dir([params.database params.images '*' params.imagefiletype]);

for i = 1:numel(imageList)
    
    aisleName = imageList(i).name(1:end-4);
    
    % check if its a valid aisle since we annotated more aisles than what
    % we have testing data for
    valcheck = strcmp(params.classnames, aisleName);
    
    if any(valcheck)
        if params.validclasses(valcheck)
            
            try
                I = imread([params.database, params.images, imageList(i).name]);
            catch
                fprintf('Valid aisle, but corresponding image does not exist\n');
            end
            
            objectStruct = parseXML([params.database params.annotations aisleName params.annotationfiletype]);
            
            for j = 1:numel(objectStruct.Children)
                if (strcmp(objectStruct.Children(j).Name, 'object'))
                    
                    assert (strcmp('name', objectStruct.Children(j).Children(1).Name));
                    className = objectStruct.Children(j).Children(1).Children.Data;
                    className = strrep(className, '_', '''');
 
                    roi_count = roi_count + 1;
                    fprintf('Found RoI %d in  %s ... Extracting %s\n', roi_count, imageList(i).name, className);
                    
                    x_array = []; y_array = [];
 
                    assert (strcmp('polygon', objectStruct.Children(j).Children(9).Name));
                    
                    for k = 1:numel(objectStruct.Children(j).Children(9).Children)
                        if strcmp('pt', objectStruct.Children(j).Children(9).Children(k).Name)
                            x = str2double(objectStruct.Children(j).Children(9).Children(k).Children(1).Children.Data);
                            y = str2double(objectStruct.Children(j).Children(9).Children(k).Children(2).Children.Data);
                            x_array = [x_array; x];
                            y_array = [y_array; y];
                        end
                    end
                                        
                    xmin = min(x_array);
                    xmax = max(x_array);
                    ymin = min(y_array);
                    ymax = max(y_array);
                    
                    Aa{roi_count,1} = roi_count;
                    Aa{roi_count,2} = aisleName;
                    Aa{roi_count,3} = className;
                    Aa{roi_count,4} = [xmin, xmax, ymin, ymax];
                    
                    % Add to At only valid test data
                    if any(strcmp(class_names, className))
                       fprintf('Adding %s to test data\n', className);
                       test_roi_count = test_roi_count + 1; 
                       At(test_roi_count,:) = Aa(roi_count,:);
                       At{test_roi_count,1} = test_roi_count;
                    end
                    
                end
            end
        else
            continue;
        end
    end

    save( [params.resultpath 'AisleData', params.cachefiletype] , 'Aa', 'At');
    
end

