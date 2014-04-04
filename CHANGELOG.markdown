0.0.7
=====

Added dependency on `fun_with_version_strings`.  Then removed it, cuz fwvs needs fwf more.  Bleh.
Added filepath.md5 => hexdigest of file contents.


0.0.4 - 0.0.6
=============

I've not been so good about updating this doc.


0.0.3
=====

Added .succession() to get all existing files within a succession group.  The differentiating piece of the filename can be either a timestamp or a numeric ID.


TODO
====

* It really makes more sense for path.basename to return a string instead of a filepath.  Or is it?  Why does Pathname.basename return a path?  Imma cargo cult this and leave it as-is.