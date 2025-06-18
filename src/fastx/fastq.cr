require "./fastq/reader"
require "./fastq/writer"

module Fastx
  module Fastq
    # FASTQ record field types for parsing state machine.
    enum FIELD : UInt8
      IDENTIFIER = 0
      SEQUENCE   = 1
      PLUS       = 2
      QUALITY    = 3
    end

    # Opens a FASTQ file for reading ("r") or writing ("w").
    # Yields the Reader/Writer to the block and automatically closes it.
    def self.open(filename, mode = "r", &) # block given
      case mode
      when "r"
        Reader.open(filename) { |reader| yield reader }
      when "w"
        Writer.open(filename) { |writer| yield writer }
      else
        raise ArgumentError.new("Invalid mode: #{mode}")
      end
    end

    # Opens a FASTQ file for reading ("r") or writing ("w").
    # Returns the Reader/Writer instance (manual close required).
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

  # Converts a quality string to an array of Phred scores.
  def self.encode_phred(quality : String, offset = 33) : Array(Int32)
    quality.chars.map { |c| c.ord - offset }
  end

  # Converts an array of Phred scores to a quality string.
  def self.decode_phred(scores : Enumerable(Int32), offset = 33) : String
    scores.map { |s| (s + offset).chr }.join
  end
end
