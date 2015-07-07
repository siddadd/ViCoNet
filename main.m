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
%%%  Main for Visual Co-occurrence Network		      	 			 %%%	
%%%  06/18/2015											      		 %%% 
%%%  Siddharth Advani										      	 %%%
%%%                                                                  %%%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%																	 %%%
%%%  SELECTED REFERENCES:         									 %%%				
%%%																	 %%%			
%%%  1. M. Cotter, S. Advani, J. Sampson, K. Irick, V. Narayanan,    %%%
%%%  A Hardware Accelerated Multilevel Visual Classifier for         %%%
%%%  Embedded Visual-Assist Systems, Computer-Aided Design (ICCAD),  %%% 
%%%  2014 IEEE/ACM International Conference on Year: 2014			 %%%
%%%  Pages: 96 - 100, DOI: 10.1109/ICCAD.2014.7001338				 %%%
%%%                                                                  %%%
%%%  2. B. Smith, S. Advani, M. Cotter, K. Irick, J. Sampson,        %%%
%%%  V. Narayanan, Using a Visual Co-occurrence Network (ViCoNet)    %%%
%%%  for Large-Scale Object Classification, Sensor to Cloud 		 %%% 
%%%  Architecture Workshop (SCAW), 2015  							 %%%
%%%																	 %%%					
%%%  3. Visual Co-occurrence Network: Using Context for Large-Scale  %%%
%%%  Object Recognition in Retail (under review)				 	 %%%		
%%%																	 %%%				
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 																 %%%		
%%%  Copyright (c) 2015 Siddharth Advani                             %%%
%%%  Distributed under the MIT License                               %%%
%%%  See MITlicense.txt file in the distribution folder.             %%%
%%%                                                                  %%%
%%%  Contact: Siddharth Advani at <ska130@cse.psu.edu>               %%%
%%%																	 %%% 		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%																	 %%%				
%%%  Assumptions : Trained on Wegmans Dataset                        %%%
%%%                Tested on Sophie Dataset                          %%%
%%%                                                                  %%%
%%%  Features : HMAX, ESVM, ViCoNet                                  %%%
%%%                                                                  %%%
%%%  Dependencies : Classifier scores                                %%%
%%%                                                                  %%%
%%%  Comments : active and passive modes are from SCAW               %%%
%%%             weight and weight-ideal are from under review        %%%
%%%																	 %%%			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all; close all; 

% Add libraries

params = loadDefaultParameters; 

VCNT = ViCoNet(params);

accuracy = zeros(VCNT.params.RUNS,1);
k = zeros(VCNT.params.RUNS,1);
test_analysis = zeros(VCNT.params.RUNS,VCNT.params.numvalidproducts);

for i = 1 : VCNT.params.RUNS    
    
    fprintf('|-------------------|\n');
    fprintf('Begin run %d\n',i);

    %% Baseline (Accuracy should remain same in each run since each RoI is evaluated as an independent and identically distributed RoI)
%     VCNT.params.ViCoNetMODE  = 'base-ESVM';
    
	%% Active
% 	VCNT.params.ViCoNetMODE  = 'active';
        
	%% Passive
% 	VCNT.params.ViCoNetMODE  = 'passive';

    %% Weight-Ideal
%    VCNT.params.ViCoNetMODE = 'weight-ideal';
    
    %% Weight
    VCNT.params.ViCoNetMODE = 'weight';
    %% Run
    [accuracy(i), k(i), temporal_context_score(i,:), test_analysis(i,:)] = VCNT.Run;
            
end

avg_accuracy = sum(accuracy)/VCNT.params.RUNS
avg_k = sum(k)/VCNT.params.RUNS
plot(mean(temporal_context_score));

if strcmp(VCNT.params.ViCoNetMODE, 'weight')
    save('ViCoNetWeight_Results.mat', 'accuracy', 'k', 'temporal_context_score', 'test_analysis');
elseif strcmp(VCNT.params.ViCoNetMODE, 'weight-ideal')
    save('ViCoNetWeightIdeal_Results.mat', 'accuracy', 'k', 'temporal_context_score', 'test_analysis');
elseif strcmp(VCNT.params.ViCoNetMODE, 'active')
    save('ViCoNetActive_Results.mat', 'accuracy', 'k', 'temporal_context_score', 'test_analysis');
elseif strcmp(VCNT.params.ViCoNetMODE, 'passive')
    save('ViCoNetPassive_Results.mat', 'accuracy', 'k', 'temporal_context_score', 'test_analysis');    
elseif strcmp(VCNT.params.ViCoNetMODE, 'base-ESVM')
    save('ViCoNetBaseESVM_Results.mat', 'accuracy', 'k', 'temporal_context_score', 'test_analysis');    
else
    save('Baseline_Results.mat', 'accuracy', 'k', 'temporal_context_score', 'test_analysis');
end
