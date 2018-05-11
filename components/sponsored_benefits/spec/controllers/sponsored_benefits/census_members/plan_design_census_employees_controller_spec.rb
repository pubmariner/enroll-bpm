require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

module DataTablesAdapter
end

module SponsoredBenefits
  RSpec.describe CensusMembers::PlanDesignCensusEmployeesController, type: :controller, dbclean: :after_each do
    routes { SponsoredBenefits::Engine.routes }
    let(:valid_session) { {} }
    let(:current_person) { double(:current_person) }
    let(:broker) { double(:broker, id: 2) }
    let(:broker_role) { double(:broker_role, id: 3) }
    let(:broker_agency_profile_id) { "5ac4cb58be0a6c3ef400009b" }
    let!(:organization) { create(:sponsored_benefits_plan_design_organization, :with_profile, sic_code: '0197') }

    let(:broker_agency_profile) { double(:sponsored_benefits_broker_agency_profile, id: broker_agency_profile_id, persisted: true, fein: "5555", hbx_id: "123312",
                                    legal_name: "ba-name", dba: "alternate", is_active: true, organization: organization) }


    # This should return the minimal set of attributes required to create a valid
    # CensusMembers::PlanDesignCensusEmployee. As you add validations to CensusMembers::PlanDesignCensusEmployee, be sure to
    # adjust the attributes here as well.
    let(:valid_attributes) {
      skip("Add a hash of attributes valid for your model")
    }

    let(:invalid_attributes) {
      skip("Add a hash of attributes invalid for your model")
    }

    let(:plan_design_proposal) { organization.plan_design_proposals[0] }
    let(:employer_profile) { plan_design_proposal.profile }
    let(:benefit_sponsorship) { employer_profile.benefit_sponsorships[0] }
    let(:plan_design_census_employee) { create(:plan_design_census_employee, benefit_sponsorship_id: benefit_sponsorship.id) }
    let(:active_user) { double(:has_hbx_staff_role? => false) }

    before do
      allow(subject).to receive(:current_person).and_return(current_person)
      allow(subject).to receive(:active_user).and_return(active_user)
      allow(current_person).to receive(:broker_role).and_return(broker_role)
      allow(broker_role).to receive(:broker_agency_profile_id).and_return(broker_agency_profile.id)
    end

    describe "GET #index" do
      it "returns a success response" do
        get :index, { plan_design_proposal_id: plan_design_proposal.id }, valid_session
        expect(response).to be_success
      end
    end

    describe "GET #show" do
      it "returns a success response" do
        get :show, { plan_design_proposal_id: plan_design_proposal.id, :id => plan_design_census_employee.to_param }, valid_session
        expect(response).to be_success
      end
    end

    describe "GET #new" do
      it "returns a success response" do
        xhr :get, :new, plan_design_proposal_id: plan_design_proposal.id, format: :js
        expect(assigns(:census_employee)).to be_a(SponsoredBenefits::CensusMembers::PlanDesignCensusEmployee)
        expect(response).to be_success
        expect(response).to render_template('new')
      end

      context "upload" do
        it "returns a success response" do
          xhr :get, :new, plan_design_proposal_id: plan_design_proposal.id, modal: "upload", format: :js
          expect(assigns(:census_employee)).to be_a(SponsoredBenefits::CensusMembers::PlanDesignCensusEmployee)
          expect(response).to be_success
          expect(response).to render_template('upload_employees')
        end
      end
    end

    describe "GET #edit" do

      it "returns a success response" do
        xhr :get, :edit, plan_design_proposal_id: plan_design_proposal.id, :id => plan_design_census_employee.to_param, format: :js
        expect(assigns(:census_employee)).to eq plan_design_census_employee
        expect(response).to be_success
        expect(response).to render_template('edit')
      end
    end

    describe "POST #create" do

      before(:each) do
        request.env["HTTP_REFERER"] = edit_organizations_plan_design_organization_plan_design_proposal_path(organization, plan_design_proposal)
      end

      let(:valid_attributes) {
        {
          "first_name"  => "John",
          "middle_name" => "",
          "last_name"   => "Chan",
          "dob"         => "12/01/1975",
          "name_sfx"    => "",
          "ssn"         => "",
          "address_attributes" => {
            "kind"=>"home", "address_1"=>"", "address_2"=>"", "city"=>"", "state"=>"", "zip"=>""
          },
          "email_attributes" => {
            "kind"=>"", "address"=>""
          },
          "census_dependents_attributes"=>{
            "0"=>{"first_name"=>"David", "middle_name"=>"", "last_name"=>"Chan", "dob"=>"2002-12-01", "employee_relationship"=>"child_under_26", "_destroy"=>"false", "ssn"=>""},
            "1"=>{"first_name"=>"Lara", "middle_name"=>"", "last_name"=>"Chan", "dob"=>"1979-12-01", "employee_relationship"=>"spouse", "_destroy"=>"false", "ssn"=>""}
          }
        }
      }

      context "with valid params" do

        it "creates a new CensusMembers::PlanDesignCensusEmployee" do
          expect {
            post :create, {plan_design_proposal_id: plan_design_proposal.id, census_members_plan_design_census_employee: valid_attributes}, valid_session
          }.to change(CensusMembers::PlanDesignCensusEmployee, :count).by(1)
        end

        it "creates a new CensusMembers::PlanDesignCensusEmployee with dependents" do
          post :create, {plan_design_proposal_id: plan_design_proposal.id, census_members_plan_design_census_employee: valid_attributes}, valid_session
          census_employee = CensusMembers::PlanDesignCensusEmployee.last
          expect(census_employee.census_dependents.size).to eq 2
          spouse = census_employee.census_dependents.detect{|cd| cd.employee_relationship == 'spouse'}
          child  = census_employee.census_dependents.detect{|cd| cd.employee_relationship == 'child_under_26'}
          expect(spouse.present?).to be_truthy
          expect(spouse.first_name).to eq "Lara"
          expect(child.present?).to be_truthy
          expect(child.first_name).to eq "David"
          expect(census_employee.address).to be_nil
          expect(census_employee.email).to be_nil
        end

        it "redirects to proposal edit page" do
          post :create, {plan_design_proposal_id: plan_design_proposal.id, census_members_plan_design_census_employee: valid_attributes}, valid_session
          expect(flash[:success]).to eq "Employee record created successfully."
          expect(response).to redirect_to edit_organizations_plan_design_organization_plan_design_proposal_path(organization, plan_design_proposal)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'new' template)" do
          valid_attributes["dob"] = nil
          post :create, {plan_design_proposal_id: plan_design_proposal.id, census_members_plan_design_census_employee: valid_attributes}, valid_session
          expect(flash[:error]).to eq "Unable to create employee record. [\"Dob can't be blank\", \"Dob can't be blank\"]"

          expect(response).to redirect_to edit_organizations_plan_design_organization_plan_design_proposal_path(organization, plan_design_proposal)
        end
      end
    end

    describe "PUT #update" do

      let(:new_attributes) {{
        "first_name"  => "John",
        "middle_name" => "",
        "last_name"   => "Chan",
        "dob"         => "12/01/1975",
        "name_sfx"    => "",
        "ssn"         => ""
        }}

      let(:address_attributes) {{ "kind"=>"home", "address_1"=>"", "address_2"=>"", "city"=>"", "state"=>"", "zip"=>"" }}
      let(:email_attributes) {{ "kind"=>"", "address"=>"" }}
      let(:census_dependents_attributes) {{
        "0"=>{"first_name"=>"David", "middle_name"=>"", "last_name"=>"Chan", "dob"=>"2002-12-01", "employee_relationship"=>"child_under_26", "_destroy"=>"false", "ssn"=>""},
        "1"=>{"first_name"=>"Lara", "middle_name"=>"", "last_name"=>"Chan", "dob"=>"1979-12-01", "employee_relationship"=>"spouse", "_destroy"=>"false", "ssn"=>""}
        }}

      let(:census_employee) { CensusMembers::PlanDesignCensusEmployee.create(new_attributes.merge(benefit_sponsorship: benefit_sponsorship)) }

      context "with valid params" do

        context "when dependent added" do

          it "should add dependents" do
            expect(census_employee.census_dependents).to be_empty
            xhr :put, :update, plan_design_proposal_id: plan_design_proposal.id, :id => census_employee.to_param, :census_members_plan_design_census_employee => new_attributes.merge(census_dependents_attributes: census_dependents_attributes), format: :js
            census_employee.reload
            expect(census_employee.census_dependents.size).to eq 2
            expect(response).to be_success
            expect(response).to render_template('update')
          end
        end

        context "when dependent deleted" do
          let(:census_employee) { CensusMembers::PlanDesignCensusEmployee.create(new_attributes.merge(census_dependents_attributes: census_dependents_attributes, benefit_sponsorship: benefit_sponsorship)) }
          let(:spouse) { census_employee.census_dependents.detect{|cd| cd.employee_relationship == 'spouse' } }
          let(:child) { census_employee.census_dependents.detect{|cd| cd.employee_relationship == 'child_under_26'} }
          let(:delete_dependents_attributes) {{
            "0"=>{"id"=> spouse.id.to_s, "first_name"=>"Lara", "middle_name"=>"", "last_name"=>"Chan", "dob"=>"1979-12-01", "employee_relationship"=>"spouse", "ssn"=>"", "_destroy"=>"false"},
            "1"=>{"id"=> child.id.to_s}
            }}

          it "should drop dependents" do
            expect(census_employee.census_dependents.size).to eq 2
            xhr :put, :update, plan_design_proposal_id: plan_design_proposal.id, :id => census_employee.to_param, :census_members_plan_design_census_employee => new_attributes.merge(census_dependents_attributes: delete_dependents_attributes), format: :js
            census_employee.reload
            expect(census_employee.census_dependents.size).to eq 1
            expect(census_employee.census_dependents.detect{|cd| cd.employee_relationship == 'child_under_26'}).to be_nil
          end
        end

        context "update employee or dependnet information" do
          let(:census_employee) { CensusMembers::PlanDesignCensusEmployee.create(new_attributes.merge(census_dependents_attributes: census_dependents_attributes, benefit_sponsorship: benefit_sponsorship)) }
          let(:spouse) { census_employee.census_dependents.detect{|cd| cd.employee_relationship == 'spouse' } }
          let(:child) { census_employee.census_dependents.detect{|cd| cd.employee_relationship == 'child_under_26'} }

          let(:updated_attributes) {{
            "first_name"  => "John",
            "middle_name" => "",
            "last_name"   => "Chan",
            "dob"         => "12/01/1978",
            "name_sfx"    => "",
            "ssn"         => "512141210",
            "address_attributes" => { "kind"=>"home", "address_1"=>"100 Bakers street", "address_2"=>"", "city"=>"Boston", "state"=>"MA", "zip"=>"01118" },
            "email_attributes" => { "kind"=>"home", "address"=>"john.chan@gmail.com" },
            "census_dependents_attributes" => {
              "0"=>{"id" => child.id.to_s, "first_name"=>"David", "middle_name"=>"Li", "last_name"=>"Chan", "dob"=>"2002-12-01", "employee_relationship"=>"child_under_26", "_destroy"=>"false", "ssn"=>""},
              "1"=>{"id" => spouse.id.to_s, "first_name"=>"Lara", "middle_name"=>"", "last_name"=>"Chan", "dob"=>"1980-12-01", "employee_relationship"=>"spouse", "_destroy"=>"false", "ssn"=>""}
              }
            }}

          it "should update employee and dependents information" do
            xhr :put, :update, plan_design_proposal_id: plan_design_proposal.id, :id => census_employee.to_param, :census_members_plan_design_census_employee => updated_attributes, format: :js
            census_employee.reload
            expect((census_employee.email.attributes.to_a & updated_attributes["email_attributes"].to_a).to_h).to eq updated_attributes["email_attributes"]
            expect((census_employee.address.attributes.to_a & updated_attributes["address_attributes"].to_a).to_h).to eq updated_attributes["address_attributes"]
            expect(census_employee.ssn).to eq updated_attributes["ssn"]
            expect(census_employee.census_dependents.detect{|cd| cd.employee_relationship == 'spouse' }.dob.strftime("%Y-%m-%d")).to eq "1980-12-01"
            expect(census_employee.census_dependents.detect{|cd| cd.employee_relationship == 'child_under_26'}.middle_name).to eq "Li"
          end
        end
      end
    end

    describe "DELETE #destroy" do
      # it "destroys the requested census_members_plan_design_census_employee" do
      #   plan_design_census_employee = CensusMembers::PlanDesignCensusEmployee.create! valid_attributes
      #   expect {
      #     delete :destroy, {:id => plan_design_census_employee.to_param}, valid_session
      #   }.to change(CensusMembers::PlanDesignCensusEmployee, :count).by(-1)
      # end

      # it "redirects to the census_members_plan_design_census_employees list" do
      #   plan_design_census_employee = CensusMembers::PlanDesignCensusEmployee.create! valid_attributes
      #   delete :destroy, {:id => plan_design_census_employee.to_param}, valid_session
      #   expect(response).to redirect_to(census_members_plan_design_census_employees_url)
      # end
    end

    describe ".bulk_employe_upload" do

    end

    describe ".expected_selection" do

    end
  end
end
