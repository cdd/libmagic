Gem::Specification.new do |s|
  s.name = "libmagic"
  s.version = "0.1"
  
  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["CDD Development Staff <info@collaborativedrug.com>"]
  s.date = "2008-05-06"
  s.description = "Wrapper for libmagic's magic_file method"
  s.email = ""
  s.extensions = ["ext/extconf.rb"]
  s.files = ["test/test_magic.rb", 
              "test/files/utf-8.txt",
              "test/files/iso-8859-1.txt",
              "test/files/windows-1252.txt",
              "test/files/us-ascii.txt",
              "test/files/macintosh.txt",
             "ext/libmagic_wrapper.c",
             "ext/extconf.rb", 
             "lib/libmagic.rb",
             "libmagic.gemspec"]
  s.has_rdoc = false
  s.homepage = ""
  s.require_paths = ["lib", "ext"]
  s.rubygems_version = "0.9.4.6"
  s.summary = "Wrapper for libmagic's magic_file method"
  s.test_files = ["test/test_magic.rb"]
end
