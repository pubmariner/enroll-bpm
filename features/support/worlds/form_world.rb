module FormWorld
  def fill_in_admin_create_plan_year_form
    first_element = find("#baStartDate > option:nth-child(2)").text
    select(first_element, :from => "baStartDate")
    find('#fteCount').set(5)
  end
end

World(FormWorld)

Then(/^the Create Plan Year form will auto-populate the available dates fields$/) do
  expect(find('#end_on').value.blank?).to eq false
  expect(find('#open_enrollment_end_on').value.blank?).to eq false
  expect(find('#open_enrollment_start_on').value.blank?).to eq false
end

Then(/^the Create Plan Year form submit button will be disabled$/) do
  expect(page.find("#adminCreatePyButton")[:class].include?("disabled")).to eq true
end

Then(/^the Create Plan Year form submit button will not be disabled$/) do
  expect(page.find("#adminCreatePyButton")[:class].include?("disabled")).to eq false
end

Then(/^the Create Plan Year option row will no longer be visible$/) do
  expect(page).to_not have_css('label', text: 'Effective Start Date')
  expect(page).to_not have_css('label', text: 'Effective End Date')
  expect(page).to_not have_css('label', text: 'Full Time Employees')
  expect(page).to_not have_css('label', text: 'Open Enrollment Start Date')
  expect(page).to_not have_css('label', text: 'Open Enrollment End Date')
end
