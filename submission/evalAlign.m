%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

csc401_a2_defns;

% some of your definitions
trainDir        = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir         = '/u/cs401/A2_SMT/data/Hansard/Testing/';
fn_LME          = 'english_model.mat';
fn_AMFE         = 'ibm1_1000.mat';
fn_scores       = 'scores_1000.mat';
fn_task5f       = 'Task5.f';
fn_task5e       = 'Task5.e';
fn_task5google  = 'Task5.google.e';
num_sents       = 1000;
max_iter        = 10;
lm_type         = '';
delta           = 1; % This isn't used
vocabSize       = 1; % This isn't used

% Train your language models. This is task 2 which makes use of task 1
if exist(fn_LME, 'file') == 2
    load(fn_LME, '-mat');
    LME = LM;
else
    LME = lm_train( trainDir, 'e', fn_LME );
end

% Train your alignment model of French, given English
if exist(fn_AMFE, 'file') == 2
    load(fn_AMFE, '-mat');
    AMFE = AM;
else
    AMFE = align_ibm1( trainDir, num_sents, max_iter, fn_AMFE );
end

% Read in lines
lines_f = textread([testDir, filesep, fn_task5f], '%s','delimiter','\n');
lines_e = textread([testDir, filesep, fn_task5e], '%s','delimiter','\n');
lines_e_google = textread([testDir, filesep, fn_task5google], '%s','delimiter','\n');

% Keep track of the translated senteces and their BLEU scores.
eng = {};
scores = {};
for l=1:length(lines_f)
    % Make a call to Bluemix to translate the French sentence
    [status, result] = unix( sprintf(strjoin({
        'curl --insecure', ...
        '-u "e61cf647-0223-4b73-bfb4-42e375a14af6":"s0SWfR64mL1s"', ...
        '-X POST', ...
        '-F "text=%s"', ...
        '-F "source=fr"', ...
        '-F "target=en"', ...
        '"https://gateway.watsonplatform.net/language-translation/api/v2/translate"', ...
    }), lines_f{l}) );
    % Process the French sentence
	fre = preprocess(lines_f{l}, 'f');
    % Decode into most likely Enlish sentence
	eng{l} = decode( fre, LME, AMFE, lm_type, delta, vocabSize );
	
    % Process al reference sentences and split them
    refs = {
        strsplit(' ', preprocess(lines_e{l}, 'e'), 'omit'), ...
        strsplit(' ', preprocess(lines_e_google{l}, 'e'), 'omit'), ...
        strsplit(' ', preprocess(result, 'e'), 'omit')
    };
    
    % Calculate the BLEU score for n=[1..3]
    scores{l} = zeros(1,3);
    for i = 1:3
        score = bleu(eng{l}, refs, i, Inf);
        scores{l}(i) = score;
    end
end

save(fn_scores, 'scores');
