require "spec_helper"

describe Rps::MarkovReasoner do
  let(:states)   { %w{ r p s }.map(&:to_sym) }
  let(:reasoner) { Rps::MarkovReasoner.new states }

  describe "#new" do
    it "needs states on initialization" do
      reasoner.states.should be(states)
    end

    it "can have initial state" do
      reasoner = Rps::MarkovReasoner.new([:r, :p, :s], :r)
      reasoner.events.should eq([:r])
    end

    it "setups matrix" do
      reasoner.matrix.keys.should eq(states)
    end
  end

  describe "#setup_matrix" do
    it "sets all elements to zero" do
      reasoner.setup_matrix
      states.each do |state|
        reasoner.matrix[state].keys.should eq(states)
        reasoner.matrix[state].values.should eq([0, 0, 0])
      end
    end
  end

  describe "#add_event" do
    it "can't add unknown event" do
      expect { reasoner.add_event('k') }.to raise_error Rps::MarkovReasoner::UnknownEvent
    end

    it "append event" do
      reasoner.add_event :r
      reasoner.events.should eq([:r])
    end

    describe "given the last and current plays are paper and rock respectively" do
      it "increment the transition from rock to paper by 1" do
        reasoner.events = [:p]
        reasoner.add_event(:r)
        reasoner.matrix[:p][:r].should eq(1)
      end
    end
  end

  describe "#estimate_next_events" do
    before do
      reasoner.matrix = {
        r: { r: 3, p: 3, s: 2 },
        p: { r: 2, p: 2, s: 1 },
        s: { r: 1, p: 0, s: 0 }
      }
    end

    it "estimates rock if current is scissors" do
      reasoner.events = [:s]
      reasoner.estimate_next_events.should eq([:r])
    end

    it "estimates rock or paper if current is rock" do
      reasoner.events = [:r]
      reasoner.estimate_next_events.should eq([:r, :p])
    end
  end

  describe "#last_event" do
    it "gets random sample if empty events" do
      reasoner.states.should_receive :sample
      reasoner.last_event
    end
  end
end

