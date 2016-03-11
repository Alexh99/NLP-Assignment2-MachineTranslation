function [ score ] = bleu( candidate, refs, n, cap )
%function that calculates the BLEU score, given a candidate and reference
%sentences.

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
    
    % Create list of unique n-grams across all ref sentences
    ngrams = {};
    % Loop from 1 up to n grams
    for i = 1:n
        gram_struct = struct();
        ngrams{i} = gram_struct;
        % Look at each reference sentence
        for j = 1:numel(refs)
            ref = refs{j};
            % Get every set of i-gram words
            for k = 1:(numel(ref)-i+1)
                igram_words = ref(k:k+i-1);
                % Record that we've seen this "n-gram"
                % ex. gram_struct.('this').('is').('trigram') = 1
                inner_struct = gram_struct;
                for k = 1:(numel(igram_words)-1)
                    word = igram_words{k};
                    if not(isfield(inner_struct, word))
                        inner_struct.(word) = struct();
                    end
                    inner_struct = inner_struct.(word);
                end
                inner_struct.(igram_words{end}) = 0;
            end
        end
    end
    
    % Record count of i to ngram matches in the reference sentences
    % Note, this is just done in place by traversing the list of 
    % ngram structures we previously created.
    for i = 1:n
        % get all candidate "igram" word tuples for i=1 to n
        for j = 1:(numel(candidate)-i+1)
            % Check if the igram is in any of the references
            igram_words = ref(j:j+i-1);
            gram_struct = ngrams{i};
            inner_struct = gram_struct;
            for k = 1:(numel(igram_words)-1)
                word = igram_words{k};
                if not(isfield(inner_struct, word))
                    break;
                end
                inner_struct = inner_struct.(word);
            end
            
            if isfield(inner_struct, igram_words{end})
                inner_struct.(igram_words{end}) = max(inner_struct.(igram_words{end}) + 1, cap);
            end
        end
    end
    
    % Go back through the structure one last time to calculate precisions
    ngram_precisions = zeros(1, n);
    for i = 1:n
        % get all candidate "igram" word tuples for i=1 to n
        N = numel(candidate)-i+1;
        C = sum_leaves(ngrams{i});
        ngram_precisions(i) = C/N;
    end

    score = bp/(prod(ngram_precisions)^n);
    
end

function [ total ] = sum_leaves( in )
    % Assume either struct or number
    if isstruct(in)
        names = fieldnames(in);
        values = zeros(1, numel(names));
        for i = 1:numel(names)
            name = names{i};
            values(i) = sum_leaves(in.(name));
        end
        total = sum(values);
    else
        total = in;
    end
end
