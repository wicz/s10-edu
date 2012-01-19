module Rps
  class Game
    HANDS = %w{ r p s }.map(&:to_sym)
    BEATS = { r: :s, p: :r, s: :p }
    NAMES = { r: "Rock", p: "Paper", s: "Scissors" }

    InvalidHand = Class.new StandardError

    attr_accessor :reasoner

    # New Scientist magazine conducted a study in 2007 concluding
    # that rock was most commonly played first
    def initialize(reasoner = Rps::MarkovReasoner.new(HANDS, :r))
      @reasoner = reasoner
    end

    def turn opponents_hand
      check_hand opponents_hand
      result = check_win opponents_hand, my_hand
      process_hand opponents_hand
      format_output result
    end

    def check_hand hand
      raise InvalidHand unless HANDS.include? hand
    end

    def my_hand
      opponent = @reasoner.estimate_next_events.sample
      BEATS.invert[opponent]
    end

    def format_output result
      result
    end

    def check_win opponent, mine
      turn = "#{NAMES[opponent]} vs #{NAMES[mine]}: "
      turn << case opponent
      when mine then "It's a draw"
      when BEATS[mine] then "I won!"
      else "You won!"
      end
      turn
    end

    def process_hand opponent
      @reasoner.add_event opponent
    end
  end
end