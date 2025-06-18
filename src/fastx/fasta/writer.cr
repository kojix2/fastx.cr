require "../exceptions"
require "compress/gzip"

module Fastx
  module Fasta
    class Writer
      @filename : Path
      @gzip : Bool
      @file : File
      @writer : File | Compress::Gzip::Writer

      def self.open(filename : String | Path, &)
        writer = self.new(filename)
        yield writer
      ensure
        writer.try &.close
      end

      def initialize(filename : String | Path)
        @filename = Path.new(filename)
        @gzip = @filename.extension == ".gz"
        @file = File.open(filename, "w")
        @writer = @gzip ? Compress::Gzip::Writer.new(@file) : @file
      end

      def write(name : String, sequence : String)
        @writer.puts(">#{name}")
        @writer.puts(sequence)
      end

      def close
        if @writer.is_a?(Compress::Gzip::Writer)
          @writer.close
        end
        @file.close
      end

      def closed?
        @file.closed?
      end
    end
  end
end
