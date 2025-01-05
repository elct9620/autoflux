# frozen_string_literal: true

RSpec.describe Autoflux::Workflow do
  subject(:workflow) { described_class.new(state: state) }
  let(:state) { nil }

  describe "#run" do
    subject(:run) { workflow.run }

    it { is_expected.to be_nil }

    context "when the state is abstract" do
      let(:state) { Autoflux::State.new }

      it { expect { run }.to raise_error(NotImplementedError) }
    end

    context "when the state is a concrete state" do
      let(:state) { Autoflux::Stop.new }

      it { is_expected.to be_nil }
    end
  end
end
