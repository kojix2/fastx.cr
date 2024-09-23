module Fastx
  class FastxError < Exception
  end

  class InvalidCharacterError < FastxError
    def initialize(filename, name, sequence)
      msg = <<-ERROR
      Non-ASCII characters in FASTA file: #{filename}
        #{name}
        #{sequence}
      ERROR
      super(msg)
    end
  end

  class InvalidFormatError < FastxError
    def initialize(filename, idx, line, message = nil)
      msg = <<-ERROR
      Invalid Format: #{filename}:#{idx}
        #{line}
      #{message}
      ERROR
      super(msg)
    end
  end
end
