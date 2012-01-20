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

  describe "#my_hand" do
    it "ask the reasoner for the next possible hand" do
      game.reasoner.should_receive(:estimate_next_events).and_return([])
      game.my_hand
    end

    it "plays rock to beat scissors" do
      game.reasoner.stub(estimate_next_events: [:s])
      game.my_hand.should eq(:r)
    end

    it "plays paper to beat rock" do
      game.reasoner.stub(estimate_next_events: [:r])
      game.my_hand.should eq(:p)
    end

    it "plays scissors to beat paper" do
      game.reasoner.stub(estimate_next_events: [:p])
      game.my_hand.should eq(:s)
    end
  end

  describe "#check_win" do
    describe "given we play the same hand" do
      it "is a draw" do
        game.check_win(:r, :r).should eq("Rock vs Rock: It's a draw")
        game.check_win(:p, :p).should eq("Paper vs Paper: It's a draw")
        game.check_win(:s, :s).should eq("Scissors vs Scissors: It's a draw")
      end
    end

    describe "given player plays rock" do
      it "beats scissors" do
        game.check_win(:r, :s).should eq("Rock vs Scissors: You won!")
      end

      it "loses for paper" do
        game.check_win(:r, :p).should eq("Rock vs Paper: I won!")
      end
    end

    describe "given player plays paper" do
      it "beats rock" do
        game.check_win(:p, :r).should eq("Paper vs Rock: You won!")
      end

      it "loses for scissors" do
        game.check_win(:p, :s).should eq("Paper vs Scissors: I won!")
      end
    end

    describe "given player plays scissors" do
      it "beats paper" do
        game.check_win(:s, :p).should eq("Scissors vs Paper: You won!")
      end

      it "loses for rock" do
        game.check_win(:s, :r).should eq("Scissors vs Rock: I won!")
      end
    end
  end

  describe "#process_hand" do
    it "adds event to reasoner" do
      game.reasoner.should_receive(:add_event).with(:r)
      game.process_hand :r
    end
  end

  describe "#turn" do
    it do
      game.should_receive :check_hand
      game.should_receive :check_win
      game.should_receive :process_hand
      game.should_receive :format_output
      game.turn :r
    end
  end
end