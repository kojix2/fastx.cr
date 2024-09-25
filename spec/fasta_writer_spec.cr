require "./spec_helper"

describe Fastx::Fasta::Writer do
  it "should wirte a fasta file" do
    tempfile = File.tempfile("quack.fa")
    writer = Fastx::Fasta::Writer.new(tempfile.path)
    writer.write("chr1 1", "A" * 10)
    writer.write("chr2 2", "C" * 9)
    writer.closed?.should be_false
    writer.close
    writer.closed?.should be_true
    File.read(tempfile.path)
      .should eq(">chr1 1\nAAAAAAAAAA\n>chr2 2\nCCCCCCCCC\n")
    tempfile.delete
  end

  it "should write a fasta file with a block" do
    tempfile = File.tempfile("quack.fa")
    Fastx::Fasta::Writer.open(tempfile.path) do |writer|
      writer.write("chr1 1", "A" * 10)
      writer.write("chr2 2", "C" * 9)
    end
    File.read(tempfile.path)
      .should eq(">chr1 1\nAAAAAAAAAA\n>chr2 2\nCCCCCCCCC\n")
    tempfile.delete
  end
end
