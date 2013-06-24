require 'spec_helper'

module Diplomacy
  describe Map do
    context "the starting state of the standard map" do
      before :each do
        mr = MapReader.new
        @map = mr.maps['Standard']
        @starting_state = @map.starting_state
      end

      it "places units correctly" do
        @starting_state[:Par].unit.should_not be_nil
        @starting_state[:Par].unit.nationality.should eq("France")
        @starting_state[:Par].unit.type.should eq(Unit::ARMY)

        @starting_state[:Bre].unit.should_not be_nil
        @starting_state[:Bre].unit.nationality.should eq("France")
        @starting_state[:Bre].unit.type.should eq(Unit::FLEET)

        @starting_state[:Liv].unit.should_not be_nil
        @starting_state[:Liv].unit.nationality.should eq("England")
        @starting_state[:Liv].unit.type.should eq(Unit::ARMY)

        @starting_state[:Lon].unit.should_not be_nil
        @starting_state[:Lon].unit.nationality.should eq("England")
        @starting_state[:Lon].unit.type.should eq(Unit::FLEET)
      end

      it "sets occupied area owners correcly" do
        @starting_state[:Par].owner.should eq("France")
        @starting_state[:Bre].owner.should eq("France")

        @starting_state[:Liv].owner.should eq("England")
        @starting_state[:Lon].owner.should eq("England")
      end

      it "sets unoccupied area owners correcly" do
        @starting_state[:Gas].owner.should eq("France")
        @starting_state[:Bur].owner.should eq("France")

        @starting_state[:Wal].owner.should eq("England")
        @starting_state[:Yor].owner.should eq("England")
      end
    end
  end
end
