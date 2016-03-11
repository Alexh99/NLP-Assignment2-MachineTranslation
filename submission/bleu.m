function score = bleu( candidate, refs, n, cap )
%
%  bleu
% 
%  This function computes the BLEU score of a candidate sentence given reference sentences. 
%
%  INPUTS:
%
%       candidate : (cell-array of string) the candidate sentence
%       refs      : (cell-array of cell-array of strings) the ref strings
%       n         : (int) the number of ngrams to use
%       cap       : (int) the maximum number of times to count candidate
%                   ngrams
%
%  Authors: Jake S., Alex H.
%
    %Strip SENTSTART and SENTEND
    candidate(strcmp(candidate, 'SENTSTART')) = [];
    candidate(strcmp(candidate, 'SENTEND')) = [];
    
    for i = 1:numel(refs)
        refs{i}(strcmp(refs{1}, 'SENTSTART')) = [];
        refs{i}(strcmp(refs{1}, 'SENTEND')) = [];
    end

    % Calculate brevity score
    num_candidate_words = numel(candidate);
    r = Inf;
    for i = 1:numel(refs)
        if abs(num_candidate_words - numel(refs{i})) < r
            r = numel(refs{i});
        end
    end
    
    brevity = r/num_candidate_words;
    
    % Calculate brevity penalty
    if brevity < 1
        bp = 1;
    else
        bp = exp(1-brevity);
    end
    
    % Loop through to create every i to ngram in the candidate
    candidate_ngrams_list = {};
    for i = 1:n
        candidate_ngrams_list{i} = {};
        % get all candidate "igram" word tuples for i=1 to n
        for j = 1:(numel(candidate)-i+1)
            igram_words = candidate(j:j+i-1);
            candidate_ngrams_list{i} = [candidate_ngrams_list{i}, {strjoin(igram_words)}];
        end
    end
    
    % Loop through to create every i to ngram for each reference
    ref_ngrams_list = {};
    for i = 1:n
        ref_ngrams_list{i} = {};
        for j = 1:(numel(refs))
            ref = refs{j};
            % get all candidate "igram" word tuples for i=1 to n
            for k = 1:(numel(ref)-i+1)
                igram_str = strjoin(ref(k:k+i-1));
                
                % don't count ref igrams multiple times
                if not(any(strcmp(ref_ngrams_list{i}, igram_str)))
                    ref_ngrams_list{i} = [ref_ngrams_list{i}, {igram_str}];
                end
            end
        end
    end
    
    % See how many i to ngram are actually in the references
    ngram_precisions = zeros(1, n);
    for i = 1:n
        ref_igrams = ref_ngrams_list{i};
        candidate_igrams = candidate_ngrams_list{i};
        N = numel(candidate_igrams);
        C = 0;
        % Check each ngram in the candidate set with ngrams in the ref set
        for j = 1:numel(ref_igrams)
            ref_igram = ref_igrams{j};
            C = C + min(sum(strcmp(candidate_igrams, ref_igram)), cap);
        end
        ngram_precisions(i) = C/N;
    end
    
    score = bp*(prod(ngram_precisions)^(1/n));
    
end
