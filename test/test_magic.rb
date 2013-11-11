# coding: utf-8
require "rubygems"
require "lib/libmagic"
require "test/unit"
require "stringio"

class MagicTest < Test::Unit::TestCase
  def test_public_interface_is_limited
    assert_equal(%w(file_charset file_charset! file_mime_type io_charset string_charset string_mime_type).map { |m| m.to_sym },
                 (Magic.public_methods - Magic.instance_methods - FFI::Library.methods - FFI::Library.instance_methods).sort.map { |m| m.to_sym })
  end
  
  def test_file_mime_type_for_utf8_file
    # regex necessary because some versions of file return the semicolon and some don't
    assert(Magic.file_mime_type(absolute_path("utf-8.txt")) =~ /text\/plain;? charset=utf-8/)
  end
  
  def test_string_mime_type_for_utf8_text
    # regex necessary because some versions of file return the semicolon and some don't
    assert(Magic.string_mime_type("Some truly Unicode characters like: 불거기") =~ /text\/plain;? charset=utf-8/)
  end
  
  def test_string_charset_for_ascii_text
    assert_equal("us-ascii", Magic.string_charset("Just ASCII"))
  end
  
  def test_string_charset_for_utf8_text
    assert_equal("utf-8", Magic.string_charset("Some truly Unicode characters like: 불거기"))
  end
  
  def test_string_charset_for_iso_8859_1_text
    assert_equal("iso-8859-1", Magic.string_charset("A\240B\240C"))
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
  
  def test_string_charset_for_string_with_utf8_Angstrom_returns_utf8_not_unknown
    string = File.open(absolute_path("utf-8.csv.gz")) do |io|
      uncompressed_io = Zlib::GzipReader.new(io)
      uncompressed_io.read
    end
    assert_equal("utf-8", Magic.string_charset(string))
  end
  
  def test_io_charset_for_ascii_file
    assert_equal("us-ascii", Magic.io_charset(File.open((absolute_path("us-ascii.txt")))))
  end
  
  def test_io_charset_for_utf8_file
    assert_equal("utf-8", Magic.io_charset(File.open(absolute_path("utf-8.txt"))))
  end
  
  require "zlib"
  def test_io_charset_for_gzipped_utf8_file
    File.open(absolute_path("utf-8.csv.gz")) do |io|
      uncompressed_io = Zlib::GzipReader.new(io)
      assert_equal("utf-8", Magic.io_charset(uncompressed_io))
    end
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
  
  def test_file_charset_for_csv_file_that_looked_like_ppm_image
    assert_equal("us-ascii", Magic.file_charset(absolute_path("file_with_text_that_looked_like_ppm_image.csv")))
  end
  
  def test_file_charset_raises_if_file_does_not_exist
    # for this, we don't use assert_raise
    begin
      Magic.file_charset("some file that does not exist.txt")
      fail "Did not raise"
    rescue Exception => expected
      # ruby 1.9 and 1.8 return different exceptions
      assert(expected.message =~ /(some file that does not exist.txt|NULL pointer)/i)
    end
  end
  
  def test_file_charset_bang_exhaustively_checks_file_contents
    # huge_file_with_one_special_character.csv
    t1 = Time.now
    assert_equal("us-ascii", Magic.file_charset(absolute_path("huge_file_with_one_special_character.csv")))
    assert_equal("iso-8859-1", Magic.file_charset!(absolute_path("huge_file_with_one_special_character.csv")))
    puts "took #{Time.now - t1} seconds"
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
  
  def test_collect_special_characters_is_empty_when_there_are_no_special_characters
    assert_special_chars_equal("", "")
    assert_special_chars_equal("", "hello")
    assert_special_chars_equal("", "12345678901234567890")
  end
  
  def test_collect_special_characters_returns_characters_with_context
    assert_special_chars_equal("µ", "µ")
    assert_special_chars_equal("321µ123", "321µ123")
    assert_special_chars_equal("µ123", "µ123")
    assert_special_chars_equal("321µ", "321µ")
    assert_special_chars_equal("0987654321\xC21234567890", "0987654321\xC21234567890")
    assert_special_chars_equal("0987654321µ1234567890", "XXX0987654321µ1234567890XXX")
    assert_special_chars_equal("µ1234567890", "µ1234567890XXX")
    assert_special_chars_equal("0987654321µ", "XXX0987654321µ")
  end
    
  def test_collect_special_characters_does_not_duplicate_context
    assert_special_chars_equal("0987654321µaaaaaµ1234567890", "XXX0987654321µaaaaaµ1234567890XXX")
  end
  
  def test_collect_special_characters_works_with_multiple_characters
    assert_special_chars_equal(
      "0987654321µaaaaaµ12345678900987654321µ1234567890", 
      "XXX0987654321µaaaaaµ1234567890XXXXXX0987654321µ1234567890XXX"
    )
  end
  
  def test_collect_special_characters_works_when_reading_multiple_chunks_to_the_buffer
    default_chunk_size = 2 ** 15
    assert_equal(default_chunk_size, Magic::CHUNK_SIZE)
    begin
      Magic.send(:remove_const, "CHUNK_SIZE")
      Magic.send(:const_set, "CHUNK_SIZE", 2)
      assert_special_chars_equal("µ", "µ")
      assert_special_chars_equal("µ123", "µ123")
      assert_special_chars_equal("321µ", "321µ")
      assert_special_chars_equal("321µ123", "321µ123")
      assert_special_chars_equal("0987654321µ", "XXX0987654321µ")
      assert_special_chars_equal(
        "0987654321µaaaaaµ12345678900987654321µ1234567890",
        "XXX0987654321µaaaaaµ1234567890XXXXXX0987654321µ1234567890XXX"
      )
    ensure
      Magic.send(:remove_const, "CHUNK_SIZE") if Magic.const_defined?("CHUNK_SIZE")
      Magic.const_set("CHUNK_SIZE", default_chunk_size)
    end
    assert_equal(default_chunk_size, Magic::CHUNK_SIZE)
  end
  
  def assert_special_chars_equal(expected_output, input)
    assert_equal(expected_output.force_encoding(Encoding::BINARY), Magic.send(:collect_special_characters, StringIO.new(input)))
  end
  
  def absolute_path(test_file_name)
    "#{ENV["PWD"]}/test/files/#{test_file_name}"
  end
end
