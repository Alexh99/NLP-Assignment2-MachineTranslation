function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end



% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
	eng = {};
	fre = {};

	DD_E   = dir( [ mydir, filesep, '*', 'e'] );
	DD_F   = dir( [ mydir, filesep, '*', 'f'] );
	
	for iFile=1:length(numSentences)

		lines_e = textread([testDir, filesep, DD_E(iFile).name], '%s','delimiter','\n');
		lines_f = textread([testDir, filesep, DD_F(iFile).name], '%s','delimiter','\n');

		for l=1:length(lines_e)
			
			processedLine_e = preprocess(lines_e{l}, 'e');
			processedLine_f = preprocess(lines_f{l}, 'f');
			
			eng{i} = strsplit(' ', processedLine_e);
			fre{i} = strsplit(' ', processedLine_f);

end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)

	
	for i = 1:length(eng)
		for j=1:length(eng{i})
			for k = 1:length(fre{i})
				AM.(eng{i,j}).(fre{i,k}) =1;
				
	
	eng_words = fieldnames(AM);
	for i = 1:numel(eng_words):
		
		tot = numel(fieldnames(eng_words{i});
		fre_words =fieldnames(eng_words{i});
		for j = 1:numel(fre_words)
			
			AM.(eng_words{i}).(fre_words{j}) = 1/tot;
			
	
	
    % TODO: your code goes here

end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  
  % TODO: your code goes here
end


