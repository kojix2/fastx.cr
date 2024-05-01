require "./spec_helper"

describe Fastx::Fasta::Reader do
  it "should read a fasta file" do
    reader = Fastx::Fasta::Reader.new(Path[__DIR__, "fixtures/moo.fa"])
    c = 0
    reader.each do |name, sequence|
      name.should eq ["chr1 1", "chr2 2"][c]
      sequence.size.should eq [1000, 900][c]
      s = sequence.to_s
      s.starts_with?([CHR1_START, CHR2_START][c]).should be_true
      s.ends_with?([CHR1_END, CHR2_END][c]).should be_true
      c += 1
    end
    reader.close
  end

  it "should read a gzip compressed fasta file" do
    reader = Fastx::Fasta::Reader.new(Path[__DIR__, "fixtures/moo.f.gz"])
    c = 0
    reader.each do |name, sequence|
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
    Fastx::Fasta::Reader.open(Path[__DIR__, "fixtures/moo.fa"]) do |reader|
      c = 0
      reader.each do |name, sequence|
        name.should eq ["chr1 1", "chr2 2"][c]
        sequence.size.should eq [1000, 900][c]
        s = sequence.to_s
        s.starts_with?([CHR1_START, CHR2_START][c]).should be_true
        s.ends_with?([CHR1_END, CHR2_END][c]).should be_true
        c += 1
      end
    end
  end
end
