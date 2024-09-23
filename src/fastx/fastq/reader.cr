require "../exceptions"
require "compress/gzip"

module Fastx
  module Fastq
    class Reader
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
        @gzip = filename.extension == ".gz"
        @file = File.open(filename)
      end

      def each
        file = @gzip ? Compress::Gzip::Reader.new(@file) : @file
        return if file.nil?

        identifier = nil
        sequence = IO::Memory.new
        quality = IO::Memory.new

        next_field = FIELD::IDENTIFIER

        file.each_line.with_index do |line, idx|
          case next_field
          when FIELD::IDENTIFIER
            unless line.starts_with?("@")
              raise InvalidFormatError.new(@filename, idx, line, "Identifier line must start with '@'")
            end

            yield(identifier, sequence, quality) unless identifier.nil?
            # Remove ">" and newline but is it ok on Windows? CR+LF?
            identifier = line[1..-1]
            # Try to reuse sequence buffer to avoid memory allocation.
            # But not clear if it's a good idea.
            # Parhaps it's better to implement a copy mode as well.
            sequence.clear
            quality.clear
            next_field = FIELD::SEQUENCE
          when FIELD::SEQUENCE
            unless line.ascii_only?
              raise InvalidCharacterError.new(@filename, identifier, sequence)
            end
            sequence.clear
            sequence << line
            next_field = FIELD::PLUS
          when FIELD::PLUS
            unless line.starts_with?("+")
              raise InvalidFormatError.new(@filename, idx, line, "Plus line must start with '+'")
            end
            next_field = FIELD::QUALITY
          when FIELD::QUALITY
            unless line.ascii_only?
              raise InvalidCharacterError.new(@filename, identifier, sequence)
            end
            quality.clear
            quality << line
            next_field = FIELD::IDENTIFIER
          end
        end

        unless identifier.nil?
          yield(identifier, sequence, quality) unless identifier.nil?
          sequence.clear
          quality.clear
        end

        file.close if file.is_a?(Compress::Gzip::Reader)
      end

      def close
        @file.close
      end
    end
  end
end
