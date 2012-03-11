# -*- mode: ruby; ruby-indent-level: 2; tab-width: 2 -*-
# vim: noet ts=2 sts=8 sw=2

require 'pathname'
require 'fileutils'
require 'erb'



require 'rdoc/generator/markup'

$RUBYDOC_DRYRUN = false # TODO make me non-global

#
# Rubydoc RDoc HTML Generator
#
# $Id: rubydoc.rb 52 2009-01-07 02:08:11Z deveiant $
#
# == Author/s
# * Michael Granger (ged@FaerieMUD.org)
#
# == Contributors
# * Mahlon E. Smith (mahlon@martini.nu)
# * Eric Hodel (drbrain@segment7.net)
#
# == License
#
# Copyright (c) 2007, 2008, Michael Granger. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the author/s, nor the names of the project's
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
class RDoc::Generator::Rubydoc

	RDoc::RDoc.add_generator( self )

	include ERB::Util

	# Path to this file's parent directory. Used to find templates and other
	# resources.
	GENERATOR_DIR = File.join 'rdoc', 'generator'

	# Release Version
	VERSION =     '0.10.0' #FIXME This is in two, yes *two* places.

	# Directory where generated classes live relative to the root
	CLASS_DIR = nil

	# Directory where generated files live relative to the root
	FILE_DIR = nil


	#################################################################
	###	C L A S S   M E T H O D S
	#################################################################

	### Standard generator factory method
	def self::for options 
		new options 
	end


	#################################################################
	###	I N S T A N C E   M E T H O D S
	#################################################################


	def render_if_exists file_path
		full_path = "#{ENV['RDOC_EXTERNALS_PATH']}#{file_path}"

		if File.exist? full_path
			IO.read full_path
		end

	  #warn "#{'_' * 90}"
		#warn "full_path   = #{full_path}"
	  #warn "#{'_' * 90}"
	end

	### Initialize a few instance variables before we start
	def initialize options 
		@options = options
		@footer_blurbs = []
		@menu_bar = %~<ul class='grids g0'>
  <li class='grid-2' ><a href='/' target='_top' >Home</a></li>
  <li class='grid-2' ><a href='/core' target='_top' >Core</a></li>
  <li class='grid-2' ><a href='/stdlib' target='_top' >Std-lib</a></li>
  <li class='grid-2' ><a href='/gems' target='_top' >Gems</a></li>
  <li class='grid-2' ><a href='/downloads' target='_top' >Downloads</a></li>
  <li class='grid-5 right' id='rd-action-search'><form id="searchbox_011815814100681837392:wnccv6st5qk" action="/search.html"><input type="hidden" name="cx" value="011815814100681837392:wnccv6st5qk" ><input name="q" type="text" size="20" >&#160;&#160;<input type="submit" name="sa" value="Search" ><input type="hidden" name="cof" value="FORID:9" ></form>
</li>
</ul>~

		if ENV['rdoc_blurbs_file'] && File.exist?(ENV['rdoc_blurbs_file'])
				@footer_blurbs = IO.readlines ENV['rdoc_blurbs_file']
		end

		@ruby_version = ENV['rdoc_ruby_version'] || nil	

		template = @options.template || 'rubydoc'

		template_dir = $LOAD_PATH.map do |path|
			#File.join File.expand_path(path), GENERATOR_DIR, 'template', template
			File.join File.expand_path(path), GENERATOR_DIR, template
		end.find do |dir|
			File.directory? dir
		end

		raise RDoc::Error, "could not find the template #{template.inspect} in '#{template_dir.strip}'" unless template_dir
		raise RDoc::Error, "template_dir is empty!" if template_dir.to_s.strip.empty?

		@template_dir = Pathname.new File.expand_path(template_dir)

		raise RDoc::Error, "@template_dir is empty!" if @template_dir.to_s.strip.empty?
		
		@files      = nil
		@classes    = nil

		@basedir = Pathname.pwd.expand_path
	end

	######
	public
	######

	# The output directory
	attr_reader :outputdir


	### Output progress information if debugging is enabled
	def debug_msg( *msg )
		return unless $DEBUG_RDOC
		$stderr.puts( *msg )
	end

	def class_dir
		CLASS_DIR
	end

	def file_dir
		FILE_DIR
	end

	### Create the directories the generated docs will live in if
	### they don't already exist.
	def gen_sub_directories
		@outputdir.mkpath
	end

	### Copy over the stylesheet into the appropriate place in the output
	### directory.
	def write_style_sheet
		debug_msg "Copying the static files from '#{@template_dir}' ..."
		options = { :verbose => $DEBUG_RDOC, :noop => $RUBYDOC_DRYRUN }
		
		

	#	%w{
	#	2011
	#	grid.inuit
	#	inuit
	#	inuit.style
	#	rdoc
  #	github
	#	zenburn
	#	default
	#		}.each do |file|
	#	  	raise RDoc::Error, "@template_dir is empty!" if @template_dir.to_s.strip.empty?
	#	    
	#		  _from = "#{@template_dir}/css/#{file}.css"
  #       warn "_from = #{_from} "

 	#			 raise "Malformed template css dir! #{_from}" if _from =~ /^\/css/
 # 
	#			 dst = Pathname.new(@template_dir + '/css').relative_path_from @template_dir


	#			 FileUtils.cp  _from, "#{dst}/#{file}.css", options 
  #  end

		Dir[(@template_dir + "{js,images,css}/**/*").to_s].each do |path|
			# debug_msg "Copy '#{path}' ?"
			next if File.directory? path
