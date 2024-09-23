require "../src/fastx"

if ARGV.size != 1
  STDERR.puts("Usage: #{PROGRAM_NAME} <fastq>")
  exit 1
end

fname = ARGV[0]

true_count = 0
false_count = 0

Fastx::Fastq::Reader.open(fname) do |reader|
  reader.each do |name, sequence, quality|
    sequence_size = sequence.size
    quality_size = quality.size
    count_check = sequence_size == quality_size
    count_check ? (true_count += 1) : (false_count += 1)
    puts "#{name}\t#{sequence.size}\t#{quality.size}\t#{count_check}"
  end
end

STDERR.puts("True: #{true_count}\tFalse: #{false_count}")
