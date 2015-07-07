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
%%% This function loads default parameters for ViCoNet               %%%	
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
function params = LoadDefaultParameters

fprintf('Loading default parameters ... \n')

%% Debug Params
params.verbose     = 0            ; 
%% Runtime Params
params.VAlpha      = 1; % Confidence of applying ViCoNet weights on RLS weights
params.ViCoNetMODE  = 'weight';
params.K            = 20; %7; %10; %20;
params.BUILD_CONTEXT_TIME = 8;
params.ESVM_CONFIDENCE_THRESH = 0.075;
params.RUNS      = 10; 
params.SPATIAL   = 1000; % ROIs within these many pixels are considered a clique
%params.PIPELINEDATA   = './data/SCAW_102_Dataset.xml'; % not used, just
%reference
params.INPUT_ANNOTATION_FILES = './testdata/';
params.ANNOTATION_FILE_TYPE = '.txt';
params.CLASS_ID_MAPPING = './mapping_with_maxESVM_score.txt';
params.AISLE_ID_MAPPING = './aisle.txt';
params.NUM_TEST_CLASS_DATA = './num_test_classes.txt';
%% File Params
params.imagefiletype          = '.jpg'   ;
params.annotationfiletype     = '.xml'   ;
params.cachefiletype          = '.mat'   ;
%% Cache Params
params.resultpath = './cache/resultdata/'   ;
%% Database Params
params.database       = './traindata/';
params.images         = 'Images/';
params.annotations    = 'Annotations/';
params.classnames     = {'Cereal', 'Chips', 'Cleaning', 'Coffee', 'Condiments', 'Cookies', 'Dental', 'Juice', 'Pasta', 'Refrigerated', 'Sauce', 'Soda', 'Soup', 'Storage'};
params.validclasses   = [1 0 1 1 1 1 1 1 1 0 1 1 0 1];
params.numvalidproducts = 62; 
%% Test Data Params
end
