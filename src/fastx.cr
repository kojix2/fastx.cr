require "./fastx/version"
require "./fastx/fasta"
require "./fastx/fastq"

module Fastx
  def self.open(filename : Path | String, mode = "r", format = nil) # block given
    case File
    when /\.fastq$/, /\.fq$/, /\.fastq.gz$/, /\.fq.gz$/
      Fastq.open(filename, mode) { |f| yield f }
    when /\.fasta$/, /\.fa$/, /\.fasta.gz$/, /\.fa.gz$/
      Fasta.open(filename, mode) { |f| yield f }
    when format == "fastq"
      Fastq.open(filename, mode) { |f| yield f }
    when format == "fasta"
      Fasta.open(filename, mode) { |f| yield f }
    else
      raise ArgumentError.new("Unknown format: #{filename}")
    end
  end

  def self.open(filename : Path | String, mode = "r", format = nil)
    case filename.to_s
    when /\.fastq$/, /\.fq$/, /\.fastq.gz$/, /\.fq.gz$/
      Fastq.open(filename, mode)
    when /\.fasta$/, /\.fa$/, /\.fasta.gz$/, /\.fa.gz$/
      Fasta.open(filename, mode)
    when format == "fastq"
      Fastq.open(filename, mode)
    when format == "fasta"
      Fasta.open(filename, mode)
    else
      raise ArgumentError.new("Unknown format: #{filename}")
    end
  end
end
