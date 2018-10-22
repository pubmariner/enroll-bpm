require 'rails_helper'

RSpec.describe 'BenefitSponsors::ModelEvents::EmployeeCoveragePassiveRenewalFailed', :dbclean => :after_each do

  let(:model_event)  { "employee_coverage_passive_renewal_failed" }
  let(:notice_event) { "employee_coverage_passive_renewal_failed" }
  let!(:start_on) { TimeKeeper.date_of_record.next_month.beginning_of_month}
  let!(:site) { create(:benefit_sponsors_site, :with_benefit_market, :as_hbx_profile, :cca) }
  let(:organization) { FactoryGirl.create(:benefit_sponsors_organizations_general_organization, :with_aca_shop_cca_employer_profile_renewal_application, site: site) }
  let(:employer_profile) { organization.employer_profile }
  let(:benefit_sponsorship) { employer_profile.active_benefit_sponsorship }
  let!(:active_benefit_application) { benefit_sponsorship.current_benefit_application }
  let!(:renewing_benefit_application) { benefit_sponsorship.renewal_benefit_application }
  let!(:person){ FactoryGirl.create(:person, :with_family)}
  let!(:family) {person.primary_family}
  let!(:employee_role) { FactoryGirl.create(:benefit_sponsors_employee_role, person: person, employer_profile: employer_profile, census_employee_id: census_employee.id)}
  let!(:census_employee)  { FactoryGirl.create(:benefit_sponsors_census_employee, benefit_sponsorship: benefit_sponsorship, employer_profile: employer_profile ) }

  before do
    census_employee.update_attributes(:employee_role_id => employee_role.id )
  end

  describe "ModelEvent" do
    it "should trigger model event" do
      census_employee.class.observer_peers.keys.each do |observer|
        expect(observer).to receive(:notifications_send) do |instance, model_event|
          expect(model_event).to be_an_instance_of(::BenefitSponsors::ModelEvents::ModelEvent)
          expect(model_event).to have_attributes(:event_key => :employee_coverage_passive_renewal_failed, :klass_instance => census_employee, :options => {event_object: renewing_benefit_application})
        end
      end
      census_employee.trigger_model_event(:employee_coverage_passive_renewal_failed, {event_object: renewing_benefit_application})
    end
  end

  describe "NoticeTrigger" do
    context "when renewal employee auto renewal" do
      subject { BenefitSponsors::Observers::CensusEmployeeObserver.new }

      let(:model_event) { ::BenefitSponsors::ModelEvents::ModelEvent.new(:employee_coverage_passive_renewal_failed, census_employee, {event_object:renewing_benefit_application}) }

      it "should trigger notice event" do
        expect(subject.notifier).to receive(:notify) do |event_name, payload|
          expect(event_name).to eq "acapi.info.events.employee.employee_coverage_passive_renewal_failed"
          expect(payload[:employee_role_id]).to eq census_employee.employee_role.id.to_s
          expect(payload[:event_object_kind]).to eq 'BenefitSponsors::BenefitApplications::BenefitApplication'
          expect(payload[:event_object_id]).to eq renewing_benefit_application.id.to_s
        end
        subject.notifications_send(census_employee, model_event)
      end
    end
  end

  describe "NoticeBuilder" do

    let(:data_elements) {
      [
        "employee_profile.notice_date",
        "employee_profile.employer_name",
        "employee_profile.benefit_application.renewal_py_start_date",
        "employee_profile.benefit_application.renewal_py_oe_start_date",
        "employee_profile.benefit_application.renewal_py_oe_end_date",
        "employee_profile.broker.primary_fullname",
        "employee_profile.broker.organization",
        "employee_profile.broker.phone",
        "employee_profile.broker.email",
        "employee_profile.broker_present?"
      ]
    }

    let(:merge_model) { subject.construct_notice_object }
    let(:recipient) { "Notifier::MergeDataModels::EmployeeProfile" }
    let!(:template)  { Notifier::Template.new(data_elements: data_elements) }

    let!(:payload)   { {
      "event_object_kind" => "BenefitSponsors::BenefitApplications::BenefitApplication",
      "event_object_id" => renewing_benefit_application.id
    } }

    context "when notice event received" do
      subject { Notifier::NoticeKind.new(template: template, recipient: recipient) }

      before do
        allow(subject).to receive(:resource).and_return(census_employee.employee_role)
        allow(subject).to receive(:payload).and_return(payload)
        renewing_benefit_application.update_attributes(:predecessor_id => active_benefit_application.id )
        census_employee.trigger_model_event(:employee_coverage_passive_renewal_failed, {event_object: renewing_benefit_application})
      end

      it "should retrun merge model" do
        expect(merge_model).to be_a(recipient.constantize)
      end

      it "should return the date of the notice" do
        expect(merge_model.notice_date).to eq TimeKeeper.date_of_record.strftime('%m/%d/%Y')
      end

      it "should return employer name" do
        expect(merge_model.employer_name).to eq employer_profile.legal_name
      end

      it "should return renewal plan year start date" do
        expect(merge_model.benefit_application.renewal_py_start_date).to eq renewing_benefit_application.start_on.strftime('%m/%d/%Y')
      end

      it "should return renewal plan year open enrollment start date" do
        expect(merge_model.benefit_application.renewal_py_oe_start_date).to eq renewing_benefit_application.open_enrollment_start_on.strftime('%m/%d/%Y')
      end

      it "should return renewal plan year open enrollment end date" do
        expect(merge_model.benefit_application.renewal_py_oe_end_date).to eq renewing_benefit_application.open_enrollment_end_on.strftime('%m/%d/%Y')
      end

      it "should return false when there is no broker linked to employer" do
        expect(merge_model.broker_present?).to be_falsey
      end
    end
  end
end