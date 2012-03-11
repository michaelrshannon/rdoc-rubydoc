# RDoc-Rubydoc #

http://github.com/neurogami/rdoc-rubydoc

Maintained by James Britt <james@neurogami.com>


## Description

`rubydoc` is an RDoc formatter producing HTML documentation.

The default template is +rubydoc+.

You are welcome to propose changes or enhancements, and to contribute alternate templates or style sheets.

Large chunks of the site were copped from the Darkfish RDoc template (http://deveiate.org/projects/Darkfish-Rdoc).

The Inuit CSS framework (http://csswizardry.com/inuitcss) is also a part of this template.


### Features of the "rubydoc" template

- Look and feel used for ruby-doc.org[http://www.ruby-doc.org/].
- Search boxes for classes and methods.
- Other stuff


## Note ##

The template was developed as part of an upgrading of ruby-doc.org.  

One goal was to have a common look across the entire site.  That meant that the CSS and (to some extent) templating needed to be shared across seperate projects.

When generating pages for ruby-doc.org the CSS is first pulled from a local copy of the site and used as the css for the rdocs.

However, if you are using this template for your purposes you'll likely *not* have a local copy of ruby-doc.org, so CSS is included here.

There are still a number of things in flux, and assorted cruft that needs to be tightened up or removed.

Some effort has been made to make the template less tightly coupled to the ruby-doc.org site, but the fact is this template was _created_ for that site.



## Synopsis

To output documentation formatted by Rubydoc, use the <tt>--format/-f</tt>
RDoc switch. For instance, to generate the documentation for Ruby core:

`
  $ gem install rdoc-rubydoc
  $ cd ~/.rvm/src/ruby-1.8.7-p302
  $ rdoc -f rubydoc -a -t "Ruby 1.8.7 Core" -o ~/docs/ruby_core_187 *.c
`
Using rake:
`
  require 'rdoc/task'

  RDoc::Task.new do |t|
    Dir.chdir '~/.rvm/src/ruby-1.9.2-p0'
    rdoc.options <<
      '--format' << 'rubydoc' <<
      '--all'
    t.title = "Ruby 1.9.2 Core"
    t.rdoc_dir = '~/docs/ruby_core_192'
    t.rdoc_files.concat Dir['*.c']
  end
`

To make Rubydoc the default format when generating RDoc documentation,
define the RDOCOPT environment variable in the appropriate file
(e.g., <tt>~/.bashrc</tt>):

`
  export RDOCOPT="--format rubydoc"
`

## Specific options

Rubydoc supports specific options in addition to the standard RDoc options:

[<tt>--style</tt> _url_, +-s+]

  Specifies the URL of a stylesheet that the template should use.
  The default is "rdoc.css".

[<tt>--see-standard-ancestors</tt>]

  Add links to Kernel/Object ancestor methods.

  When a method or attribute is defined in a class/module, and is also
  present in an ancestor, Rubydoc adds a link to the ancestor method/attribute
  in the description ("See also ..."). Unless this option is specified,
  this annotation is not generated for Object and Kernel ancestor methods.

## Requirements

- Ruby >= 1.8.7
- RDoc >= 3.0

## Installation
  
  Get the source code form GitHub
  run `rake rake install_gem`


  
## License

(The MIT License)

Copyright (c) 2012 James Britt

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
