require_relative '../app/performer'

RSpec.describe App::Performer do
  let(:input_stream) { StringIO.new }
  let(:output_stream) { StringIO.new }
  let(:writer_double) { instance_double(App::DatabaseWriter, add: nil, flush: nil) }
  let(:reader_double) { instance_double(App::DatabaseReader, read: nil) }

  before do
    allow(App::DatabaseWriter).to receive(:new).and_return(writer_double)
    allow(App::DatabaseReader).to receive(:new).and_return(reader_double)
  end

  describe "#call" do
    context "with valid input data" do
      let(:input_data) { "2023-01-01,T1,U1,100\n2023-01-02,T2,U2,200\n" }
      let(:input_stream) { StringIO.new(input_data) }
      it "processes all rows and writes sorted output" do
        expect(writer_double).to receive(:add).with(["2023-01-01", "T1", "U1", "100"]).ordered
        expect(writer_double).to receive(:add).with(["2023-01-02", "T2", "U2", "200"]).ordered
        expect(writer_double).to receive(:flush).ordered

        # allow(reader_double).to receive(:read) do |&block|
        #   %w[2023-01-02,T2,U2,200 2023-01-01,T1,U1,100].each { |row| block.call(row) }
        # end

        subject.call

        expect(output_stream.string).to eq("2023-01-02,T2,U2,200\n2023-01-01,T1,U1,100\n")
        expect(output_stream).to be_closed
      end
    end

    context "with empty input" do
      it "flushes writer and closes output" do
        expect(writer_double).to receive(:flush)
        allow(reader_double).to receive(:read)

        subject.call

        expect(output_stream.string).to be_empty
        expect(output_stream).to be_closed
      end
    end

    context "with invalid CSV line" do
      let(:input_stream) { StringIO.new("valid,data\ninvalid_data\n") }

      it "stops processing at invalid line" do
        allow(CSV).to receive(:parse_line).with("invalid_data").and_return(nil)
        expect(writer_double).to receive(:add).once
        expect(writer_double).to receive(:flush)

        subject.call
      end
    end

    context "with exact batch size" do
      let(:batch) { Array.new(App::Performer::BATCH_SIZE, "2023-01-01,T1,U1,100\n") }

      it "flushes at batch boundary and final flush" do
        input_stream = StringIO.new(batch.join)
        performer = described_class.new(input_stream: input_stream, output_stream: output_stream)

        expect(writer_double).to receive(:add).exactly(App::Performer::BATCH_SIZE).times
        expect(writer_double).to receive(:flush).twice  # Once at batch size, once final

        performer.call
      end
    end
  end

  describe "initialization" do
    it "configures database helpers with correct batch size" do
      expect(App::DatabaseWriter).to receive(:new).with(batch_size: App::Performer::BATCH_SIZE)
      expect(App::DatabaseReader).to receive(:new).with(batch_size: App::Performer::BATCH_SIZE)
      subject.call
    end
  end

  private

  def subject
    described_class.new(input_stream: input_stream, output_stream: output_stream)
  end
end

RSpec.describe App::Performer do
  subject { described_class.new(input_stream: input_stream, output_stream: output_stream) }

  let(:input_stream) { StringIO.new(input_data) }
  let(:output_stream) { StringIO.new }
  let(:input_data) { '' }

  let(:writer_double) { instance_double(App::DatabaseWriter, add: nil, flush: nil) }
  let(:reader_double) { instance_double(App::DatabaseReader, read: nil) }
  let(:batch_size) { described_class::BATCH_SIZE }

  before do
    allow(App::DatabaseWriter).to receive(:new).and_return(writer_double)
    allow(App::DatabaseReader).to receive(:new).and_return(reader_double)
  end

  describe "#call" do
    context "with valid input data" do
      let(:input_data) { "2023-01-01,T1,U1,100\n2023-01-02,T2,U2,200\n" }
      let(:expected_output) { "2023-01-02,T2,U2,200\n2023-01-01,T1,U1,100\n" }
      it "processes all rows and writes sorted output" do
        expect(writer_double).to receive(:add).with(%w[2023-01-01 T1 U1 100]).ordered
        expect(writer_double).to receive(:add).with(%w[2023-01-02 T2 U2 200]).ordered
        expect(writer_double).to receive(:flush).ordered

        expect(reader_double).to receive(:read) do |&block|
          %w[2023-01-02,T2,U2,200 2023-01-01,T1,U1,100].each(&block)
        end

        subject.call

        expect(output_stream.string).to eq(expected_output)
        expect(output_stream).to be_closed
      end
    end

    context "with empty input" do
      it "flushes writer and closes output" do
        expect(writer_double).to receive(:flush)
        allow(reader_double).to receive(:read)

        subject.call

        expect(output_stream.string).to be_empty
        expect(output_stream).to be_closed
      end
    end

    context "with invalid CSV line" do
      let(:input_data) { "valid,data\ninvalid_data\n" }

      it "stops processing at invalid line" do
        allow(CSV).to receive(:parse_line).with("invalid_data").and_return(nil)
        expect(writer_double).to receive(:add).once
        expect(writer_double).to receive(:flush)

        subject.call
      end
    end

    context "with exact batch size" do
      let(:input_data) { Array.new(batch_size, "2023-01-01,T1,U1,100\n").join }
      let(:batch_row) { %w[2023-01-01 T1 U1 100] }

      it "flushes at batch boundary and final flush" do
        expect(writer_double).to receive(:add).with(batch_row).exactly(batch_size).times
        expect(writer_double).to receive(:flush).twice

        subject.call
      end
    end
  end

  describe "initialization" do
    it "configures database helpers with correct batch size" do
      expect(App::DatabaseWriter).to receive(:new).with(batch_size: batch_size)
      expect(App::DatabaseReader).to receive(:new).with(batch_size: batch_size)
      subject.call
    end
  end
end
