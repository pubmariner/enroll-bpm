require File.join(File.dirname(__FILE__), "..", "..", "lib/mongoid_migration_task")

class ModifyBenefitApplication< MongoidMigrationTask

  def migrate
    action = ENV['action'].to_s

    case action
    when "cancel"
      cancel_benefit_application(benefit_applications_for_cancel)
    when "terminate"
      terminate_benefit_application(benefit_applications_for_terminate)
    when "reinstate"
      reinstate_benefit_application(benefit_applications_for_reinstate)
    when "update_aasm_state"
      update_aasm_state(benefit_applications_for_aasm_state_update)
    when "update_effective_period_and_approve"
      update_effective_period_and_approve(benefit_applications_for_aasm_state_update)
    end
  end

  def update_aasm_state(benefit_applications)

  end

  def reinstate_benefit_application(benefit_applications)

  end

  def update_effective_period_and_approve(benefit_applications)
    effective_date = Date.strptime(ENV['effective_date'], "%m/%d/%Y")
    new_start_date = Date.strptime(ENV['new_start_date'], "%m/%d/%Y")
    new_end_date = Date.strptime(ENV['new_end_date'], "%m/%d/%Y")
    oe_start_on = new_start_date.prev_month
    oe_end_on = oe_start_on+19.days
    raise 'new_end_date must be greater than new_start_date' if new_start_date >= new_end_date
    benefit_application = benefit_applications.where(:"effective_period.min" => effective_date, :aasm_state => :draft).first
    if benefit_application.present?
      benefit_application.update_attributes!(effective_period: new_start_date..new_end_date)
      benefit_application.update_attributes!(open_enrollment_period: oe_start_on..oe_end_on)
      benefit_application.approve_application!
    else
      raise "No benefit application found."
    end
  end

  def terminate_benefit_application(benefit_applications)
    termination_notice = ENV['termination_notice'].to_s
    termination_date = Date.strptime(ENV['termination_date'], "%m/%d/%Y")
    end_on = Date.strptime(ENV['end_on'], "%m/%d/%Y")
    benefit_applications.each do |benefit_application|
      service = initialize_service(benefit_application)
      service.terminate(end_on, termination_date)
      trigger_advance_termination_request_notice(benefit_application) if benefit_application.terminated? && (termination_notice == "true")
    end
  end

  def cancel_benefit_application(benefit_application)
    service = initialize_service(benefit_application)
    service.cancel
  end

  def benefit_applications_for_aasm_state_update

  end

  def benefit_applications_for_reinstate

  end

  def benefit_applications_for_terminate
    benefit_sponsorship = get_benefit_sponsorship
    benefit_sponsorship.benefit_applications.published_benefit_applications_by_date(TimeKeeper.date_of_record)
  end

  def benefit_applications_for_cancel
    benefit_sponsorship = get_benefit_sponsorship
    benefit_application_start_on = Date.strptime(ENV['plan_year_start_on'].to_s, "%m/%d/%Y")
    application = benefit_sponsorship.benefit_applications.where(:"effective_period.min" => benefit_application_start_on)
    raise "Found #{application.count} benefit applications with that start date" if application.count != 1
    application.first
  end

  def get_benefit_sponsorship
    fein = ENV['fein'].to_s
    organizations = BenefitSponsors::Organizations::Organization.where(fein: fein)
    if organizations.size != 1
      raise "Found no (OR) more than 1 organizations with the #{fein}" unless Rails.env.test?
    end
    organizations.first.active_benefit_sponsorship
  end

  def initialize_service(benefit_application)
    BenefitSponsors::BenefitApplications::BenefitApplicationEnrollmentService.new(benefit_application)
  end

  def trigger_advance_termination_request_notice(benefit_application)
    benefit_application.trigger_model_event(:group_advance_termination_confirmation)
  end
end

