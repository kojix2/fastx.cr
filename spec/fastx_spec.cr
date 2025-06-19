require "./spec_helper"

describe Fastx do
  it "has a version number" do
    (Fastx::VERSION).should be_a(String)
  end

  it "should open a fasta file" do
    reader = Fastx.open(Path[__DIR__, "fixtures/moo.fa"], "r")
    c = 0
    reader.as(Fastx::Fasta::Reader).each do |name, sequence|
      name.should eq ["chr1 1", "chr2 2"][c]
      sequence.size.should eq [1000, 900][c]
      s = sequence.to_s
      s.starts_with?([CHR1_START, CHR2_START][c]).should be_true
      s.ends_with?([CHR1_END, CHR2_END][c]).should be_true
      c += 1
    end
    reader.close
  end

  it "should open a fasta file with block" do
    Fastx.open(Path[__DIR__, "fixtures/moo.fa"], "r") do |reader|
      c = 0
      reader.as(Fastx::Fasta::Reader).each do |name, sequence|
        name.should eq ["chr1 1", "chr2 2"][c]
        sequence.size.should eq [1000, 900][c]
        s = sequence.to_s
        s.starts_with?([CHR1_START, CHR2_START][c]).should be_true
        s.ends_with?([CHR1_END, CHR2_END][c]).should be_true
        c += 1
      end
    end
  end

  it "should open a fastq file" do
    reader = Fastx.open(Path[__DIR__, "fixtures/moo.fq"], "r")
    c = 0
    reader.as(Fastx::Fastq::Reader).each do |id, sequence, quality|
      id.should eq ["chr1_106_509:0/1", "chr1_437_492:1/1"][c]
      sequence.size.should eq 100
      quality.size.should eq 100
      s = sequence.to_s
      s.should eq [FQ_SEQ_1, FQ_SEQ_2][c]
      q = quality.to_s
      q.should eq [FQ_QUAL_1, FQ_QUAL_2][c]
      c += 1
    end
  end

  it "should open a fastq file with a block" do
    Fastx.open(Path[__DIR__, "fixtures/moo.fq"], "r") do |reader|
      c = 0
      reader.as(Fastx::Fastq::Reader).each do |id, sequence, quality|
        id.should eq ["chr1_106_509:0/1", "chr1_437_492:1/1"][c]
        sequence.size.should eq 100
        quality.size.should eq 100
        s = sequence.to_s
        s.should eq [FQ_SEQ_1, FQ_SEQ_2][c]
        q = quality.to_s
        q.should eq [FQ_QUAL_1, FQ_QUAL_2][c]
        c += 1
      end
    end
  end

  it "should write a fasta file" do
    tempfile = File.tempfile("quack.fa")
    writer = Fastx.open(tempfile.path, "w").as(Fastx::Fasta::Writer)
    writer.write("chr1 1", "A" * 10)
    writer.write("chr2 2", "C" * 9)
    writer.close
    File.read(tempfile.path)
      .should eq(">chr1 1\nAAAAAAAAAA\n>chr2 2\nCCCCCCCCC\n")
    tempfile.delete
  end

  it "should write a fastq file" do
    tempfile = File.tempfile("quack.fq")
    writer = Fastx.open(tempfile.path, "w").as(Fastx::Fastq::Writer)
    writer.write("chr1_106_509:0/1", "A" * 10, "5" * 10)
    writer.write("chr2_437_492:1/1", "C" * 9, "!" * 9)
    writer.close
    File.read(tempfile.path)
      .should eq("@chr1_106_509:0/1\nAAAAAAAAAA\n+\n5555555555\n@chr2_437_492:1/1\nCCCCCCCCC\n+\n!!!!!!!!!\n")
    tempfile.delete
  end

  it "should open file with format specification" do
    tempfile = File.tempfile("test_file")

    # Write as FASTA using format parameter
    Fastx.open(tempfile.path, "w", Fastx::Format::FASTA) do |writer|
      writer.as(Fastx::Fasta::Writer).write("test", "ACGT")
    end

    # Read as FASTA using format parameter
    Fastx.open(tempfile.path, "r", Fastx::Format::FASTA) do |reader|
      reader.as(Fastx::Fasta::Reader).each do |name, sequence|
        name.should eq "test"
        sequence.to_s.should eq "ACGT"
      end
    end

    tempfile.delete
  end

  it "should raise ArgumentError for unknown format" do
    expect_raises(ArgumentError, "Unknown format: unknown_file.xyz") do
      Fastx.open("unknown_file.xyz", "r")
    end
  end

  it "should normalize base characters" do
    Fastx.normalize_base(65u8).should eq 65u8  # A
    Fastx.normalize_base(97u8).should eq 65u8  # a -> A
    Fastx.normalize_base(67u8).should eq 67u8  # C
    Fastx.normalize_base(99u8).should eq 67u8  # c -> C
    Fastx.normalize_base(71u8).should eq 71u8  # G
    Fastx.normalize_base(103u8).should eq 71u8 # g -> G
    Fastx.normalize_base(84u8).should eq 84u8  # T
    Fastx.normalize_base(116u8).should eq 84u8 # t -> T
    Fastx.normalize_base(78u8).should eq 78u8  # N
    Fastx.normalize_base(110u8).should eq 78u8 # n -> N
    Fastx.normalize_base(88u8).should eq 78u8  # X -> N (unknown)
  end

  it "should encode bases" do
    result = Fastx.encode_bases("AcGtN")
    result.should eq Slice[65u8, 67u8, 71u8, 84u8, 78u8] # ACGTN
  end

  it "should decode bases" do
    result = Fastx.decode_bases([65u8, 67u8, 71u8, 84u8, 78u8])
    result.should eq "ACGTN"
  end

  it "should encode and decode phred scores (default offset 33)" do
    quality = "IIIIHGF"
    scores = Fastx.encode_phred(quality)
    scores.should eq [40_u8, 40_u8, 40_u8, 40_u8, 39_u8, 38_u8, 37_u8]
    decoded = Fastx.decode_phred(scores)
    decoded.should eq quality
  end

  it "should encode and decode phred scores with offset 64" do
    quality = "dddd"
    scores = Fastx.encode_phred(quality, offset: 64)
    scores.should eq [36_u8, 36_u8, 36_u8, 36_u8]
    decoded = Fastx.decode_phred(scores, offset: 64)
    decoded.should eq quality
  end

  it "should work with Format enum for FASTQ" do
    tempfile = File.tempfile("test_file")

    # Write as FASTQ using format parameter
    Fastx.open(tempfile.path, "w", Fastx::Format::FASTQ) do |writer|
      writer.as(Fastx::Fastq::Writer).write("test", "ACGT", "!!!!")
    end

    # Read as FASTQ using format parameter
    Fastx.open(tempfile.path, "r", Fastx::Format::FASTQ) do |reader|
      reader.as(Fastx::Fastq::Reader).each do |id, sequence, quality|
        id.should eq "test"
        sequence.to_s.should eq "ACGT"
        quality.to_s.should eq "!!!!"
      end
    end

    tempfile.delete
  end
end
