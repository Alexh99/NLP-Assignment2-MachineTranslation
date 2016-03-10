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
  fprintf('Done Reading\n')
  % Initialize AM uniformly 
  AM = initialize(eng, fre);
  fprintf('Done Initialization\n')
  % Iterate between E and M steps
  for iter=1:maxIter,
    fprintf('Iteration: %d\n',iter);
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
	
    i = 0;
	for iFile=1:length(DD_E)

		lines_e = textread([mydir, filesep, DD_E(iFile).name], '%s','delimiter','\n');
		lines_f = textread([mydir, filesep, DD_F(iFile).name], '%s','delimiter','\n');

		for l=1:length(lines_e)
			
            if i < numSentences
                processedLine_e = preprocess(lines_e{l}, 'e');
                processedLine_f = preprocess(lines_f{l}, 'f');
			
                eng{l} = strsplit(' ', processedLine_e);
                fre{l} = strsplit(' ', processedLine_f);
                
                i = i + 1;
            else
                return;
            end
        end    
    end
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
				AM.(eng{i}{j}).(fre{i}{k}) =1;
            end
        end
    end
				
	
	eng_words = fieldnames(AM);
	for i = 1:numel(eng_words)
		
		fre_words = fieldnames(AM.(eng_words{i}));
		tot = numel(fre_words);
		
        for j = 1:numel(fre_words)

			AM.(eng_words{i}).(fre_words{j}) = 1/tot;
			
        end
    end
    
    AM.SENTSTART = rmfield(AM.SENTSTART, fieldnames(AM.SENTSTART));
    AM.SENTSTART.SENTSTART = 1;

    AM.SENTEND = rmfield(AM.SENTEND, fieldnames(AM.SENTEND));
    AM.SENTEND.SENTEND = 1;
    
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%

% Note: t == AM

    % Initialize tcount and total
    tcount = {};
    total = {};
    
    eng_words = fieldnames(t);
 	for i = 1:numel(eng_words)
        % set total(e) to 0 for all e
        total.(eng_words{i}) = 0;
 		fre_words = fieldnames(t.(eng_words{i}));
        for j = 1:numel(fre_words)
            % set tcount(f, e) to 0 for all f, e
            tcount.(eng_words{i}).(fre_words{j}) = 0;
        end
    end

%     Do we need all word combinations, not just the
%     combinations we did in the previous step?
%
%     Get all unique french and english words
%     eng_words = unique([eng{:}]);
%     fre_words = unique([fre{:}]);
%     for i = 1:numel(eng_words)
%        e = eng_words{i};
%        total.(e) = 0;
%        for j = 1:numel(fre_words)
%           f = fre_words{j};
%           tcount.(e).(f) = 0; 
%        end
%     end
    
    %  Slide 13
    for i = 1:numel(eng)
        E = eng{i};
        F = fre{i};
        unique_F = unique(F);
        unique_E = unique(E);
        for j = 1:numel(unique_F)
            f = unique_F{j};
            F_count_f = sum(strcmp(F,{f}));
            
            denom_c = 0;
            for k = 1:numel(unique_E)
                e = unique_E{k};
                
                % Check if P(f|e) [t.(e).(f)] is a thing, otherwise treat it as 0
                if any(strcmp(f,fieldnames(t.(e))))
                    denom_c = denom_c + (t.(e).(f) * F_count_f);
                % else
                    % denom_c = denom_c + (0 * F_countf);
                end
            end
            for k = 1:numel(unique_E)
                e = unique_E{k};
                E_count_e = sum(strcmp(E,{e}));
                
                % Check if P(f|e) [t.(e).(f)] is a thing, otherwise treat it as 0
                if any(strcmp(f,fieldnames(t.(e))))
                    tcount.(e).(f) = tcount.(e).(f) + (t.(e).(f)*F_count_f*E_count_e/denom_c);
                    total.(e) = total.(e) + (t.(e).(f)*F_count_f*E_count_e/denom_c);
                end
            end
        end
    end
    
    % Slide 12
    domain_total = fieldnames(total);
    for i = 1:numel(domain_total)
       e = domain_total{i};
       
       domain_tcount = fieldnames(tcount.(e));
       for j = 1:numel(domain_tcount)
           f = domain_tcount{j};
           
           t.(e).(f) = tcount.(e).(f)/total.(e);
       end
    end

end


