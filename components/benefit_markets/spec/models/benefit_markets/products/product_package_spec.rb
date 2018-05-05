require 'rails_helper'

module BenefitMarkets
  RSpec.describe Products::ProductPackage, type: :model do

    let(:this_year)               { TimeKeeper.date_of_record.year }
    # let(:benefit_market_kind)     { :aca_shop }
    let(:application_period)      { Date.new(this_year, 1, 1)..Date.new(this_year, 12, 31) }
    let(:product_kind)            { :health }
    let(:kind)                    { :single_issuer }
    let(:hbx_id)                  { "58585858" }
    let(:title)                   { "SafeCo Issuer Health" }
    let(:description)             { "All products offered by a single issuer" }
    let(:products)                { [FactoryGirl.build(:benefit_markets_products_product)] }
    # let(:contribution_model_key)  { "Highest rated and highest value" }
    # let(:pricing_model_key)       { "Highest rated and highest value" }


    let(:params) do
        {
          application_period: application_period,
          product_kind:       product_kind,
          kind:               kind,
          hbx_id:             hbx_id,
          title:              title,
          description:        description,
          products:           products,
          # contribution_model: contribution_model,
          # pricing_model:      pricing_model,
        }
    end

    context "A new Product instance" do

      context "with no arguments" do
        subject { described_class.new }

        it "should not be valid" do
          subject.validate
          expect(subject).to_not be_valid
        end
      end

      context "without required params" do

        context "that's missing title" do
          subject { described_class.new(params.except(:title)) }

          it "should be invalid" do
            subject.validate
            expect(subject).to_not be_valid
            expect(subject.errors[:title]).to include("can't be blank")
          end
        end
      end

      context "with all valid params" do
        subject { described_class.new(params) }

        it "should be valid" do
          subject.validate
          expect(subject).to be_valid
        end
      end

    end
  end
end
