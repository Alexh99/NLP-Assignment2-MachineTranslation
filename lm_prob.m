function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);

  logProb = 0;
  
  %MLE no smoothing
  if isempty(type)
      for i = 2:length(words)
        prob = 0;
        if isfield(LM.uni,words{i-1})
            denom = LM.uni.(words{i-1});
            if isfield(LM.bi.(words{i-1}),words{i})
                numerator = LM.bi.(words{i-1}).(words{i});
                prob = numerator/denom;
                logProb = logProb + log2(prob);
            end
        else
            logProb = logProb -Inf;
        end
      end
      
  else
      for i = 2:length(words)
        prob = 0;
        denom = delta*vocabSize;
        numerator = delta;
        if isfield(LM.uni,words{i-1})
            denom = denom + LM.uni.(words{i-1});
            if isfield(LM.bi.(words{i-1}),words{i})
                numerator = numerator + LM.bi.(words{i-1}).(words{i});
            end
        end
        prob = numerator/denom;
        logProb = logProb + log2(prob);
      end
  end
  
  
      
  % TODO: the student implements the following
  % TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.
return