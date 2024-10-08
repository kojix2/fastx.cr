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
end
