require "./fastq/reader"
require "./fastq/writer"

module Fastx
  module Fastq
    def self.open(filename, mode = "r")
      if mode == "r"
        Reader.new(filename)
      elsif mode == "w"
        Writer.new(filename)
      else
        raise ArugmentError.new("Invalid mode: #{mode}")
      end
    end
  end
end
