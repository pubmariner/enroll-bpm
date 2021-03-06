module Notifier
  class MergeDataModels::Dependent
    include Virtus.model

    attribute :first_name, String
    attribute :last_name, String
    attribute :mailing_address, MergeDataModels::Address
    attribute :age, Integer
    attribute :dc_resident, String
    attribute :citizenship, String
    attribute :incarcerated, String
    attribute :federal_tax_filing_status, String
    attribute :tax_household_size, Integer
    attribute :expected_income_for_coverage_year, String
    attribute :aptc, String
    attribute :other_coverage, String
    attribute :aqhp_eligible, Boolean
    attribute :uqhp_eligible, Boolean
    attribute :totally_ineligible, Boolean
    attribute :non_magi_medicaid, Boolean
    attribute :magi_medicaid, Boolean
    attribute :aqhp_or_non_magi_medicaid_members_present, Boolean
    attribute :totally_ineligible_members_present, Boolean
    attribute :magi_medicaid_members_present, Boolean

    def self.stubbed_object
      Notifier::MergeDataModels::Dependent.new(
        {
          first_name: 'Dependent',
          last_name: 'Test',
          age: 19,
          federal_tax_filing_status: 'Married Filing Jointly',
          expected_income_for_coverage_year: "$6500",
          citizenship: 'US Citizen',
          dc_resident: 'Yes',
          tax_household_size: 2,
          coverage_year: 2020,
          previous_coverage_year: 2019,
          incarcerated: 'No',
          other_coverage: 'No',
          aptc: nil,
          totally_ineligible: 'No',
          non_magi_medicaid: 'No',
          magi_medicaid: 'Yes',
          aqhp_eligible: 'No',
          uqhp_eligible: 'No',
          aqhp_event: true,
          uqhp_event: false,
          aqhp_or_non_magi_medicaid_members_present: false,
          totally_ineligible_members_present: false,
          magi_medicaid_members_present: true
        }
      )
    end

    def collections
      %w[]
    end

    def conditions
      %w[uqhp_eligible? aqhp_eligible? aqhp_eligible_and_irs_consent_not_needed? magi_medicaid? non_magi_medicaid? aqhp_or_non_magi_medicaid? uqhp_or_non_magi_medicaid? totally_ineligible?]
    end

    def uqhp_eligible?
      uqhp_eligible
    end

    def totally_ineligible?
      totally_ineligible
    end

    def aqhp_eligible_and_irs_consent_not_needed?
      aqhp_eligible? && !irs_consent?
    end

    def magi_medicaid?
      magi_medicaid
    end

    def non_magi_medicaid?
      non_magi_medicaid
    end

    def aqhp_or_non_magi_medicaid?
      aqhp_eligible? || non_magi_medicaid?
    end

    def uqhp_or_non_magi_medicaid?
      uqhp_eligible? || non_magi_medicaid?
    end

    def aqhp_eligible?
      aqhp_eligible
    end
  end
end