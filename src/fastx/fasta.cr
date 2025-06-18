require "./fasta/reader"
require "./fasta/writer"

module Fastx
  module Fasta
    # Opens a FASTA file for reading ("r") or writing ("w").
    # Yields the Reader/Writer to the block and automatically closes it.
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

    # Opens a FASTA file for reading ("r") or writing ("w").
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
end
