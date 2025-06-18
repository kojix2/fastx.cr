# Fastx.cr

[![test](https://github.com/bio-cr/fastx.cr/actions/workflows/ci.yml/badge.svg)](https://github.com/bio-cr/fastx.cr/actions/workflows/ci.yml)
[![Docs Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://bio-cr.github.io/fastx.cr/)

A Crystal library for reading and writing FASTA and FASTQ files.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     fastx:
       github: bio-cr/fastx.c
   ```

2. Run `shards install`

## Usage

### Reading FASTA files

```crystal
require "fastx"

# Using Reader directly
reader = Fastx::Fasta::Reader.new("file.fa")
reader.each do |name, sequence|
  puts "Name: #{name}"
  puts "Sequence: #{sequence.to_s}"
end
reader.close

# Using block (automatically closes)
Fastx::Fasta::Reader.open("file.fa") do |reader|
  reader.each do |name, sequence|
    puts "Name: #{name}"
    puts "Sequence: #{sequence.to_s}"
  end
end

# Using each_copy for String copies (avoids buffer reuse issues)
Fastx::Fasta::Reader.open("file.fa") do |reader|
  reader.each_copy do |name, sequence|
    puts "Name: #{name}"
    puts "Sequence: #{sequence}" # sequence is already a String
  end
end
```

### Reading FASTQ files

```crystal
# Using Reader directly
reader = Fastx::Fastq::Reader.new("file.fq")
reader.each do |identifier, sequence, quality|
  puts "ID: #{identifier}"
  puts "Sequence: #{sequence.to_s}"
  puts "Quality: #{quality.to_s}"
end
reader.close

# Using block (automatically closes)
Fastx::Fastq::Reader.open("file.fq") do |reader|
  reader.each do |identifier, sequence, quality|
    puts "ID: #{identifier}"
    puts "Sequence: #{sequence.to_s}"
    puts "Quality: #{quality.to_s}"
  end
end

# Using each_copy for String copies (avoids buffer reuse issues)
Fastx::Fastq::Reader.open("file.fq") do |reader|
  reader.each_copy do |identifier, sequence, quality|
    puts "ID: #{identifier}"
    puts "Sequence: #{sequence}" # sequence is already a String
    puts "Quality: #{quality}"   # quality is already a String
  end
end
```

### Writing FASTA files

```crystal
# Using Writer directly
writer = Fastx::Fasta::Writer.new("output.fa")
writer.write("seq1", "ACGTACGT")
writer.write("seq2", "TGCATGCA")
writer.close

# Using block (automatically closes)
Fastx::Fasta::Writer.open("output.fa") do |writer|
  writer.write("seq1", "ACGTACGT")
  writer.write("seq2", "TGCATGCA")
end
```

### Writing FASTQ files

```crystal
# Using Writer directly
writer = Fastx::Fastq::Writer.new("output.fq")
writer.write("seq1", "ACGTACGT", "!!!!!!!!")
writer.write("seq2", "TGCATGCA", "~~~~~~~~")
writer.close

# Using block (automatically closes)
Fastx::Fastq::Writer.open("output.fq") do |writer|
  writer.write("seq1", "ACGTACGT", "!!!!!!!!")
  writer.write("seq2", "TGCATGCA", "~~~~~~~~")
end
```

### Auto-detection by file extension

```crystal
# Automatically detects format from file extension
Fastx.open("file.fa") do |reader|
  reader.as(Fastx::Fasta::Reader).each do |name, sequence|
    puts "#{name}: #{sequence.to_s}"
  end
end

Fastx.open("file.fq") do |reader|
  reader.as(Fastx::Fastq::Reader).each do |id, sequence, quality|
    puts "#{id}: #{sequence.to_s}"
  end
end
```

### Explicit format specification

```crystal
# Using Format enum for explicit format specification
Fastx.open("data", "r", Fastx::Format::FASTA) do |reader|
  reader.as(Fastx::Fasta::Reader).each do |name, sequence|
    puts "#{name}: #{sequence.to_s}"
  end
end

Fastx.open("output", "w", Fastx::Format::FASTQ) do |writer|
  writer.as(Fastx::Fastq::Writer).write("seq1", "ACGT", "!!!!")
end
```

### Gzip support

Both reading and writing of gzip-compressed files are supported automatically when the filename ends with `.gz`.

```crystal
# Reads gzip-compressed FASTA
Fastx::Fasta::Reader.open("file.fa.gz") do |reader|
  reader.each do |name, sequence|
    puts "#{name}: #{sequence.to_s}"
  end
end

# Writes gzip-compressed FASTQ
Fastx::Fastq::Writer.open("output.fq.gz") do |writer|
  writer.write("seq1", "ACGT", "!!!!")
end
```

### Base encoding

Convert DNA sequences to UInt8 arrays suitable for byte-wise or array processing:

```crystal
# Encode bases to UInt8 array (A,C,G,T,N → 65,67,71,84,78; others → 78)
encoded = Fastx.encode_bases("AcGtNxyz")
# Returns: Slice[65u8, 67u8, 71u8, 84u8, 78u8, 78u8, 78u8, 78u8]

# Decode UInt8 array back to DNA string
decoded = Fastx.decode_bases(encoded)
# Returns: "ACGTNNNN"
```

### Quality encoding

Convert quality strings to Phred score arrays and back:

```crystal
# Encode quality string to Phred scores (Phred+33 by default)
phred_scores = Fastx.encode_phred("IIIIHGF") # => [40, 40, 40, 40, 39, 38, 37]

# Decode Phred scores to quality string
quality_str = Fastx.decode_phred([40, 40, 40, 40, 39, 38, 37]) # => "IIIIHGF"

# Specify offset for Phred+64
phred_scores64 = Fastx.encode_phred("dddd", offset: 64)
quality_str64 = Fastx.decode_phred([36, 36, 36, 36], offset: 64)
```

## Contributing

1. Fork it (<https://github.com/bio-cr/fastx/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

MIT License

This project includes code generated by AI.
