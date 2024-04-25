# Fastx.cr

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
require "fastx"
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/kojix2/fastx/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
