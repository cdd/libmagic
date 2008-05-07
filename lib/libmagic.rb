require "libmagic_wrapper"

class Magic
  REGEX = /charset=(.+)$/
  def self.file_charset(filename)
    if match = REGEX.match(file_mime_type(filename))
      return match[1]
    else
      return nil
    end
  end
end
