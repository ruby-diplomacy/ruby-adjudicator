require 'spec_helper'

module Diplomacy
  describe OrderParser do
    describe "parsing" do
      before :each do
        sp = StateParser.new
        stateblob = "Italy:FAdr,AApu Austria:FTri,AVie,ABud"

        @gamestate = sp.parse_state stateblob
      end

      context "one of each" do
        before :each do
          @op = OrderParser.new @gamestate

          blob = "AApu-Tri,FAdrCAApu-Tri,FTriH,ABudSFTriH,AVieSABud-Vie"
          orderList = @op.parse_orders blob
          @orders = {}
          orderList.each do |order|
            @orders[order.unit_area] = order
          end
        end

        it "parses holds correctly" do
          expect(@orders[:Tri]).to be_an_instance_of(Hold)
        end

        it "parses moves correctly" do
          expect(@orders[:Apu]).to be_an_instance_of(Move)
        end

        it "parses supports correctly" do
          expect(@orders[:Vie]).to be_an_instance_of(Support)
        end

        it "parses support holds correctly" do
          expect(@orders[:Bud]).to be_an_instance_of(SupportHold)
        end

        it "parses convoys correctly" do
          expect(@orders[:Adr]).to be_an_instance_of(Convoy)
        end
      end
      context "wrong orders" do
        it "throws OrderParsingError" do
          @op = OrderParser.new @gamestate

          blob = "AApu-Tri,FAdrCApu-Tri,FTriABudSFTriH,AVieSABud-Vie"
          expect {
            orderList = @op.parse_orders blob
          }.to raise_error OrderParsingError
        end

        it "throws WrongOrderTypeError" do
          @op = OrderParser.new @gamestate

          blob = "AApu-Tri,FAdrCAApu-Tri,FTriH,ABudSFTriH,AVieSABud-Vie"
          expect {
            @op.parse_retreats blob
          }.to raise_error WrongOrderTypeError
        end
      end
    end
  end
end
