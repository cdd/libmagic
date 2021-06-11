= libmagic

* https://github.com/cdd/libmagic

== DESCRIPTION:

Ruby wrapper for the Unix file/libmagic utility, which can guess mime types and character sets.

== FEATURES/PROBLEMS:

* Determines mime type of a file, IO or string
* Can also just return the charset of a text file
* Cannot detect various flavors of extended ASCII that are not ISO-8859-1, returns "unknown" as the charset in all cases
* For many uses this is good enough, because by far the most common "unknown" will be windows-1252

== SYNOPSIS:

  Magic.file_mime_type("path_to_file.pdf")
  Magic.file_charset("path_to_file.txt")

== REQUIREMENTS:

* the Unix program file (aka libmagic)'s libraries and headers (see below for installation)

== INSTALL:

* install file/libmagic's libraries and headers
  * on Ubuntu: sudo aptitude install libmagic-dev
  * on OS X with MacPorts: sudo port install file
    Unfortunately, the version of file that comes with OS X appears to be statically linked

* sudo gem install libmagic

== LICENSE:

(The MIT License)

Copyright (c) 2008 Collaborative Drug Discovery, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
