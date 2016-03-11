%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = 'Hansard/Training/';
testDir      = 'Hansard/Testing/';
fn_LME       = 'part5_english_model.mat';
fn_LMF       = 'part5_french_model.mat';
lm_type      = '';
delta        = 1;
vocabSize    = 1; 
numSentences = 1000;

% Train your language models. This is task 2 which makes use of task 1
LME = LM;% lm_train( trainDir, 'e', fn_LME );
%LMF = lm_train( trainDir, 'f', fn_LMF );

% Train your alignment model of French, given English 
AMFE = AM; %align_ibm1( trainDir, numSentences,10,'align_model_1000.mat');
% ... TODO: more 

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this 

lines_f = textread([testDir, filesep, 'Task5.f'], '%s','delimiter','\n');
lines_e = textread([testDir, filesep, 'Task5.e'], '%s','delimiter','\n');
lines_e_google = textread([testDir, filesep, 'Task5.google.e'], '%s','delimiter','\n');
eng = {};
for l=1:length(lines_f)
    [status, result] = unix( sprintf('curl --insecure -u "e61cf647-0223-4b73-bfb4-42e375a14af6":"s0SWfR64mL1s" -X POST -F "text=%s" -F "source=fr" -F "target=en" "https://gateway.watsonplatform.net/language-translation/api/v2/translate"', lines_f{l}) );
	fre = preprocess(lines_f{l}, 'f');
	eng{l} = strsplit(' ', decode2( fre, LME, AMFE, '', delta, vocabSize ), 'omit');
	
    refs = {
        strsplit(' ', lines_e{l}, 'omit'),
        strsplit(' ', lines_e_google{l}, 'omit'),
        strsplit(' ', result, 'omit')
    };
    
    scores = zeros(1,3);
    for i = 1:3
        score = bleu(eng{l}, refs, i, Inf);
        scores(i) = score;
    end
end
