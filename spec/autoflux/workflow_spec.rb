# frozen_string_literal: true

RSpec.describe Autoflux::Workflow do
  subject(:workflow) { described_class.new(state: state) }
  let(:state) { nil }

  describe "#run" do
    subject(:run) { workflow.run }

    it { is_expected.to be_nil }
  end
end
