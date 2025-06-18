require "../exceptions"
require "compress/gzip"

module Fastx
  module Fastq
    class Writer
      @filename : Path
      @gzip : Bool
      @file : File
      @writer : File | Compress::Gzip::Writer

      # Opens a FASTQ file for writing, yields the writer to the block, and automatically closes it.
      def self.open(filename : String | Path, &)
        writer = self.new(filename)
        yield writer
      ensure
        writer.try &.close
      end

      # Creates a new FASTQ writer for the specified file.
      # Automatically detects gzip compression from .gz extension.
      def initialize(filename : String | Path)
        @filename = Path.new(filename)
        @gzip = @filename.extension == ".gz"
        @file = File.open(filename, "w")
        @writer = @gzip ? Compress::Gzip::Writer.new(@file) : @file
      end

      # Writes a FASTQ record with the given identifier, sequence, and quality.
      def write(identifier : String, sequence : String, quality : String)
        @writer.puts("@#{identifier}")
        @writer.puts(sequence)
        @writer.puts("+")
        @writer.puts(quality)
      end

      # Closes the file handle.
      def close
        if @writer.is_a?(Compress::Gzip::Writer)
          @writer.close
        end
        @file.close
      end

      # Returns true if the file handle is closed.
      def closed?
        @file.closed?
      end
    end
  end
end
