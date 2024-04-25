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
end
