require "../exceptions"
require "compress/gzip"

module Fastx
  module Fasta
    class Reader
      @filename : Path
      @gzip : Bool
      @file : File

      # Opens a FASTA file, yields the reader to the block, and automatically closes it.
      def self.open(filename : String | Path, &)
        reader = self.new(filename)
        yield reader
      ensure
        reader.try &.close
      end

      # Creates a new FASTA reader for the specified file.
      # Automatically detects gzip compression from .gz extension.
      def initialize(filename : String | Path)
        @filename = Path.new(filename)
        @gzip = @filename.extension == ".gz"
        @file = File.open(filename)
      end

      # Iterates over each FASTA record, yielding name and sequence.
      def each(&)
        file = @gzip ? Compress::Gzip::Reader.new(@file) : @file
        return if file.nil?

        name = nil
        sequence = IO::Memory.new

        file.each_line do |line|
          if line.starts_with?(">")
            yield name, sequence unless name.nil?
            # Remove ">" and newline but is it ok on Windows? CR+LF?
            name = line[1..-1]
            # Try to reuse sequence buffer to avoid memory allocation.
            # But not clear if it's a good idea.
            # Parhaps it's better to implement a copy mode as well.
            sequence.clear
          else
            # Check for invalid characters
            if !line.ascii_only?
              raise InvalidCharacterError.new(@filename, name, sequence)
            end
            sequence << line
          end
        end
        yield name, sequence unless name.nil?

        file.close if file.is_a?(Compress::Gzip::Reader)
      end

      # Iterates over each FASTA record, yielding name and sequence as String copies.
      # This avoids buffer reuse issues when references to sequence data are kept.
      def each_copy(&)
        file = @gzip ? Compress::Gzip::Reader.new(@file) : @file
        return if file.nil?

        name = nil
        sequence = IO::Memory.new

        file.each_line do |line|
          if line.starts_with?(">")
            yield name, sequence.to_s unless name.nil?
            # Remove ">" and newline but is it ok on Windows? CR+LF?
            name = line[1..-1]
            sequence.clear
          else
            # Check for invalid characters
            if !line.ascii_only?
              raise InvalidCharacterError.new(@filename, name, sequence)
            end
            sequence << line
          end
        end
        yield name, sequence.to_s unless name.nil?

        file.close if file.is_a?(Compress::Gzip::Reader)
      end

      # Closes the file handle.
      def close
        @file.close
      end

      # Returns true if the file handle is closed.
      def closed?
        @file.closed?
      end
    end
  end
end
