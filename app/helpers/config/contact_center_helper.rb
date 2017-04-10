module Config::ContactCenterHelper
  def contact_center_address_one
    Settings.contact_center.address_one
  end

  def contact_center_alt_name
    Settings.contact_center.alt_name
  end

  def contact_center_alt_phone_number
    Settings.contact_center.phone_number
  end

  def contact_center_city
    Settings.contact_center.city
  end

  def contact_center_email_address
    Settings.contact_center.email_address
  end

  def contact_center_phone_number
    Settings.contact_center.phone_number
  end

  def contact_center_postal_code
    Settings.contact_center.postal_code
  end

  def contact_center_name
    Settings.contact_center.name
  end

  def contact_center_state
    Settings.contact_center.state
  end

  def contact_center_tty_number
    Settings.contact_center.tty_number
  end
end
