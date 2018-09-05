Gem::Specification.new do |s|
  s.name = "libmagic"
  s.version = "0.5.10"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["CDD Development Staff <info@collaborativedrug.com>"]
  s.date = "2010-02-04"
  s.description = "Wrapper for libmagic's magic_file and magic_buffer methods"
  s.email = ""
  s.files = ["test/test_magic.rb", 
             "test/files/utf-8.txt",
             "test/files/iso-8859-1.txt",
             "test/files/windows-1252.txt",
             "test/files/us-ascii.txt",
             "test/files/macintosh.txt",
             "test/files/huge_file_with_one_special_character.csv",
             "test/files/huge_file_with_one_special_character_at_the_end.csv",
             "test/files/part_of_ki_file.csv",
             "lib/libmagic.rb",
             "lib/custom-magic",
             "lib/custom-magic.mime",
             "libmagic.gemspec"]
  s.has_rdoc = false
  s.homepage = ""
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.0"
  s.summary = "Wrapper for libmagic's magic_file and magic_buffer methods, plus extra goodness"
  s.test_files = ["test/test_magic.rb"]
  
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
    
    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency("ffi", "1.9.25")
    else
      s.add_dependency("ffi", "1.9.25")
    end
  else
    s.add_dependency("ffi", "1.9.25")
  end
end
