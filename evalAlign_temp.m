%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
%trainDir     = Don't need, already done in other files;
testDir      = 'Hansard/Testing/';
fn_LME       = LM;
% fn_LMF       = Don't need.... ;
lm_type      = 'smooth'; %this is hardcoded below to be 'smooth' already 
delta        = 0.1;
vocabSize    = length(fields(LM.uni)); 
% numSentences =  don't need, already created the AM models ;

% Train your language models. This is task 2 which makes use of task 1
LME = LM %lm_train( trainDir, 'e', fn_LME );
%LMF = lm_train( trainDir, 'f', fn_LMF );

% Train your alignment model of French, given English 
AMFE = AM%align_ibm1( trainDir, numSentences );

% ... TODO: more 

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  

DD   = dir( [ testDir, filesep, '*', 'f'] );
	
for iFile=1:length(DD)

	lines_f = textread([mydir, filesep, DD_F(iFile).name], '%s','delimiter','\n');

	for l=1:length(lines_f)
		fre = preprocess(lines_f{l}, 'f');
		eng = decode( fre, LME, AMFE, 'smooth', delta, vocabSize );
		
		%Calculate BLEU score somehow? 
		%Maybe bluemix stuff goes here?
		fprintf(eng);
	end
end

% Decode the test sentence 'fre'
eng = decode( fre, LME, AMFE, 'smooth', delta, vocabSize );

% TODO: perform some analysis
% add BlueMix code here 

[status, result] = unix('')