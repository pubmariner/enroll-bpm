require "rails_helper"

describe Subscribers::SsaVerification do

  it "should subscribe to the correct event" do
    expect(Subscribers::SsaVerification.subscription_details).to eq ["acapi.info.events.lawful_presence.ssa_verification_response"]
  end

  describe "given a ssa verification message to handle" do
    let(:individual_id) { "121211" }
    let(:xml) { File.read(Rails.root.join("spec", "test_data", "ssa_verification_payloads", "response.xml")) }
    let(:xml_hash) { {:response_code => "ss", :response_text => "Failed", :ssn_verification_failed => nil,
                      :death_confirmation => nil, :ssn_verified => "true", :citizenship_verified => "true",
                      :incarcerated => "false"} }
    let(:xml_hash2) { {:response_code => "ss", :response_text => "Failed", :ssn_verification_failed => "true" } }

    let(:person) { person = FactoryGirl.build(:person);
    consumer_role = person.build_consumer_role;
    consumer_role = FactoryGirl.build(:consumer_role);
    person.consumer_role = consumer_role;
    person.consumer_role.aasm_state=:verifications_pending;
    person
    }

    let(:payload) { {:individual_id => individual_id, :body => xml} }

    context "ssn_verified" do
      it "should approve lawful presence" do
        allow(subject).to receive(:xml_to_hash).with(xml).and_return(xml_hash)
        allow(subject).to receive(:find_person).with(individual_id).and_return(person)
        subject.call(nil, nil, nil, nil, payload)
        expect(person.consumer_role.aasm_state).to eq('fully_verified')
        expect(person.consumer_role.lawful_presence_determination.vlp_authority).to eq('vlp')
        expect(person.consumer_role.lawful_presence_determination.citizen_status).to eq(::ConsumerRole::US_CITIZEN_STATUS)
      end

      it "should save the response" do
        allow(subject).to receive(:xml_to_hash).with(xml).and_return(xml_hash)
        allow(subject).to receive(:find_person).with(individual_id).and_return(person)
        subject.call(nil, nil, nil, nil, payload)
        expect(person.consumer_role.lawful_presence_determination.ssa_verifcation_responses.count).to eq(1)
        expect(person.consumer_role.lawful_presence_determination.ssa_verifcation_responses.first.body).to eq(payload[:body])
      end
    end

    context "ssn_verification_failed" do
      it "should deny lawful presence" do
        allow(subject).to receive(:xml_to_hash).with(xml).and_return(xml_hash2)
        allow(subject).to receive(:find_person).with(individual_id).and_return(person)
        subject.call(nil, nil, nil, nil, payload)
        expect(person.consumer_role.aasm_state).to eq('verifications_outstanding')
        expect(person.consumer_role.lawful_presence_determination.vlp_authority).to eq('vlp')
        expect(person.consumer_role.lawful_presence_determination.citizen_status).to eq(::ConsumerRole::NOT_LAWFULLY_PRESENT_STATUS)
      end

      it "should save the response" do
        allow(subject).to receive(:xml_to_hash).with(xml).and_return(xml_hash2)
        allow(subject).to receive(:find_person).with(individual_id).and_return(person)
        subject.call(nil, nil, nil, nil, payload)
        expect(person.consumer_role.lawful_presence_determination.ssa_verifcation_responses.count).to eq(1)
      end
    end

  end
end
