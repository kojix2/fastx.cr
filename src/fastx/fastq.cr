require "./fastq/reader"
require "./fastq/writer"

module Fastx
  module Fastq
    enum FIELD : UInt8
      IDENTIFIER = 0
      SEQUENCE   = 1
      PLUS       = 2
      QUALITY    = 3
    end

    def self.open(filename, mode = "r") # block given
      case mode
      when "r"
        Reader.open(filename) { |reader| yield reader }
      when "w"
        Writer.open(filename) { |writer| yield writer }
      else
        raise ArgumentError.new("Invalid mode: #{mode}")
      end
    end

    def self.open(filename, mode = "r")
      case mode
      when "r"
        Reader.new(filename)
      when "w"
        Writer.new(filename)
      else
        raise ArgumentError.new("Invalid mode: #{mode}")
      end
    end
  end
end
