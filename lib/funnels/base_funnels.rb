module Funnels
  class BaseFunnels < ActiveRecord::Base
    def funnel(description)
      return unless block_given?
      funnel = Funnels::Funnel.new description: description
      yield funnel
      funnel.save!
    end
  end
end
