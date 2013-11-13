module Diplomacy
  class OrderParser
    def initialize(gamestate, orders=nil)
      @gamestate = gamestate || GameState.new
      @orders = orders || []
    end

    def parse_orders(orderblob, classes=[Move, Hold, Support, SupportHold, Convoy]) 
      @orders.clear
      order_list = orderblob.split(',')

      order_list.each do |order_text|
        @orders << parse_single_order(order_text)
      end

      wrong_orders = []
      @orders.each_with_index do |order, index|
        if order.nil?
          wrong_orders << order_list[index]
        end
      end

      unless wrong_orders.empty?
        raise OrderParsingError.new(wrong_orders), "Failed to parse orders: #{wrong_orders.join(", ")}"
      end

      @orders.each do |order|
        raise WrongOrderTypeError, "expected one of #{classes}, received #{order.class}" unless classes.member? order.class
      end

      @orders
    end

    def parse_retreats(orderblob)
      parse_orders(orderblob, [Retreat])
    end

    def parse_builds(orderblob)
      parse_orders(orderblob, [Build])
    end

    private

    def parse_single_order(orderblob)
      # try to parse it as a move
      if /^[AF](?'unit_area'\w{3})(?'unit_area_coast'\(.+?\))?-(?'dst'\w{3})(?'dst_coast'\(.+?\))?$/ =~ orderblob
        unit = @gamestate[unit_area.to_sym].unit
        move = Move.new(unit, unit_area.to_sym, dst.to_sym)
        move.unit_area_coast = unit_area_coast if not unit_area_coast.nil?
        move.dst_coast = dst_coast if not dst_coast.nil?
        return move
      end

      # try to parse it as a hold
      if /^[AF](?'unit_area'\w{3})H$/ =~ orderblob
        unit = @gamestate[unit_area.to_sym].unit unless unit_area.nil?
        return Hold.new(unit, unit_area.to_sym)
      end

      # try to parse it as a support
      if /^[AF](?'unit_area'\w{3})(?'unit_area_coast'\(.+?\))?S[AF](?'src'\w{3})(?'src_coast'\(.+?\))?-(?'dst'\w{3})(?'dst_coast'\(.+?\))?$/ =~ orderblob
        unit = @gamestate[unit_area.to_sym].unit unless unit_area.nil?
        support = Support.new(unit, unit_area.to_sym, src.to_sym, dst.to_sym)
        support.unit_area_coast = unit_area_coast if not unit_area_coast.nil?
        support.src_coast = src_coast if not src_coast.nil?
        support.dst_coast = dst_coast if not dst_coast.nil?
        return support
      end

      # try to parse it as a support hold
      if /^[AF](?'unit_area'\w{3})(?'unit_area_coast'\(.+?\))?S[AF](?'dst'\w{3})(?'dst_coast'\(.+?\)?)?H$/ =~ orderblob
        unit = @gamestate[unit_area.to_sym].unit unless unit_area.nil?
        support = SupportHold.new(unit, unit_area.to_sym, dst.to_sym)
        support.unit_area_coast = unit_area_coast if not unit_area_coast.nil?
        support.dst_coast = dst_coast if not dst_coast.nil?
        return support
      end

      # try to parse it as a convoy
      if /^[AF](?'unit_area'\w{3})C[AF](?'src'\w{3})-(?'dst'\w{3})$/ =~ orderblob
        unit = @gamestate[unit_area.to_sym].unit unless unit_area.nil?
        return Convoy.new(unit, unit_area.to_sym, src.to_sym, dst.to_sym)
      end

      # try to parse it as a retreat
      if /^[AF](?'unit_area'\w{3})(?'unit_area_coast'\(.+?\))?\*(?'dst'\w{3})(?'dst_coast'\(.+?\))?$/ =~ orderblob
        unit = @gamestate[unit_area.to_sym].unit
        retreat = Retreat.new(unit, unit_area.to_sym, dst.to_sym)
        retreat.unit_area_coast = unit_area_coast if not unit_area_coast.nil?
        retreat.dst_coast = dst_coast if not dst_coast.nil?
        return retreat
      end

      # try to parse it as a build
      if /^(?'unit_type'[AF])(?'unit_area'\w{3})(?'unit_area_coast'\(.+?\))?(?'build'[BD])$/ =~ orderblob
        is_build = (build == 'B')
        is_army = (unit_type == 'A')


        if is_build
          unit = Unit.new @gamestate[(unit_area + (unit_area_coast || "") ).to_sym].owner, (is_army ? Unit::ARMY : Unit::FLEET)
        else
          unit = @gamestate[(unit_area + (unit_area_coast || "") ).to_sym].unit
        end

        build = Build.new(unit, unit_area.to_sym, is_build)
        build.unit_area_coast = unit_area_coast unless unit_area_coast.nil?
        return build
      end

      return nil
    end
  end

  class OrderParsingError < StandardError
    attr_accessor :orderblob

    def initialize(orderblob)
      @orderblob = orderblob
    end
  end

  class WrongOrderTypeError < StandardError
  end
end
