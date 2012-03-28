-- Function: mad_entityfind(text, boolean)

-- DROP FUNCTION mad_entityfind(text, boolean);


CREATE OR REPLACE FUNCTION mad_entityfind(sentence text, fuzzy boolean)
  RETURNS SETOF basic_entity AS
$BODY$
from nltk import word_tokenize, pos_tag, ne_chunk

# Helper function for traversing through the parse tree
def traverse(tree, num = 0, groups = []):
    node = [n for n in tree]
    for n in node:
        try:
            #Check to see if n is an intermediary node
            n.node
        
        except AttributeError:
            # We found a leaf node in our tree
            if n[1] in ["NNP", "NNPS"] and fuzzy: # Then we can put it in as a potential entity:
                
                if len(groups) > 0: # Check to see if the last item in the node is the previous word in the sentence
                    last = groups.pop()
                    if num - 1 == last[1]: 
                        # If the word was right before it, we can create a compound fuzzy entity
                        groups.append([" ".join([last[0], n[0]]), last[1]])
                        continue
                    else:
                        groups.append(last)
                    groups.append([n[0], num])
            num += 1         
        else:
            # We have a intermediate (we found ourselves a detected entity)
            # Lets harvest out the proper noun phrase...
            leaves = [n[0] for n in n.leaves()]
            groups.append([" ".join(leaves), num]) 
            num += len(leaves)
    return [groups, num]

tree = ne_chunk(pos_tag(word_tokenize(sentence)), False);
x = [entity for entity in traverse(tree)[0]]
return (x)
$BODY$
  LANGUAGE plpythonu VOLATILE
  COST 500
  ROWS 1000;
ALTER FUNCTION mad_entityfind(text,boolean)
  OWNER TO "john";