#			next if path =~ /#{File::SEPARATOR}\./

			dst = Pathname.new(path).relative_path_from @template_dir

			# I suck at glob
			dst_dir = dst.dirname
			FileUtils.mkdir_p dst_dir, options unless File.exist? dst_dir

			FileUtils.cp @template_dir + path, dst, options
		end
	end

	### Build the initial indices and output objects
	### based on an array of TopLevel objects containing
	### the extracted information.
	def generate( top_levels )
		@outputdir = Pathname.new( @options.op_dir ).expand_path( @basedir )

		@files = top_levels.sort
		@classes = RDoc::TopLevel.all_classes_and_modules.sort
		@methods = @classes.map { |m| m.method_list }.flatten.sort
		@modsort = get_sorted_module_list( @classes )

# Copied from Babel
		# ------------------
		 @all_classes_and_modules = RDoc::TopLevel.all_classes_and_modules.sort
    @unique_classes_and_modules = RDoc::TopLevel.unique_classes_and_modules.sort

    @all_methods = @unique_classes_and_modules.
      inject([]) { |a,m| a.concat m.method_list }.
      sort { |a,b| [a, a.parent_name] <=> [b, b.parent_name] }

    @all_files = top_levels # not sorted: keep command line order
    @files_with_comment = @all_files.reject { |f| f.comment.empty? }
    @simple_files = @files_with_comment.select { |f| f.parser == RDoc::Parser::Simple }

		@files_to_display =
      if @unique_classes_and_modules.empty?
        @all_files
      else
        @simple_files
      end

    @main_file = @options.main_page && @all_files.find { |f| f.full_name == @options.main_page }
    if @main_file
      unless @files_to_display.find { |f| f.full_name == @options.main_page }
        @files_to_display.unshift @main_file
      end
    end

