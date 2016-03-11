function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation 
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed 
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French) 
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz 

  global CSC401_A2_DEFNS
  
  % first, convert the input sentence to lower-case and add sentence marks 
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down 
  inSentence = regexprep( inSentence, '\s+', ' '); 

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  % TODO: your code here
  %    e.g., outSentence = regexprep( outSentence, 'TODO', 'TODO');
  
  %Split on non characters
  outSentence = regexprep(outSentence,'([\W])',' $1 ');
  
  %Join back apostrophes for later
  outSentence = regexprep( outSentence, '\s''\s', ''''); 
  
  %Make sure only one space between each word
  outSentence = regexprep( outSentence, '\s+', ' '); 
  
  switch language
   case 'e'
    %Possesive dog's -> dog 's
    outSentence = regexprep( outSentence, '(\w+)''(\w+)','$1 ''$2' );
    
    %Possesive dogs' -> dogs '
    outSentence = regexprep( outSentence, '(\w+)''\s','$1 '' ' );
    
    %Contractions couldn't -> could n't
    outSentence = regexprep( outSentence, '(\w+)n\s''t\s','$1 n''t ' );
    
   case 'f'
    %  French Rules
    outSentence = regexprep( outSentence, 'l''(.)', 'l'' $1'); 
    outSentence = regexprep( outSentence, 'qu''(.)', 'qu'' $1'); 
    outSentence = regexprep( outSentence, '(.)+''on', '$1'' on'); 
    outSentence = regexprep( outSentence, '(.)+''il', '$1'' il');   
    outSentence = regexprep( outSentence, '(\w)''(\w+)', '$1'' $2');
    
    %Ignore cases
    outSentence = regexprep( outSentence, '(d)''(\s)(abord)', 'd''abord');
    outSentence = regexprep( outSentence, '(d)''(\s)(accord)', 'd''accord');
    outSentence = regexprep( outSentence, '(d)''(\s)(ailleurs)', 'd''ailleurs');
    outSentence = regexprep( outSentence, '(d)''(\s)(habitude)', 'd''habitude');

  end

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );

