require 'rubygems'
require 'hoe'


RUBY_SRC_DIR  = "#{ENV['HOME']}/.rvm/src/ruby-1.8.6-head" # :)

RUBY_SOURCE_VER = '1.8.6'

Hoe.spec 'rdoc-rubydoc' do

  developer('James Britt', 'james@neurogami.com')

  self.summary = "An RDoc formatter producing HTML documentation."
  self.description = paragraphs_of('README.md', 3, 6).join("\n\n")

  self.readme_file = 'README.md'
  self.history_file = 'HISTORY.rdoc'
  self.extra_rdoc_files = ['README.md', 'HISTORY.rdoc']

  self.remote_rdoc_dir = ''
  self.testlib = :minitest

  self.extra_deps << ['rdoc', '~> 3.0']

  self.extra_dev_deps << ['minitest', '>= 1.7']
  self.extra_dev_deps << ['nokogiri', '~> 1.4']

  spec_extras[:homepage] = 'http://github.com/neurogami/rdoc-rubydoc'
  spec_extras[:rdoc_options] = [
    '--main', 'README.md',
  ]

  #spec_extras[:post_install_message] = <<-EOS
  #  the crash for creating Rubydoc documentation is due to a RubyGem bug
  #EOS

end



# Grabs CSS, images, js from ruby-doc site files to make things consistant
# Note to people who don't have their own local ruby-doc site:
# The goal here to have a single set of CSS and scripts for Ruby-doc.org,
# and be able to edit them in one place, yet have them included as part 
# of the RDoc output.  
# 
#
def copy_over_files
  if ENV['RUBY_DOC_MAIN_SRC']
    destination_base = File.expand_path(File.dirname(__FILE__)) + '/lib/rdoc/generator/rubydoc'

    %w{css js images}.each do |i|   
      warn `rm  -rf  #{destination_base}/#{i}`
      warn `cp -rv #{ENV['RUBY_DOC_MAIN_SRC']}/#{i} #{destination_base}/`
    end
  else
    warn "No RUBY-DOC-MAIN-SRC, so no copying. Hope that's what you wanted."
  end

end


desc 'copy_over_files'
task :copy_over_files  do
    copy_over_files
end

#------------------------------------------------------------
# 
desc "Re-gem, install, re-run rdoc"
task  "dev:re-do-all" => [:clean, :copy_over_files, :gem, :install_gem] do
  rdoc_dir = "#{File.dirname(File.expand_path __FILE__)}/DOCS"
  puts `rm -rf #{rdoc_dir}`
  gen_rdoc RUBY_SRC_DIR, rdoc_dir, template='rubydoc'
  puts `cd #{rdoc_dir}; mkserver; cd -` # mkserver writes out a simple script to run heel and kick off a browser 
end

task :file_list do
  puts Dir['*'].reject { |f| File.directory? f }
  puts Dir['lib/**/*'].reject { |f| File.directory? f }
  puts Dir['test/**/*'].reject { |f| File.directory? f }
end


def gen_rdoc src_dir, rdoc_dir, template='rubydoc'
  Dir.chdir(src_dir) do
    cmd = "export rdoc_ruby_version=#{RUBY_SOURCE_VER}; rdoc -D -v -f #{template}   -a -t \"Ruby n.n.n Core\" -o #{rdoc_dir} *.c "
    puts cmd
    sh cmd
  end
end
