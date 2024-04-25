require "../exceptions"
require "compress/gzip"

module Fastx
  module Fasta
    class Writer
      @filename : Path
      @gzip : Bool
      @file : File

      def self.open(filename : String | Path)
        reader = self.new(filename)
        yield reader
      ensure
        reader.try &.close
      end

      def initialize(filename : String | Path)
        @filename = Path.new(filename)
        @gzip = @filename.extension == ".gz"
        @file = File.open(filename, "w")
      end

      def close
        @file.close
      end
    end
  end
end
