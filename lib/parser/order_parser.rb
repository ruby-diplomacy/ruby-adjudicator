module Diplomacy
  class OrderParser
    def initialize(gamestate, orders=nil)
      @gamestate = gamestate || GameState.new
      @orders = orders || []
    end

    def parse_orders(orderblob)
      @orders.clear
      order_list = orderblob.split(',')
      
      order_list.each do |order_text|
        @orders << parse_single_order(order_text)
      end
      @orders
    end
    
    def parse_single_order(orderblob)
      # try to parse it as a move
      /^[AF](?'unit_area'\w{3})(?'unit_area_coast'\(.+?\))?-(?'dst'\w{3})(?'dst_coast'[^-]+)?$/ =~ orderblob
      if not unit_area.nil?
        unit = @gamestate[unit_area.to_sym].unit unless unit_area.nil?
        move = Move.new(unit, unit_area.to_sym, dst.to_sym)
        move.unit_area_coast = unit_area_coast if not unit_area_coast.nil?
        move.dst_coast = dst_coast if not dst_coast.nil?
        return move
      end
      
      # try to parse it as a hold
      /^[AF](?'unit_area'\w{3})H$/ =~ orderblob
      if not unit_area.nil?
        unit = @gamestate[unit_area.to_sym].unit unless unit_area.nil?
        return Hold.new(unit, unit_area.to_sym)
      end
      
      # try to parse it as a support
      /^[AF](?'unit_area'\w{3})(?'unit_area_coast'\(.+?\))?S[AF](?'src'\w{3})(?'src_coast'\(.+?\))?-(?'dst'\w{3})(?'dst_coast'[^-]+)?$/ =~ orderblob
      if not unit_area.nil?
        unit = @gamestate[unit_area.to_sym].unit unless unit_area.nil?
        support = Support.new(unit, unit_area.to_sym, src.to_sym, dst.to_sym)
        support.unit_area_coast = unit_area_coast if not unit_area_coast.nil?
        support.src_coast = src_coast if not src_coast.nil?
        support.dst_coast = dst_coast if not dst_coast.nil?
        return support
      end
      
      # try to parse it as a support hold
      /^[AF](?'unit_area'\w{3})(?'unit_area_coast'\(.+?\))?S[AF](?'dst'\w{3})(?'dst_coast'\(.+?\))?$/ =~ orderblob
      if not unit_area.nil?
        unit = @gamestate[unit_area.to_sym].unit unless unit_area.nil?
        support = SupportHold.new(unit, unit_area.to_sym, dst.to_sym)
        support.unit_area_coast = unit_area_coast if not unit_area_coast.nil?
        support.dst_coast = dst_coast if not dst_coast.nil?
        return support
      end
      
      # try to parse it as a convoy
      /^[AF](?'unit_area'\w{3})C[AF](?'src'\w{3})-(?'dst'\w{3})$/ =~ orderblob
      if not unit_area.nil?
        unit = @gamestate[unit_area.to_sym].unit unless unit_area.nil?
        return Convoy.new(unit, unit_area.to_sym, src.to_sym, dst.to_sym)
      end
    end

    def parse_retreats(orderblob)
      @orders.clear
      order_list = orderblob.split(',')

      order_list.each do |order_text|
        @orders << parse_single_retreat(order_text)
      end
      @orders
    end

    def parse_single_retreat(orderblob)
      # try to parse it as a move
      /^[AF](?'unit_area'\w{3})(?'unit_area_coast'\(.+?\))?-(?'dst'\w{3})(?'dst_coast'[^-]+)?$/ =~ orderblob
      if not unit_area.nil?
        unit = @gamestate[unit_area.to_sym].unit unless unit_area.nil?
        retreat = Retreat.new(unit, unit_area.to_sym, dst.to_sym)
        retreat.unit_area_coast = unit_area_coast if not unit_area_coast.nil?
        retreat.dst_coast = dst_coast if not dst_coast.nil?
        return retreat
      end
    end

    def parse_builds(orderblob)
      @orders.clear
      order_list = orderblob.split(',')

      order_list.each do |order_text|
        @orders << parse_single_build(order_text)
      end
      @orders
    end

    def parse_single_build(orderblob)
      /^(?'unit_type'[AF])(?'unit_area'\w{3})(?'build'[BD])$/ =~ orderblob
      if not unit_area.nil?
      	is_build = (build == 'B')
        is_army = (unit_type == 'A')
      	if is_build
          unit = Unit.new @gamestate[unit_area.to_sym].owner, (is_army ? Unit::ARMY : Unit::FLEET)
        else
          unit = @gamestate[unit_area.to_sym].unit
        end

        return Build.new(unit, unit_area.to_sym, is_build)
      end
    end
  end
end
