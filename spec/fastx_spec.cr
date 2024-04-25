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
      s.starts_with?(
        ["CGCAACCCGACTCGAGGCACAGATCCGGTAGCGTTACGAGTAATCAGAGGAAATGGTTTTCGC",
         "TGAGAGCTAAACTAGACTTAACCGTCGCCTCTACCATACGGGCGCGCTGGGCGGGCCTAAGTT",
        ][c]).should be_true
      s.ends_with?(
        ["GCCGGTTATCACTTTATGGGGCGTGCTGGAGTTGTCAACATCC",
         "AACCTGAAGGTAAATGCCCCCCGCCTCTACCGGGCAGGGACACTAGCAGTGCCAAACGTTTGC",
        ][c]).should be_true
      c += 1
    end
    reader.close
  end
end
