CHANGELOG
=========

v0.0.9
------

Changed the initialization procedure, which wasn't working on some systems.

v0.0.8
------

A few new, useful functions.  .ext() overloaded to take an argument, spit out the path with .arg added to the end.  timestamp() 

v0.0.7
------

Added dependency on `fun_with_version_strings`.  Then removed it, cuz fwvs needs fwf more.  Bleh.
Added filepath.md5() => hexdigest of file contents.
Added shaXXXX functions, so the poor li'l crypto won't feel left out.


0.0.4 - 0.0.6
-------------

I've not been so good about updating this doc.


0.0.3
-----

Added .succession() to get all existing files within a succession group.  The differentiating piece of the filename can be either a timestamp or a numeric ID.


TODO
----

* It really makes more sense for path.basename to return a string instead of a filepath.  Or is it?  Why does Pathname.basename return a path?  Imma cargo cult this and leave it as-is.