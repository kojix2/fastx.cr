require "./fastx/version"
require "./fastx/fasta"
require "./fastx/fastq"

module Fastx
  def self.open(filename : Path | String, mode = "r", format = nil, &) # block given
    case format
    when "fastq"
      Fastq.open(filename, mode) { |f| yield f }
    when "fasta"
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

  def self.open(filename : Path | String, mode = "r", format = nil)
    case format
    when "fastq"
      Fastq.open(filename, mode)
    when "fasta"
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

  # Experimental
  # FIXME: Other than ACGTN are replaced with N but FASTA format allows other characters

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

  # Experimental

  def self.normalize_sequence(sequence : IO::Memory | String) : Slice(UInt8)
    sequence.to_slice.map do |c|
      normalize_base(c)
    end
  end

  # Experimental

  def self.normalize_sequence(sequence : IO::Memory | String, &) : Slice
    sequence.to_slice.map do |c|
      yield normalize_base(c)
    end
  end
end
