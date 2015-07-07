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
%%% Class Definition for Visual Co-occurrence Network		      	 %%%	
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

classdef ViCoNet
 
   properties 
        params;         
   end    
      
   methods
       
       function obj = ViCoNet(pars)
           if pars.verbose
            fprintf('Creating ViCoNet Class ...\n')
           end
           obj.params = pars; 
       end              
	   
	   function [accuracy, k, temporal_context_score, test_analysis] = Run(obj)
            temporal_context_score = 0;
            test_analysis = 0; 
            
			if any(strcmp(obj.params.ViCoNetMODE, {'active','passive'}))
				[accuracy, k] = simulateViCoNetStatic(obj.params);						
			elseif strcmp(obj.params.ViCoNetMODE, 'weight-ideal')
				[accuracy, k, temporal_context_score] = simulateViCoNetWeightIdeal(obj.params);
            elseif strcmp(obj.params.ViCoNetMODE, 'weight')
				[accuracy, k, temporal_context_score, test_analysis] = simulateViCoNetWeight(obj.params);           
			elseif strcmp(obj.params.ViCoNetMODE, 'base-ESVM')
				[accuracy, k] = simulateBaseESVM(obj.params);     
			else
				[accuracy, k] = simulateBaseline(obj.params); 
			end		
	   end
	   
	   function V = BuildViCoNet(obj)            
            if obj.params.verbose
              fprintf('Build ViCoNet\n')
			end
            V = buildViCoNet(obj.params);
       end
	   
	   
	end
	
end	

