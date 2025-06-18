require "./fastx/version"
require "./fastx/format"
require "./fastx/fasta"
require "./fastx/fastq"

module Fastx
  # Opens a FASTA/FASTQ file with automatic format detection or explicit format.
  # Yields the appropriate Reader/Writer to the block and automatically closes it.
  def self.open(filename : Path | String, mode = "r", format : Format? = nil, &) # block given
    case format
    when Format::FASTQ
      Fastq.open(filename, mode) { |f| yield f }
    when Format::FASTA
      Fasta.open(filename, mode) { |f| yield f }
    else
      case filename.to_s
      when /\.fastq$/, /\.fq$/, /\.fastq.gz$/, /\.fq.gz$/
        Fastq.open(filename, mode) { |f| yield f }
      when /\.fasta$/, /\.fa$/, /\.fasta.gz$/, /\.fa.gz$/
        Fasta.open(filename, mode) { |f| yield f }
      else
        raise ArgumentError.new("Unknown format: #{filename}")
      end
    end
  end

  # Opens a FASTA/FASTQ file with automatic format detection or explicit format.
  # Returns the appropriate Reader/Writer instance (manual close required).
  def self.open(filename : Path | String, mode = "r", format : Format? = nil)
    case format
    when Format::FASTQ
      Fastq.open(filename, mode)
    when Format::FASTA
      Fasta.open(filename, mode)
    else
      case filename.to_s
      when /\.fastq$/, /\.fq$/, /\.fastq.gz$/, /\.fq.gz$/
        Fastq.open(filename, mode)
      when /\.fasta$/, /\.fa$/, /\.fasta.gz$/, /\.fa.gz$/
        Fasta.open(filename, mode)
      else
        raise ArgumentError.new("Unknown format: #{filename}")
      end
    end
  end

  # Normalizes a single base character to uppercase ACGTN.
  # Non-ACGTN characters are converted to N (78u8).
  def self.normalize_base(c : UInt8) : UInt8
    case c
    when 65u8, 97u8  then 65u8 # A
    when 67u8, 99u8  then 67u8 # C
    when 71u8, 103u8 then 71u8 # G
    when 84u8, 116u8 then 84u8 # T
    when 78u8, 110u8 then 78u8 # N
    else
      STDERR.puts "'#{c.chr}' is replaced with 'N'"
      78u8 # N
    end
  end

  # Converts a DNA sequence (String or IO::Memory) to a UInt8 slice,
  # where each base is encoded as a single byte (A, C, G, T, N → 65, 67, 71, 84, 78; others → 78).
  # This representation is suitable for SIMD or byte-wise processing.
  def self.encode_bases(sequence : IO::Memory | String) : Slice(UInt8)
    sequence.to_slice.map do |c|
      normalize_base(c)
    end
  end
end
