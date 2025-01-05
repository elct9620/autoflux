# frozen_string_literal: true

RSpec.describe Autoflux::Memory do
  subject(:memory) { described_class.new }

  describe "#push" do
    subject(:push) { memory.push(data) }
    let(:data) { { role: "system", content: "Your are a helpful assistant" } }

    it do
      expect { push }
        .to change(memory, :data)
        .from([])
        .to([
              { role: "system", content: "Your are a helpful assistant" }
            ])
    end

    context "when initial data is given" do
      subject(:memory) { described_class.new(data: [data]) }

      it do
        expect { push }
          .to change(memory, :data)
          .from([{ role: "system", content: "Your are a helpful assistant" }])
          .to([
                { role: "system", content: "Your are a helpful assistant" },
                { role: "system", content: "Your are a helpful assistant" }
              ])
      end
    end
  end
end
