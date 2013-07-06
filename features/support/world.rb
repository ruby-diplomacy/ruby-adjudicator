module DiplomacyWorld
  def adjudicator
    if @adjudicator.nil?
      @adjudicator = Diplomacy::Adjudicator.new
    end
    @adjudicator
  end
  
  def orders
    @orders ||= []
  end
 
  def status_to_s(status)
    case status
    when Diplomacy::SUCCESS
      return 'S'
    when Diplomacy::FAILURE
      return 'F'
    when Diplomacy::INVALID
      return 'I'
    end
  end
end

World(DiplomacyWorld)
