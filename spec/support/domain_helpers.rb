module DomainHelpers
  def create_user(role: :customer, **attributes)
    User.create!(
      { name: "#{role.to_s.capitalize} User", email: "#{role}-#{SecureRandom.uuid}@example.test", password: "password123", password_confirmation: "password123", role: role }.merge(attributes)
    )
  end

  def create_service(provider:, **attributes)
    provider.provider_profile.services.create!(
      { name: "Massage", description: "A restorative appointment.", category: Category.find_or_create_by!(name: "Wellness"), price: 95, duration: 60, status: :active }.merge(attributes)
    )
  end

  def make_provider_available(provider, day: 1)
    provider.provider_profile.availability_slots.create!(day_of_week: day, starts_at: "09:00", ends_at: "17:00")
  end

  def sign_in(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
