# Fastx.cr

[![test](https://github.com/kojix2/fastx.cr/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/fastx.cr/actions/workflows/ci.yml)

I hope that in the future this library will be able to read and write FASTA and FASTQ, but currently it can only read FASTA.

**NOTE:** Currently the standard Crystal library does not open bgzip well; it can only handle gzip files.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     fastx:
       github: kojix2/fastx.cr
   ```

2. Run `shards install`

## Usage

```crystal
# Create a Reader instance for your FASTA file
reader = Fastx::Fasta::Reader.new("path_to_your_file.fa")

# Go through each sequence in the file
reader.each do |name, sequence|
  puts "Name: #{name}"
  puts "Sequence: #{sequence.to_s}"
end

# Always remember to close the reader
reader.close
```

High-level API

```crystal
Fastx.open("path_to_your_file.fa") do |reader|
  reader.as(Fastx::Fasta::Reader) # Necessary in the current situation 
        .each do |name, sequence|
    puts "Name: #{name}"
    puts "Sequence: #{sequence.to_s}"
  end
end
```

## Development

This library is in development.

## Contributing

1. Fork it (<https://github.com/kojix2/fastx/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
