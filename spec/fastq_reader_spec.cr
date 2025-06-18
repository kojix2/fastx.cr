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
    reader.close
  end

  it "should open a fastq file with block" do
    Fastx::Fastq::Reader.open(Path[__DIR__, "fixtures/moo.fq"]) do |reader|
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

  it "should raise InvalidFormatError for invalid identifier line" do
    tempfile = File.tempfile("invalid.fq")
    File.write(tempfile.path, "invalid_identifier\nACGT\n+\n!!!!\n")

    reader = Fastx::Fastq::Reader.new(tempfile.path)
    expect_raises(Fastx::InvalidFormatError) do
      reader.each do |id, sequence, quality|
        # This should raise an exception
      end
    end
    reader.close
    tempfile.delete
  end

  it "should raise InvalidFormatError for invalid plus line" do
    tempfile = File.tempfile("invalid.fq")
    File.write(tempfile.path, "@test\nACGT\ninvalid_plus\n!!!!\n")

    reader = Fastx::Fastq::Reader.new(tempfile.path)
    expect_raises(Fastx::InvalidFormatError) do
      reader.each do |id, sequence, quality|
        # This should raise an exception
      end
    end
    reader.close
    tempfile.delete
  end

  it "should raise InvalidCharacterError for non-ASCII characters in sequence" do
    tempfile = File.tempfile("invalid.fq")
    File.write(tempfile.path, "@test\nACGT\u{1F600}ACGT\n+\n!!!!!!!\n")

    reader = Fastx::Fastq::Reader.new(tempfile.path)
    expect_raises(Fastx::InvalidCharacterError) do
      reader.each do |id, sequence, quality|
        # This should raise an exception
      end
    end
    reader.close
    tempfile.delete
  end

  it "should raise InvalidCharacterError for non-ASCII characters in quality" do
    tempfile = File.tempfile("invalid.fq")
    File.write(tempfile.path, "@test\nACGTACGT\n+\n!!!\u{1F600}!!!\n")

    reader = Fastx::Fastq::Reader.new(tempfile.path)
    expect_raises(Fastx::InvalidCharacterError) do
      reader.each do |id, sequence, quality|
        # This should raise an exception
      end
    end
    reader.close
    tempfile.delete
  end
end