#------------

		# Now actually write the output
		write_style_sheet
		generate_index
		generate_class_files
		generate_file_files

	rescue StandardError => err
		debug_msg "%s: %s\n  %s" % [ err.class.name, err.message, err.backtrace.join("\n  ") ]
		raise
	end

	#########
	protected
	#########

	### Return a list of the documented modules sorted by salience first, then
	### by name.
	def get_sorted_module_list( classes )
		nscounts = classes.inject({}) do |counthash, klass|
			top_level = klass.full_name.gsub( /::.*/, '' )
			counthash[top_level] ||= 0
			counthash[top_level] += 1

			counthash
		end

		# Sort based on how often the top level namespace occurs, and then on the
		# name of the module -- this works for projects that put their stuff into
		# a namespace, of course, but doesn't hurt if they don't.
		classes.sort_by do |klass|
			top_level = klass.full_name.gsub( /::.*/, '' )
			[
				nscounts[ top_level ] * -1,
				klass.full_name
			]
		end.select do |klass|
			klass.document_self
		end
	end

	def raw_rel_path_prefix outfile
		@outputdir.relative_path_from outfile.dirname 
	end

	def rel_path_prefix outfile, fixed=false
		if ENV['RDOC_FOR_WEBSITE'] =~ /yes|true|ok/i
			#warn "Have ENV['RDOC_FOR_WEBSITE'], rel_path_prefix = '/'"
			return '/' unless fixed
		end

		rel_prefix = @outputdir.relative_path_from outfile.dirname 

		if rel_prefix.to_s == '.'
			#warn "\n===========================================================\n"
			#warn "rel_prefix == '.', so change it!"
			rel_prefix = ''
		end

    if rel_prefix.to_s.size == 1
			#		warn "\n===========================================================\n"
			#warn "rel_prefix.size == 1 , so change it!"
		

			rel_prefix = ''
		end


		if rel_prefix.to_s.size > 1 
			rel_prefix = rel_prefix.to_s + '/' unless  rel_prefix.to_s =~ /\/$/
		end

	#	
		raise "WTF is prex == . ?" if rel_prefix.to_s == '.'
		#warn "\n.......................\nrel_prefix  now = '#{rel_prefix}'"

    rel_prefix 

	end


	### Generate an index page which lists all the classes which
	### are documented.
	def generate_index
		template_file = @template_dir + 'index.rhtml'
		return unless template_file.exist?

		debug_msg "Rendering the index page..."

		template_src = template_file.read
		template = ERB.new( template_src, nil, '<>' )
		template.filename = template_file.to_s
		context = binding()

		output = nil

		begin
			output = template.result( context )
		rescue NoMethodError => err
			raise RDoc::Error, "Error while evaluating %s: %s (at %p)" % [
				template_file,
				err.message,
				eval( "_erbout[-50,50]", context )
			], err.backtrace
		end


		outfile = @basedir + @options.op_dir + 'index.html'
		
		rel_prefix = rel_path_prefix outfile 
		local_rel_prefix = rel_path_prefix outfile , :fix
		raw_prefix = raw_rel_path_prefix outfile 


		unless $RUBYDOC_DRYRUN
			debug_msg "Outputting to %s" % [outfile.expand_path]
			outfile.open( 'w', 0644 ) do |fh|
				fh.print( output )
			end
		else
			debug_msg "Would have output to %s" % [outfile.expand_path]
		end
	end

	### Generate a documentation file for each class
	def generate_class_files
		template_file = @template_dir + 'classpage.rhtml'
		return unless template_file.exist?
		debug_msg "Generating class documentation in #@outputdir"

		@classes.each do |klass|
			debug_msg "  working on %s (%s)" % [ klass.full_name, klass.path ]
			outfile    = @outputdir + klass.path
			rel_prefix = rel_path_prefix outfile
			raw_prefix = raw_rel_path_prefix outfile 
			local_rel_prefix = rel_path_prefix outfile , :fix
			svninfo    = self.get_svninfo klass 

			debug_msg "  rendering #{outfile}"
			self.render_template( template_file, binding(), outfile )
		end
	end

	### Generate a documentation file for each file
	def generate_file_files
		template_file = @template_dir + 'filepage.rhtml'
		return unless template_file.exist?
		debug_msg "Generating file documentation in #@outputdir"

		@files.each do |file|
			outfile     = @outputdir + file.path
			debug_msg "  working on %s (%s)" % [ file.full_name, outfile ]
			rel_prefix = rel_path_prefix outfile
			raw_prefix = raw_rel_path_prefix outfile 
			local_rel_prefix = rel_path_prefix outfile , :fix
			context     = binding()

			debug_msg "  rendering #{outfile}"
			self.render_template( template_file, binding(), outfile )
		end
	end


	### Return a string describing the amount of time in the given number of
	### seconds in terms a human can understand easily.
	def time_delta_string seconds 
		return 'less than a minute' if seconds < 1.minute
		return (seconds / 1.minute).to_s + ' minute' + (seconds/60 == 1 ? '' : 's') if seconds < 50.minutes
		return 'about one hour' if seconds < 90.minutes
		return (seconds / 1.hour).to_s + ' hours' if seconds < 18.hours
		return 'one day' if seconds < 1.day
		return 'about one day' if seconds < 2.days
		return (seconds / 1.day).to_s + ' days' if seconds < 1.week
		return 'about one week' if seconds < 2.week
		return (seconds / 1.week).to_s + ' weeks' if seconds < 3.months
		return (seconds / 1.month).to_s + ' months' if seconds < 1.year
		return (seconds / 1.year).to_s + ' years'
	end


	# %q$Id: rubydoc.rb 52 2009-01-07 02:08:11Z deveiant $"
	SVNID_PATTERN = /
		\$Id:\s
			(\S+)\s					# filename
			(\d+)\s					# rev
			(\d{4}-\d{2}-\d{2})\s	# Date (YYYY-MM-DD)
			(\d{2}:\d{2}:\d{2}Z)\s	# Time (HH:MM:SSZ)
			(\w+)\s				 	# committer
		\$$
	/x

	### Try to extract Subversion information out of the first constant whose value looks like
	### a subversion Id tag. If no matching constant is found, and empty hash is returned.
	def get_svninfo( klass )
		constants = klass.constants or return {}

		constants.find {|c| c.value =~ SVNID_PATTERN } or return {}

		filename, rev, date, time, committer = $~.captures
		commitdate = Time.parse( date + ' ' + time )

		return {
			:filename    => filename,
			:rev         => Integer( rev ),
			:commitdate  => commitdate,
			:commitdelta => time_delta_string( Time.now.to_i - commitdate.to_i ),
			:committer   => committer,
		}
	end


	### Load and render the erb template in the given +template_file+ within the
	### specified +context+ (a Binding object) and write it out to +outfile+.
	### Both +template_file+ and +outfile+ should be Pathname-like objects.

	def render_template template_file, context, outfile 
		template_src = template_file.read
		template = ERB.new( template_src, nil, '<>' )
		template.filename = template_file.to_s

		output = begin
							 template.result context 
						 rescue NoMethodError => err
							 raise RDoc::Error, "Error while evaluating %s: %s (at %p)" % [
								 template_file.to_s,
								 err.message,
								 eval( "_erbout[-50,50]", context )
							 ], err.backtrace
						 end

		unless $RUBYDOC_DRYRUN
			outfile.dirname.mkpath
			outfile.open( 'w', 0644 ) do |ofh|
				ofh.print output 
			end
		else
			debug_msg "  would have written %d bytes to %s" %
			[ output.length, outfile ]
		end
	end

