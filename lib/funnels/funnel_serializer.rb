module Funnels
  class FunnelSerializer
    attr_accessor :funnel

    def initialize(funnel)
      raise ArgumentError, "arg must be a Funnel" unless funnel.is_a? Funnels::Funnel
      self.funnel = funnel
    end

    
  end
end
