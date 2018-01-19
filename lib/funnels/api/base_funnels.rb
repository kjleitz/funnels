module Funnels
  class BaseFunnels
    def funnel(description)
      return unless block_given?
      funnel = Funnels::Funnel.new description: description, category: category
      yield funnel
      funnel.save!
    end

    def category
      self.class.name.demodulize.gsub(/funnels?/i, '').underscore.to_sym
    end
  end
end
