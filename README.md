# What works

door.rkt draws the facade of a house. usually with somw shrubs in front.

matcher.rkt prints some invented potential murder reports.

gen.txt prints out some one-sentence quests.

None of this code is stable, and will almost certainly change incompatibly.
If you use any of it, make and use your own copy; otherwise things will likely break when I update this put from under you.

All of this README (and a lot of the comments in the code) is written in a personal style.  That's just the way I tend to work, writing what I'm trying to do informally long before I implement anything.  My code is sometimes saturated with comments explaining what I'm trying to do rather than what I'm doing.

I'm not embarrassed anout making mistakes (or typos) either.  I know that the road to success is paved with mistakes.  Let me know if you find anything wrong or stupid or that could be improved.

# About door.rkt

This is, on the face of it, a program to draw facades of buildings with somewhat random windows and doors.  Even as just this, it is deficient in many ways.  It doesn't have enough range of coordinated colours (it doesn't even know how to coordinate colours), and there are far too few kinds of windows, door handles, mailbox slots (actually none of these latter).

But that isn't the purpose of this code; it's a vehicle for another objective.

I'm building a library to manage attributes while drawing pictures.

Attibutes will be things like architectural style, sizes, colours, and so forth.  Maybe eventually climate, life zone, local geology, and so forth.

I'm using association lists to simulate dynamic binding (as opposed to the static binding that Scheme uses everywhere) to manage style information,
though I suspect that the plain old association lists from the original Lisp 1.5 may be too simplistic.

But I won't find out in what way they are simplistic until I try them out and see where it gets awkward.

There are perhaps too many functions that explicitly manipulate association lists,
taking association lists as parameters and returning them as results.
I'd prefer to use ones where the association list is implicit,
so I don't fill user code with a lot of lambda's and a's or a-list's.
(some functions call a-lists 'a'; others call them 'env'; also inconsistent)

I'm currently in transition between the explicit and implicit styles.
The user won't be compounding picts directly,
but instead compounding functions that return picts.

I suspect the functions that explicitly mention association lists will be
* those that implement operations on association lists
* those that use pict primitives directly.

I suspect that the mechanism of having associations returning functions isn't ideal either.
Combining these functions with freezing is a way of indicating at what level decisions are made,
and having functions that return functions also gives multilevel freezing.
But I suspect I'd really want something more like probability distributions that can be combined and modified.

But I suspect the association lists may need other kinds of binding rather than encoding this information in the bound value's type.

As for the instance of door generation I've built so far:
Simply having width and height for a door isn't enough.
Other things have dimensions.
And things within things have context-dependent dimensions.
At the moment I'm using hc-append and vc-append to *add* dimensions bottom-up.

But if may be convenient to pass down contextual resource constraints, such as available area.  A door-drawer could key off that to determine door size.  Drawing code could simply refuse to draw if ther isn't enought space, forcing the context to consider alternatives.

Maybe I need doorwidth and doorheight.

TODO:  I could use a notation for parameterless functions and constant functions.
e.g. (K foo) could be (lambda (a) foo)
Should foo be evaluated at call time or lambda time?
In combinatory logic it doesn't matter (as long as everything still terminates).  Here it might.

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

Nor do I
* Do anything with 3-D
* Deal with floor plans instead of facades
* Do any kind of space subdivision that isn't hierarchical rectangles.

# About matcher and gen

These are seemingly independent of door, certainly at present.

matcher.rkt is the beginning of a rule formalism for a plot calculus (still only a vague concept)

* Ideas toward plot generator
  * actors
  * traits
    * ambitious
    * is a thif
  * Possessions
    * life
    * a knife
  * actions

* e.g.
  * Bob has knife
  * John is a thief
  * therefore John has a knife

Example: the puritan lecher (inhereht plot conflict)

Note:  If you interpret the above list differently from me, don't worry.
It'll just mean we have mode ideas!

TODO: Someone rcommended I have a look at Crusader Kings 2


gen.rkt is likewise a beginning -- currently it describes quests -- the kinds of things that are often quested for in fantasy games and novels.  No, I really don't know where this is going.  That's the point of doing this.

And I hope the attribute mechanism in door will eventually expand to being able to talk about map regions instead of doors an windows.  This will need much experimentation.

gen has a trial mechanism for probabilities, which may get adopted, or something like it, for door.rkt.

# pict3d

I would love to get textures in a 3D scene, but pict3d does not do that.
Current source repository for pict3d turns out to be https://pkgs.racket-lang.org/package/pict3d
