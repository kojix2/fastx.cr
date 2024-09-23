require "./spec_helper"

describe Fastx::Fastq::Reader do
  it "should read a fastq file" do
    reader = Fastx::Fastq::Reader.new(Path[__DIR__, "fixtures/moo.fq"])
    c = 0
    reader.each do |id, sequence, quality|
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
