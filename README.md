This is, on the face of it, a program to draw facades of buildings with somewhat random wondows and doors.  Even as just this, it is deficient in many ways.  It doesn't have enough range of colours, and there are far too few kinds of windows.

But that isn't the purpose of this code; it's a vehicle for another objective.

I'm building a library to manage attributes while drawing pictures.

Attibutes will be things like architectural style, sizes, colours, and so forth.
I'm using association lists simulate dynamic binding (as opposed to the static binding that Scheme uses everywhere) to manage style information,
though I suspect that plain old association lists as present in the original Lisp 1.5 may be too simple.
But I won't find out in what way they are oversimplified until I try them out and see where it gets awkward.

There are perhaps too many functions that explicitly manipulate association lists,
taking association lists as parameters and returning them as results.
I'd prefer to use ones where the association list is implicit,
so I don't fill user code with a lot of lambda's and a's or a-list's.

I'm currently in transition.
The user won't be compounding picts explicitly,
but instead compounding functions that return picts.

I suspect the functions that explicitly mention association lists will be
* those that implement operations on association lists
* those that use pict primitives directly.

I suspect that the mechanism of having associations returning functions isn't ideal either.
Combining these functions with freezing is a way of indicating at what level decisions are made,
and having functions that return functions also gives multilevel freezing.
But I suspect I'd really want something more like probability distributions that can be combined and modified variously.

But I suspect the association lists may need other kinds of binding rather than encoding this information in the bound value's type.

As for the instance of door generation I've built so far:
Simply having width and height for a door isn't enough.
Other things have dimensions.
And things within things have context-dependent dimensions.
At the moment I'm using hc-append and vc-append to *add* dimensions bottom-up.
But I'll need to use top-down constraints as well at some point,
and even have the presence or absence of subobjects depend on constraints.

Maybe I need doorwidth and doorheight.

TODO:  I could use a notation for parameterless functions and costant functions.
e.g. (K foo) could be (lambda (a) foo)
Should foo be evaluated at call time or lambda time?
In combinatory logic it doesn't matter.  Here it might.

TODO: What's the way of producing run-time errors that abort execution and produce a traceback?  List printing a message containing the word ERROR isn't enough.

I am also slowly familiarising myself with Racket.
I've used Lisp-like languages before, but with significantly different syntax.
I use nested if's, for example, where I could better use cond.
I'm not yet familiar enough with ordinary Scheme to have good taste in redesigning the language to better suit my application.
I haven't even enough experience with the application to figure out what the right data and control structures should be.

What my current recursive passing down assocation lists doesn't do:

* Impose constraints on subobject
* Have style libraries that can be activated on several independent objects.
* Have regional styles that are different for various areas but admit exceptions.
* Do anything with 3-D
* Deal with floor plans instead of facades
* Do any kind of space subdivision that isn't hierarchical rectangles.
