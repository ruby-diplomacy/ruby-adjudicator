require 'spec_helper'

module Diplomacy
  describe GameState do
    describe "#apply_orders!" do
      before :each do
        @gs = GameState.new

        @italian_army = Unit.new("Italy", Unit::ARMY)
        @austrian_army = Unit.new("Austria", Unit::ARMY)
        @austrian_fleet = Unit.new("Austria", Unit::FLEET)
        @french_army = Unit.new("France", Unit::ARMY)

        @gs[:Ven] = AreaState.new "Italy", @italian_army
        @gs[:Tri] = AreaState.new "Austria", @austrian_fleet
        @gs[:Tyr] = AreaState.new "Austria", @austrian_army
        @gs[:Mar] = AreaState.new "France", @french_army
      end

      it "moves a unit that moved successfully" do
        move = Move.new(@italian_army, :Ven, :Pie)
        move.succeed

        @gs.apply_orders! [ move ]

        @gs[:Ven].unit.should be_nil
        @gs[:Pie].unit.should eq(@italian_army)
      end

      it "doesn't move a unit that moved unsuccessfully" do
        move = Move.new(@italian_army, :Ven, :Tyr)
        move.fail

        @gs.apply_orders! [ move ]

        @gs[:Ven].unit.should eq(@italian_army)
        @gs[:Tyr].unit.should eq(@austrian_army)
      end

      it "handles a dislodge correctly" do
        move = Move.new(@austrian_army, :Tyr, :Ven)
        support = Support.new(@austrian_fleet, :Tri, :Tyr, :Ven)
        hold = Hold.new(@italian_army, :Ven)

        @gs.apply_orders! [ move, support, hold ].each {|o| o.succeed }

        @gs[:Ven].unit.should eq(@austrian_army)
        @gs[:Tyr].unit.should be_nil
        @gs[:Tri].unit.should eq(@austrian_fleet)
        @gs.retreats[:Ven].should eq(@italian_army)
      end

      it "changes ownership on successful move (with adjust=true)" do
        move = Move.new(@italian_army, :Ven, :Pie)
        move.succeed

        @gs.apply_orders! [ move ], true

        @gs[:Pie].owner.should eq(@italian_army.nationality)
      end

      it "changes ownership on dislodge (with adjust=true)" do
        move = Move.new(@austrian_army, :Tyr, :Ven)
        support = Support.new(@austrian_fleet, :Tri, :Tyr, :Ven)
        hold = Hold.new(@italian_army, :Ven)

        @gs.apply_orders! [ move, support, hold ].each {|o| o.succeed }, true

        @gs[:Ven].owner.should eq(@austrian_army.nationality)
      end
    end

    describe "#apply_retreats!" do
      before :each do
        @gs = GameState.new

        @italian_army = Unit.new("Italy", Unit::ARMY)
        @austrian_army = Unit.new("Austria", Unit::ARMY)
        @austrian_fleet = Unit.new("Austria", Unit::FLEET)

        @gs.retreats[:Ven] = @italian_army
        @gs[:Tri] = AreaState.new "Austria", @austrian_fleet
        @gs[:Ven] = AreaState.new "Austria", @austrian_army
      end

      it "moves a unit when it retreats" do
        retreat = Retreat.new @italian_army, :Ven, :Pie
        retreat.succeed

        @gs.apply_retreats! [ retreat ]

        @gs[:Pie].unit.should eq(@italian_army)
      end

      it "doesn't move units when they retreat unsuccessfully" do
        retreat = Retreat.new @italian_army, :Ven, :Pie
        other_retreat = Retreat.new @french_army, :Mar, :Pie
        retreat.fail
        other_retreat.fail

        @gs.apply_retreats! [ retreat, other_retreat ]

        @gs[:Pie].unit.should be_nil
      end

      it "changes ownership on successful retreat (with adjust=true)" do
        retreat = Retreat.new @italian_army, :Ven, :Pie
        retreat.succeed

        @gs.apply_retreats! [ retreat ], true

        @gs[:Pie].owner.should eq(@italian_army.nationality)
      end
    end

    describe "#apply_builds!" do
      it "builds units" do
        @gs = GameState.new

        @new_english_army = Unit.new("England", Unit::ARMY)
        @new_english_fleet = Unit.new("England", Unit::FLEET)
        @new_french_fleet = Unit.new("France", Unit::FLEET)

        builds = [
          Build.new(@new_english_army, :Yor),
          Build.new(@new_english_fleet, :Lon),
          Build.new(@new_french_fleet, :Bre)
        ].each {|b| b.succeed }

        @gs.apply_builds!(builds)

        @gs[:Yor].unit.should eq(@new_english_army)
        @gs[:Lon].unit.should eq(@new_english_fleet)
        @gs[:Bre].unit.should eq(@new_french_fleet)
      end
    end
  end
end
