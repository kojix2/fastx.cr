require "./fasta/reader"
require "./fasta/writer"

module Fastx
  module Fasta
    def self.open(filename, mode = "r")
      if mode == "r"
        Reader.new(file)
      elsif mode == "w"
        Writer.new(file)
      else
        raise ArugmentError.new("Invalid mode: #{mode}")
      end
    end
  end
end
