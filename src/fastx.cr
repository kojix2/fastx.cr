require "./fastx/version"
require "./fastx/fasta"
require "./fastx/fastq"

module Fastx
  def self.open(filename : Path | String, mode = "r", format = nil)
    case File
    when /\.fastq$/, /\.fq$/, /\.fastq.gz$/, /\.fq.gz$/
      Fastq.open(filename, mode)
    when /\.fasta$/, /\.fa$/, /\.fasta.gz$/, /\.fa.gz$/
      Fasta.open(filename, mode)
    when format == "fastq"
      Fastq.open(filename, mode)
    when format == "fasta"
      Fasta.open(filename, mode)
    else
      raise ArgumentError, "Unknown format: #{filename}"
    end
  end
end
