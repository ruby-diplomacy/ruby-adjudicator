require 'spec_helper'

module Diplomacy
  describe StateParser do
    describe "parsing" do
      context "the French starting position" do
        before :each do
          @sp = StateParser.new
          blob = "France:APar,FBre,AMar|Par,Bre,Mar,Pic,Bur,Gas"
          @gamestate = @sp.parse_state blob
        end

        it "sets France as the owner of all French lands" do

          @gamestate[:Par].owner.should eq(:France)
          @gamestate[:Bre].owner.should eq(:France)
          @gamestate[:Mar].owner.should eq(:France)
          @gamestate[:Gas].owner.should eq(:France)
          @gamestate[:Pic].owner.should eq(:France)
          @gamestate[:Bur].owner.should eq(:France)
        end

        it "creates the correct units" do
          @gamestate[:Par].unit.should_not be_nil
          @gamestate[:Par].unit.nationality.should eq(:France)
          @gamestate[:Par].unit.type.should eq(Unit::ARMY)

          @gamestate[:Bre].unit.should_not be_nil
          @gamestate[:Bre].unit.nationality.should eq(:France)
          @gamestate[:Bre].unit.type.should eq(Unit::FLEET)

          @gamestate[:Mar].unit.should_not be_nil
          @gamestate[:Mar].unit.nationality.should eq(:France)
          @gamestate[:Mar].unit.type.should eq(Unit::ARMY)
        end
      end

      context "I'm sorry Austria, you are fucked" do
        before :each do
          @sp = StateParser.new
          blob = "Italy:ATyr,AVen,FIon|Ven,Apu,Tus,Pie,Rom,Nap Austria:FAlb,ASer,ABud|Bud,Boh,Gal,Vie,Tri,Tyr"
          @gamestate = @sp.parse_state blob
        end

        it "creates an Italian army in Tyrolia" do
          @gamestate[:Tyr].unit.should_not be_nil
          @gamestate[:Tyr].unit.nationality.should eq(:Italy)
          @gamestate[:Tyr].unit.type.should eq(Unit::ARMY)
        end

        it "sets Austria as the owner of Tyrolia" do
          @gamestate[:Tyr].owner.should eq(:Austria)
        end

        it "creates an Austrian Fleet in Albania" do
          @gamestate[:Alb].unit.should_not be_nil
          @gamestate[:Alb].unit.nationality.should eq(:Austria)
          @gamestate[:Alb].unit.type.should eq(Unit::FLEET)
        end

        it "doesn't set Austria as the owner of Albania" do
          @gamestate[:Alb].owner.should_not eq(:Austria)
        end
      end

      context "England dislodged France in Belgium" do
        before :each do
          @sp = StateParser.new
          blob = "England:ABel,FNth,FEng|Bel France:ABel*Lon"
          @gamestate = @sp.parse_state blob
        end

        it "places the French army in dislodges" do
          dislodge_tuple = @gamestate.dislodges[:Bel]

          dislodge_tuple.unit.should_not be_nil
          dislodge_tuple.unit.nationality.should eq(:France)
          dislodge_tuple.unit.type.should eq(Unit::ARMY)
        end

        it "doesn't place any more units in dislodges" do
          @gamestate.dislodges.length.should eq(1)
        end
      end

      context "Germany really has it in for Austria" do
        before :each do
          @sp = StateParser.new
          blob = "Germany:AMun,ABoh,ATyr,AGal|Mun,Sil,Boh,Tyr,Gal Austria:AVie*Sil|Vie Embattled:Vie"
          @gamestate = @sp.parse_state blob
        end

        it "marks Vienna as embattled" do
          @gamestate[:Vie].embattled.should be_true
        end

        it "doesn't mark Munich as embattled" do
          @gamestate[:Mun].embattled.should be_false
        end

        it "sets Austria as the owner of Vienna" do
          @gamestate[:Vie].owner.should eq(:Austria)
        end

        it "places the Austrian army in dislodges" do
          dislodge_tuple = @gamestate.dislodges[:Vie]

          dislodge_tuple.unit.should_not be_nil
          dislodge_tuple.unit.nationality.should eq(:Austria)
          dislodge_tuple.unit.type.should eq(Unit::ARMY)
        end
      end
    end

    describe "dumping" do
      it "dumps correctly the French starting position" do
        gamestate = GameState.new
        gamestate[:Par] = AreaState.new(:France, Unit.new(:France, Unit::ARMY))
        gamestate[:Bre] = AreaState.new(:France, Unit.new(:France, Unit::FLEET))
        gamestate[:Mar] = AreaState.new(:France, Unit.new(:France, Unit::ARMY))
        gamestate[:Pic] = AreaState.new(:France)
        gamestate[:Bur] = AreaState.new(:France)
        gamestate[:Gas] = AreaState.new(:France)
        sp = StateParser.new gamestate
        sp.dump_state.should eq("France:APar,FBre,AMar|Par,Bre,Mar,Pic,Bur,Gas")
      end

      it "dumps correctly the Russian starting position" do
        gamestate = GameState.new
        gamestate[:StP] = AreaState.new(:Russia, Unit.new(:Russia, Unit::FLEET), :sc)
        gamestate[:Sev] = AreaState.new(:Russia, Unit.new(:Russia, Unit::FLEET))
        gamestate[:War] = AreaState.new(:Russia, Unit.new(:Russia, Unit::ARMY))
        gamestate[:Mos] = AreaState.new(:Russia, Unit.new(:Russia, Unit::ARMY))
        gamestate[:Ukr] = AreaState.new(:Russia)
        gamestate[:Liv] = AreaState.new(:Russia)
        gamestate[:Fin] = AreaState.new(:Russia)
        sp = StateParser.new gamestate
        sp.dump_state.should eq("Russia:FStP(sc),FSev,AWar,AMos|StP,Sev,War,Mos,Ukr,Liv,Fin")
      end

      it "dumps correctly a position with a dislodged unit" do
        gamestate = GameState.new
        gamestate[:Bel] = AreaState.new(:England, Unit.new(:England, Unit::ARMY))
        gamestate[:Nth] = AreaState.new(nil, Unit.new(:England, Unit::FLEET))
        gamestate[:Eng] = AreaState.new(nil, Unit.new(:England, Unit::FLEET))
        gamestate.dislodges[:Bel] = DislodgeTuple.new(Unit.new(:France, Unit::ARMY), :Lon)
        sp = StateParser.new gamestate
        sp.dump_state.should eq("England:ABel,FNth,FEng|Bel France:ABel*Lon")
      end

      it "dumps correctly a state with an embattled area" do
        gamestate = GameState.new
        gamestate[:Vie] = AreaState.new(:Germany, Unit.new(:Germany, Unit::ARMY), nil, true)

        sp = StateParser.new gamestate
        sp.dump_state.should eq("Germany:AVie|Vie Embattled:Vie")
      end
    end
  end

  describe "parsing and dumping" do
    it "preserves information" do
      blob = "Italy:ATyr,AVen,FIon|Ven,Apu,Tus,Pie,Rom,Nap Austria:FAlb,ASer,ABud|Bud,Boh,Gal,Vie,Tri,Tyr"
      sp = StateParser.new
      gamestate = sp.parse_state blob

      dumper = StateParser.new gamestate
      # dumper.dump_state.should eq(blob) not testing this, because order might have changed, but we don't care
      # instead we reparse

      StateParser.new.parse_state(dumper.dump_state).should eq(gamestate)
    end
  end
end
