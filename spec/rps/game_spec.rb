require 'spec_helper'

describe Rps::Game do
  let(:game) { Rps::Game.new }

  describe "#new" do
    it "has Markov reasoner as default" do
      game.reasoner.should be_a(Rps::MarkovReasoner)
    end

    it "hands can be rock, paper or scissors" do
      Rps::Game::HANDS.should eq([:r, :p, :s])
    end
  end

  describe "#check_hand" do
    it "raises error for invalid hand" do
      expect { game.check_hand :k }.to raise_error Rps::Game::InvalidHand
    end
  end

  describe "#estimate_my_hand" do
    it "ask the reasoner for the next possible hand" do
      game.reasoner.should_receive(:estimate_next_events).and_return([])
      game.estimate_my_hand
    end

    it "plays rock to beat scissors" do
      game.reasoner.stub(estimate_next_events: [:s])
      game.estimate_my_hand.should eq(:r)
    end

    it "plays paper to beat rock" do
      game.reasoner.stub(estimate_next_events: [:r])
      game.estimate_my_hand.should eq(:p)
    end

    it "plays scissors to beat paper" do
      game.reasoner.stub(estimate_next_events: [:p])
      game.estimate_my_hand.should eq(:s)
    end
  end

  describe "#check_win" do
    describe "given we play the same hand" do
      it "is a draw" do
        game.get_winner(:r, :r).should eq(:draw)
        game.get_winner(:p, :p).should eq(:draw)
        game.get_winner(:s, :s).should eq(:draw)
      end
    end

    describe "given player plays rock" do
      it "beats my scissors" do
        game.get_winner(:r, :s).should eq(:you)
      end

      it "loses for my paper" do
        game.get_winner(:r, :p).should eq(:me)
      end
    end

    describe "given player plays paper" do
      it "beats my rock" do
        game.get_winner(:p, :r).should eq(:you)
      end

      it "loses for my scissors" do
        game.get_winner(:p, :s).should eq(:me)
      end
    end

    describe "given player plays scissors" do
      it "beats my paper" do
        game.get_winner(:s, :p).should eq(:you)
      end

      it "loses for my rock" do
        game.get_winner(:s, :r).should eq(:me)
      end
    end
  end

  describe "#process_hand" do
    it "adds event to reasoner" do
      game.reasoner.should_receive(:add_event).with(:r)
      game.process_hand :r
    end
  end

  describe "#update_stats" do
    it "sums 1 to the result" do
      game.update_stats :draw
      game.stats.values.should eq([0, 0, 1])
    end
  end

  describe "#turn" do
    it do
      game.should_receive :check_hand
      game.should_receive :estimate_my_hand
      game.should_receive :get_winner
      game.should_receive :update_stats
      game.should_receive :format_output
      game.should_receive :process_hand
      game.turn :r
    end
  end
end