module Rps
  class Game
    HANDS = [:r, :p, :s]
    BEATS = { r: :p, p: :s, s: :r }
    NAMES = { r: "Rock", p: "Paper", s: "Scissors" }

    InvalidHand = Class.new(StandardError)

    attr_accessor :reasoner, :stats

    # New Scientist magazine conducted a study in 2007 concluding
    # that rock was most commonly played first
    def initialize(reasoner = Rps::MarkovReasoner.new(HANDS, :r))
      @reasoner = reasoner
      @stats = { me: 0, you: 0, draw: 0 }
    end

    def turn(opponents_hand)
      check_hand opponents_hand
      my_hand = estimate_my_hand
      result = get_winner(opponents_hand, my_hand)
      update_stats result
      process_hand opponents_hand
      format_output(opponents_hand, my_hand, result)
    end

    def update_stats(result)
      @stats[result] += 1
    end

    def statistics
      "My wins/Ties/Your wins: #{@stats[:me]} / #{@stats[:draw]} / #{@stats[:you]}"
    end

    def check_hand(hand)
      raise InvalidHand.new(hand) unless HANDS.include?(hand)
    end

    def estimate_my_hand
      opponent = @reasoner.estimate_next_events.sample
      BEATS[opponent]
    end

    def format_output(opponent_hand, my_hand, result)
      turn = "#{NAMES[opponent_hand]} vs #{NAMES[my_hand]}: "
      turn << case result
      when :draw  then "It's a draw"
      when :you   then "You won!"
      else "I won!"
      end
      turn
    end

    def get_winner(opponent_hand, my_hand)
      case opponent_hand
      when my_hand        then :draw
      when BEATS[my_hand] then :you
      else :me
      end
    end

    def process_hand(opponent)
      @reasoner.add_event opponent
    end
  end
end