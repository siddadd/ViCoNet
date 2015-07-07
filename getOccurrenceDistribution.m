function ProbDistribution = getOccurrenceDistribution(VCOM, VSOM, Key, candidate)
% This function generates a distribution of occurrence weights
% 06/20/2015
% Siddharth Advani
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sidx = strcmp(Key, candidate);

Pcandidate = VSOM(sidx);   

ProbDistribution  = VCOM(sidx,:)./Pcandidate;   % P(A|B) = P(AB)/P(B)