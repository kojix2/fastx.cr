module Fastx
  module Fastq
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

      def closed?
        @file.closed?
      end
    end
  end
end
