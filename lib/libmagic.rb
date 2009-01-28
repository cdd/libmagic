require "libmagic_wrapper"

class Magic
  VERSION = '0.4.1'
  
  REGEX = /charset=(.+)$/
  class << self
    def file_charset(filename)
      mime_type_to_charset(file_mime_type(filename))
    end
    
    # Exhaustively checks file contents. The plan is you should always be able to trust the answer this method returns.
    def file_charset!(filename)
      quick_answer = file_charset(filename)
      
      if quick_answer == "us-ascii"
        # try harder
        File.open(filename) do |io|
          special_characters = collect_special_characters(io)
          return string_charset(special_characters) unless special_characters.empty?
        end
      end
      
      return quick_answer
    end
    
    EXTENDED_ASCII_CHARSET = "unknown" # currently libmagic doesn't distinguish the various extended ASCII charsets except ISO-8859-1
    def string_charset(text)
      text.each_byte { |byte| return "unknown" if byte == PROBLEMATIC_EXTENDED_ASCII_CHAR }
      mime_type_to_charset(string_mime_type(text))
    end
    
    private
    EXHAUSTIVE_CHECK_CACHE_SIZE = 10
    LAST_ASCII_CHAR = 127
    PROBLEMATIC_EXTENDED_ASCII_CHAR = 133 # windows-1252 ellipsis
    def collect_special_characters(io)
      cache = create_cache
      special_characters = ""
      
      while char = io.read(1)
        cache << char
        
        if char[0] > LAST_ASCII_CHAR
          # give the special character context
          special_characters << cache.join
          special_characters << io.read(EXHAUSTIVE_CHECK_CACHE_SIZE).to_s # could be nil, hence #to_s
          cache.reset
        end
      end
      
      return special_characters
    end
    
    def create_cache
      cache = []
      class << cache
        alias_method :standard_append, :<<
        def <<(element)
          standard_append(element)
          shift if self.size > EXHAUSTIVE_CHECK_CACHE_SIZE
          return self
        end
        
        def reset
          delete_if { true }
        end
      end
      return cache
    end
    
    def mime_type_to_charset(mime_type)
      if match = REGEX.match(mime_type)
        return match[1]
      else
        return nil
      end
    end
  end
end
