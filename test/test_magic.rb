require "rubygems"
require 'lib/libmagic'
require 'test/unit'

class MagicTest < Test::Unit::TestCase
  def test_public_interface_is_limited
    assert_equal(%w(file_charset file_charset! file_mime_type io_charset string_charset string_mime_type),
                 (Magic.public_methods - Magic.instance_methods - FFI::Library.methods - FFI::Library.instance_methods).sort)
  end
  
  def test_file_mime_type_for_utf8_file
    # regex necessary because some versions of file return the semicolon and some don't
    assert(Magic.file_mime_type(absolute_path("utf-8.txt")) =~ /text\/plain;? charset=utf-8/)
  end
  
  def test_string_mime_type_for_utf8_text
    # regex necessary because some versions of file return the semicolon and some don't
    assert(Magic.string_mime_type("Some truly Unicode characters like: 불거기") =~ /text\/plain;? charset=utf-8/)
  end
  
  def test_string_charset_for_utf8_text
    assert_equal("utf-8", Magic.string_charset("Some truly Unicode characters like: 불거기"))
  end
  
  def test_file_charset_for_ascii_file
    assert_equal("us-ascii", Magic.file_charset(absolute_path("us-ascii.txt")))
  end
  
  def test_file_charset_for_large_CSV_file_that_libmagic_thinks_is_pascal_sourcecode
    assert_equal("us-ascii", Magic.file_charset(absolute_path("part_of_ki_file.csv")))
  end
  
  def test_file_charset_for_utf8_file
    assert_equal("utf-8", Magic.file_charset(absolute_path("utf-8.txt")))
  end
  
  def test_file_charset_for_iso_8859_1_file
    assert_equal("iso-8859-1", Magic.file_charset(absolute_path("iso-8859-1.txt")))
  end
  
  def test_string_charset_for_iso_8859_1_text
    assert_equal("iso-8859-1", Magic.string_charset("A\240B\240C"))
  end
  
  def test_file_charset_for_windows_1252_file
    # unfortunately, unknown means some kind of extended ascii
    assert_equal("unknown", Magic.file_charset(absolute_path("windows-1252.txt")))
  end
  
  def test_file_charset_for_macintosh_file
    # unfortunately, unknown means some kind of extended ascii
    assert_equal("unknown", Magic.file_charset(absolute_path("macintosh.txt")))
  end
  
  def test_file_charset_for_csv_file_that_looked_like_ppm_image
    assert_equal("us-ascii", Magic.file_charset(absolute_path("file_with_text_that_looked_like_ppm_image.csv")))
  end
  
  def test_raises_if_file_does_not_exist
    begin
      Magic.file_charset("some file that does not exist.txt")
      fail "Did not raise"
    rescue ArgumentError => expected
      assert(expected.message =~ /NULL/i) # for this, we don't use assert_raise
    end
  end
  
  def test_file_charset_bang_exhaustively_checks_file_contents
    # huge_file_with_one_special_character.csv
    t1 = Time.now
    assert_equal("us-ascii", Magic.file_charset(absolute_path("huge_file_with_one_special_character.csv")))
    assert_equal("iso-8859-1", Magic.file_charset!(absolute_path("huge_file_with_one_special_character.csv")))
    puts "took #{Time.now - t1} seconds"
  end
  
  def test_io_charset_for_ascii_file
    assert_equal("us-ascii", Magic.io_charset(File.open((absolute_path("us-ascii.txt")))))
  end
  
  def test_io_charset_for_utf8_file
    assert_equal("utf-8", Magic.io_charset(File.open(absolute_path("utf-8.txt"))))
  end
  
  def test_io_charset_for_iso_8859_1_file
    assert_equal("iso-8859-1", Magic.io_charset(File.open(absolute_path("iso-8859-1.txt"))))
  end
  
  def test_io_charset_for_windows_1252_file
    # unfortunately, unknown means some kind of extended ascii
    assert_equal("unknown", Magic.io_charset(File.open(absolute_path("windows-1252.txt"))))
  end
  
  def test_io_charset_for_macintosh_file
    # unfortunately, unknown means some kind of extended ascii
    assert_equal("unknown", Magic.io_charset(File.open(absolute_path("macintosh.txt"))))
  end
  
  def test_io_charset_for_csv_file_that_looked_like_ppm_image
    assert_equal("us-ascii", Magic.io_charset(File.open(absolute_path("file_with_text_that_looked_like_ppm_image.csv"))))
  end
  
  (128..159).each do |windows_char|
    eval <<-EOMETHOD
      def test_string_charset_for_string_with_windows_char_#{windows_char}_returns_unknown
        assert_equal("unknown", Magic.string_charset("over, and over, and over\\#{windows_char.to_s(8)}"))
      end
    EOMETHOD
  end

  # although this is redundant, it's nice to document the one weird case we've found explicitly
  def test_string_charset_for_string_with_windows_ellipsis_returns_unknown
    # windows 1252 ellipsis is 133 = 0205
    # this is a weird case found from a file Sylvia had problem slurping
    assert_equal("unknown", Magic.string_charset("over, and over, and over\205"))
  end

  def test_file_charset_bang_returns_correct_value_for_us_ascii_file
    assert_equal("us-ascii", Magic.file_charset!(absolute_path("us-ascii.txt")))
  end
  
  def test_file_charset_bang_returns_correct_value_for_windows_1252_file
    assert_equal("unknown", Magic.file_charset!(absolute_path("windows-1252.txt")))
  end
  
  def test_file_charset_bang_returns_correct_value_for_UTF8_file
    assert_equal("utf-8", Magic.file_charset!(absolute_path("utf-8.txt")))
  end
  
  def test_file_charset_bang_handles_special_character_at_the_end_of_the_file
    assert_equal("us-ascii", Magic.file_charset(absolute_path("huge_file_with_one_special_character_at_the_end.csv")))
    assert_equal("iso-8859-1", Magic.file_charset!(absolute_path("huge_file_with_one_special_character_at_the_end.csv")))
  end
  
  def absolute_path(test_file_name)
    "#{ENV["PWD"]}/test/files/#{test_file_name}"
  end
end
