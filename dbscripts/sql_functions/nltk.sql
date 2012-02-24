-- Be sure to setup a link to nltk_data so postgresql knows where it is
-- a command that works sudo ln -s /home/cgrant/nltk_data/ /usr/share/nltk_data

CREATE OR REPLACE FUNCTION cgrant_nltk() RETURNS TEXT AS
$$
import nltk
return nltk.__version__
$$ LANGUAGE plpythonu;
-- select cgrant_nltk();
-- "2.0b9"

CREATE TYPE pair AS (
	term text,
	pos text
);

CREATE OR REPLACE FUNCTION cgrant_postag(doc TEXT) 
RETURNS SETOF pair AS
$$
import nltk
from django.utils.encoding import smart_unicode
return nltk.pos_tag(nltk.word_tokenize(smart_unicode(doc, errors='ignore')))
$$ LANGUAGE plpythonu;

-- select cgrant_postag('And now for something completely different');


--DROP TYPE netriple CASCADE;
CREATE TYPE netriple AS (
  termnum integer, --sequence number
  term text,     
  pos text,      
  tag text -- this is the name entity tag NE, or PERSON, GPE, ORGANIZATION...
);               
                 
-- Named entity chunker
CREATE OR REPLACE FUNCTION cgrant_ne_chunk(doc TEXT, hardtags boolean)
RETURNS SETOF netriple AS
$$
import nltk
from types import TupleType
from django.utils.encoding import smart_unicode
seq = 0
tok = nltk.word_tokenize(smart_unicode(doc, errors='ignore'))
pos = nltk.pos_tag(tok)
chunk = nltk.ne_chunk(pos, hardtags)
array = []
for res in chunk:
	if isinstance(res, TupleType):
		array.append( (seq, res[0], res[1], None))
		seq += 1
	else:
		for x in res.pos():
			array.append((seq, x[0][0], x[0][1], x[1]))
		seq += 1
return array
$$ LANGUAGE plpythonu Volatile;

select cgrant_ne_chunk('Kirn began his career in psychology, graduating from UF with a masters degree in clinical psychology in 1971 and a doctorate in the same subject in 1974. While at UF, he met his wife, Katrine, who also earned her doctorate in clinical psychology at UF. He worked in the mental health field for six years, first as an intern and later at community mental health centers and in a private practice in Kentucky that he owned with his wife. He also was a full-time faculty member at Bellarmine University in Louisville for six years.', true)
