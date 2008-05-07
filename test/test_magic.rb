require 'lib/libmagic'
require 'test/unit'

class MagicTest < Test::Unit::TestCase
  def test_file_mime_type_for_utf8_file
    assert_equal("text/plain charset=utf-8", Magic.file_mime_type(absolute_path("utf-8.txt")))
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
  
  def test_file_charset_for_windows_1252_file
    # unfortunately, unknown means some kind of extended ascii
    assert_equal("unknown", Magic.file_charset(absolute_path("windows-1252.txt")))
  end
  
  def test_file_charset_for_macintosh_file
    # unfortunately, unknown means some kind of extended ascii
    assert_equal("unknown", Magic.file_charset(absolute_path("macintosh.txt")))
  end
  
  def test_raises_if_file_does_not_exist
    begin
      Magic.file_charset("some file that does not exist.txt")
      fail "Did not raise"
    rescue RuntimeError => expected
      assert(expected.message =~ /no such file or directory/i) # for this, we don't use assert_raise
    end
  end
  
  def absolute_path(test_file_name)
    "#{ENV["PWD"]}/test/files/#{test_file_name}"
  end
end
