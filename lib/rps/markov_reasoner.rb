module Rps
  class MarkovReasoner
    UnknownEvent = Class.new(StandardError)

    attr_accessor :states, :events, :matrix

    def initialize(states, initial_state = nil)
      @states = states
      @events = []
      @events << initial_state if initial_state
      setup_matrix
    end

    def setup_matrix
      @matrix = {}
      @states.each do |i|
        @matrix[i] = {}
        @states.each do |j|
          @matrix[i][j] = 0
        end
      end

      @matrix
    end

    def last_event
      @events.last || @states.sample
    end

    def add_event(event)
      check_event event
      @matrix[last_event][event] += 1
      @events << event
    end

    def estimate_next_events
      max = @matrix[last_event].values.max
      possibilities = @matrix[last_event].select { |k, v| v >= max }

      possibilities.keys
    end

    def check_event(event)
      @states.include?(event) or raise UnknownEvent
    end
  end
end

