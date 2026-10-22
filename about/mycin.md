A consultation with MYCIN, Stanford's expert system of the 1970s for finding the bacteria
behind serious blood infections.  It asks about a patient, a culture and the organism grown
from it, and names the likely organisms, each with a certainty factor.

## What it does

MYCIN works backwards from what it wants to know, the organism's identity, through rules of the
form *if these findings, then this conclusion, with this much certainty*.  Certainty factors run
from -1, certainly false, to 1, certainly true, and the certainties of rules reaching one
conclusion are combined.  What a rule needs and MYCIN does not know, it asks you, and it can say
why.

This is Peter Norvig's rebuilding in Common Lisp from *Paradigms of Artificial Intelligence
Programming* (1992): a small shell and six of MYCIN's rules, enough to tell five kinds of
bacteria apart.  It shows how such a system reasons; it is not a medical tool.

## Using it

Type each answer and press `RET`.  Most questions also take, in place of an answer:

- **Why?** (`C-c C-w`, or type `why`): the rule MYCIN is trying, and what it knows.
- **Rule** (`C-c C-r`, `rule`): that rule as written.
- **Answers** (`C-c C-c`, `?`): the answers the question takes.
- **Unknown** (`C-c C-u`, `unknown`): go on without it.

An answer may also weigh several values, as `(neg .8 pos .2)`.  **New Consultation**
(`C-c C-n`) starts again.

```
What is the AEROBICITY of ORGANISM-1? why
[Why is the value of AEROBICITY being asked for?]
It is known that:
    1) THE GRAM OF THE ORGANISM IS NEG
    1) THE MORPHOLOGY OF THE ORGANISM IS ROD
Therefore,
Rule 107:
  If
    1) THE AEROBICITY OF THE ORGANISM IS AEROBIC
  Then there is suggestive evidence (0.8) that
    1) THE IDENTITY OF THE ORGANISM IS ENTEROBACTERIACEAE
```

## Where it comes from

Edward Shortliffe built MYCIN for his doctoral work, with Bruce Buchanan, Stanley Cohen and
others; its name is the ending of many antibiotics' names.  The full system held hundreds of
rules and recommended antibiotics and doses.  It was never used on patients, but its
rules, certainty factors and explanations set the pattern for the expert systems that followed,
and emptied of its medical rules it became EMYCIN, a shell for other fields.

## What it needs

The Common Lisp extension, which runs MYCIN in a batch Emacs beside yours; the App Store
installs it first.
