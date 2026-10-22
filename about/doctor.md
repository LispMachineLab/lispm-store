A psychotherapist in the manner of ELIZA, who listens to what troubles you and answers, as
often as not, with a question about what you have just said.

## What it does

The doctor reads the last sentence you typed, looks for a word it knows, and turns your words
back on you: "I am" becomes "you are", "my" becomes "your", and a mention of your mother brings
questions about your family.  It keeps a note of things you have said and returns to them later,
corrects a few common misspellings, and has replies ready for talk of school, love, death and
machines.

Behind the replies there is no understanding, only patterns over words and stock phrases to fill
them, which is how ELIZA worked too.  That this is often enough to keep a conversation going is
the old lesson the program still teaches.

## Using it

- Type a sentence and press `RET`; the doctor answers on the lines below.  `C-j` does the same.
- Say one thing at a time: the doctor reads only the last sentence you typed.
- **New Session** starts again, with a doctor who remembers nothing of the last one.
- Say goodbye and it takes its leave, now and then with a word about its bill.

## Where it comes from

Joseph Weizenbaum wrote ELIZA at MIT in the mid-1960s and described it in *Communications of
the ACM* in 1966.  ELIZA followed scripts of key words and reply patterns.  Its best-known
script, DOCTOR, played a psychotherapist of Carl Rogers's school, who draws a client out by
handing their words back as questions, and so can seem attentive while knowing nothing of the
world.  Many who typed to it believed it understood them.  That troubled Weizenbaum, and in
*Computer Power and Human Reason* (1976) he argued against leaving human judgement to machines.

GNU Emacs has had a doctor of its own since the mid-1980s: `doctor.el`, whose copyright notice
begins in 1985, is not Weizenbaum's program but a new one, written in Emacs Lisp, that works in
ELIZA's way.
