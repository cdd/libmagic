require 'ffi'

module Magic
  VERSION = '0.5.7'
  ASCII_CHARSET = "us-ascii"
  # currently libmagic doesn't distinguish the various extended ASCII charsets except ISO-8859-1
  EXTENDED_ASCII_CHARSET = "unknown"
  PROBLEMATIC_EXTENDED_ASCII_CHAR = 133 # windows-1252 ellipsis
  REGEX = /charset=(.+)$/
  
  class << self
    def file_charset(filename)
      mime_type_to_charset(file_mime_type(filename))
    end
    
    # Exhaustively checks file contents. The plan is you should always be able to trust the answer this method returns.
    def file_charset!(filename)
      quick_answer = file_charset(filename)
      
      if quick_answer == ASCII_CHARSET
        return File.open(filename) { |io| io_charset(io) } # try harder
      else
        return quick_answer
      end
    end
    
    def io_charset(io)
      io.rewind
      special_characters = collect_special_characters(io)
      return special_characters.empty? ? ASCII_CHARSET : string_charset(special_characters)
    ensure
      io.rewind
    end
    
    def string_charset(text)
      quick_answer = mime_type_to_charset(string_mime_type(text))
      if quick_answer == ASCII_CHARSET
        text.each_byte { |byte| return EXTENDED_ASCII_CHARSET if byte == PROBLEMATIC_EXTENDED_ASCII_CHAR }
      end
      return quick_answer
    end
    
    private
    CONTEXT_SIZE = 10
    LAST_ASCII_CHAR = 127
    CHUNK_SIZE = 2 ** 15
    def collect_special_characters(io)
      special_characters_with_context = ""
      content = io.read
      # buffer = io.read(CHUNK_SIZE)
      
      leading_index = trailing_index = 0
      last_detection = nil
      
      while leading_index < content.bytesize do
        byte = content.getbyte(leading_index)
        if byte > LAST_ASCII_CHAR
          last_detection = leading_index
        end
        
        if last_detection.nil?
          # Advance the trailing index if it we haven't seen a non-ascii byte and the trailing index is CONTEXT_SIZE bytes behind
          if trailing_index == leading_index - CONTEXT_SIZE
            trailing_index += 1
          end
        else
          if last_detection < (leading_index - CONTEXT_SIZE)
            # It has been CONTEXT_SIZE bytes since the last non-ascii character, so we should write this chunk to the results
            special_characters_with_context << content.byteslice(trailing_index...leading_index)
            trailing_index = leading_index + 1 # Just think of it as trailing_index = "leading_index's value at the end of the loop"
            last_detection = nil
          end
        end
        
        leading_index += 1
      end
      
      # Deal with leftovers, if present
      if last_detection
        special_characters_with_context << content.byteslice(trailing_index, leading_index)
      end
      
      return special_characters_with_context
    end
    
    def mime_type_to_charset(mime_type)
      if match = REGEX.match(mime_type)
        return standardize_charset(match[1])
      else
        return nil
      end
    end
    
    # file returns different things in different versions
    def standardize_charset(nonstandard)
      case nonstandard
      when "unknown-8bit"
        "unknown"
      else
        nonstandard
      end
    end
  end
end

# Just to make things neater, split out the FFI part here
module Magic
  extend FFI::Library
  
  ffi_lib "magic" # you might need to set your LD_LIBRARY_PATH on OS X if you're using MacPorts
  
  private
  MAGIC_NONE =              0x000000 # No flags
  MAGIC_DEBUG =             0x000001 # Turn on debugging
  MAGIC_SYMLINK =           0x000002 # Follow symlinks
  MAGIC_COMPRESS =          0x000004 # Check inside compressed files
  MAGIC_DEVICES =           0x000008 # Look at the contents of devices
  MAGIC_MIME_TYPE =         0x000010 # Return only the MIME type
  MAGIC_CONTINUE =          0x000020 # Return all matches
  MAGIC_CHECK =             0x000040 # Print warnings to stderr
  MAGIC_PRESERVE_ATIME =    0x000080 # Restore access time on exit
  MAGIC_RAW =               0x000100 # Don't translate unprint chars
  MAGIC_ERROR =             0x000200 # Handle ENOENT etc as real errors
  MAGIC_MIME_ENCODING =     0x000400 # Return only the MIME encoding
  MAGIC_MIME =              (MAGIC_MIME_TYPE | MAGIC_MIME_ENCODING)
  MAGIC_NO_CHECK_COMPRESS = 0x001000 # Don't check for compressed files
  MAGIC_NO_CHECK_TAR =      0x002000 # Don't check for tar files
  MAGIC_NO_CHECK_SOFT =     0x004000 # Don't check magic entries
  MAGIC_NO_CHECK_APPTYPE =  0x008000 # Don't check application type
  MAGIC_NO_CHECK_ELF =      0x010000 # Don't check for elf details
  MAGIC_NO_CHECK_ASCII =    0x020000 # Don't check for ascii files
  MAGIC_NO_CHECK_TROFF =    0x040000 # Don't check ascii/troff
  MAGIC_NO_CHECK_TOKENS =   0x100000 # Don't check ascii/tokens
  
  attach_function :magic_open, [:int], :pointer
  attach_function :magic_setflags, [:pointer, :int], :int
  attach_function :magic_load, [:pointer, :pointer], :int
  attach_function :magic_buffer, [:pointer, :pointer, :size_t], :string
  attach_function :magic_file, [:pointer, :string], :string
  attach_function :magic_error, [:pointer], :string
  
  class << self
    def string_mime_type(string)
      cookie = load_cookie
      return process_result(cookie, magic_buffer(cookie, string, string.size))
    end
    
    def file_mime_type(filename)
      cookie = load_cookie
      return process_result(cookie, magic_file(cookie, filename))
    end
    
    private
    def load_cookie
      # MAGIC_NO_CHECK_SOFT is supposed to prevent it from using the magic database, but doesn't seem to work on Linux.
      cookie = magic_open(MAGIC_MIME | MAGIC_ERROR)
      # Instead, we use a custom magic file with one simple entry.
      magic_load(cookie, "#{File.dirname(__FILE__)}/custom-magic")
      return cookie
    end
    
    def process_result(cookie, mime_type)
      return mime_type unless mime_type.nil?
      raise magic_error(cookie)
    end
  end
end
