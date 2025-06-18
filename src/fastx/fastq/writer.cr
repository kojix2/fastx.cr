require "../exceptions"
require "compress/gzip"

module Fastx
  module Fastq
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

      def write(identifier : String, sequence : String, quality : String)
        @writer.puts("@#{identifier}")
        @writer.puts(sequence)
        @writer.puts("+")
        @writer.puts(quality)
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