end # Roc::Generator::Rubydoc

# :stopdoc:

### Time constants
module TimeConstantMethods # :nodoc:

	### Number of seconds (returns receiver unmodified)
	def seconds
		return self
	end
	alias_method :second, :seconds

	### Returns number of seconds in <receiver> minutes
	def minutes
		return self * 60
	end
	alias_method :minute, :minutes

	### Returns the number of seconds in <receiver> hours
	def hours
		return self * 60.minutes
	end
	alias_method :hour, :hours

	### Returns the number of seconds in <receiver> days
	def days
		return self * 24.hours
	end
	alias_method :day, :days

	### Return the number of seconds in <receiver> weeks
	def weeks
		return self * 7.days
	end
	alias_method :week, :weeks

	### Returns the number of seconds in <receiver> fortnights
	def fortnights
		return self * 2.weeks
	end
	alias_method :fortnight, :fortnights

	### Returns the number of seconds in <receiver> months (approximate)
	def months
		return self * 30.days
	end
	alias_method :month, :months

	### Returns the number of seconds in <receiver> years (approximate)
	def years
		return (self * 365.25.days).to_i
	end
	alias_method :year, :years


	### Returns the Time <receiver> number of seconds before the
	### specified +time+. E.g., 2.hours.before( header.expiration )
	def before time 
		return time - self
	end


	### Returns the Time <receiver> number of seconds ago. (e.g.,
	### expiration > 2.hours.ago )
	def ago
		return self.before ::Time.now 
	end


	### Returns the Time <receiver> number of seconds after the given +time+.
	### E.g., 10.minutes.after( header.expiration )
	def after time
		return time + self
	end

	# Reads best without arguments:  10.minutes.from_now
	def from_now
		return self.after( ::Time.now )
	end
end # module TimeConstantMethods


# Extend Numeric with time constants
class Numeric # :nodoc:
	include TimeConstantMethods
end


