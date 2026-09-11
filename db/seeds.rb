category_names = [ "Beauty", "Wellness", "Home Services", "Fitness", "Lessons", "Professional" ]
category_names.each { |name| Category.find_or_create_by!(name: name) }

admin = User.find_or_initialize_by(email: "admin@servicehub.test")
admin.assign_attributes(name: "Service Hub Admin", role: :admin, password: "password123", password_confirmation: "password123")
admin.save!

provider = User.find_or_initialize_by(email: "maya@servicehub.test")
provider.assign_attributes(name: "Maya Chen", role: :provider, password: "password123", password_confirmation: "password123")
provider.save!

profile = provider.provider_profile || provider.create_provider_profile!(business_name: "Maya Chen's Services")
profile.update!(business_name: "Maya Wellness Studio", bio: "Thoughtful wellness appointments for busy people.")

7.times do |day_of_week|
  slot = profile.availability_slots.find_or_initialize_by(day_of_week: day_of_week)
  slot.update!(starts_at: "00:00", ends_at: "23:59:59")
end

services = [
  { name: "Restorative massage", category: "Wellness", description: "A tailored 60-minute massage to ease tension and restore balance.", price: 95, duration: 60 },
  { name: "Deep tissue massage", category: "Wellness", description: "A focused 75-minute massage for persistent muscle tension.", price: 120, duration: 75 },
  { name: "Express facial", category: "Beauty", description: "A refreshing 30-minute facial for a quick skin reset.", price: 55, duration: 30 },
  { name: "Signature facial", category: "Beauty", description: "A personalized 60-minute facial with cleansing and hydration.", price: 90, duration: 60 },
  { name: "Personal training session", category: "Fitness", description: "A one-on-one workout session tailored to your goals.", price: 70, duration: 60 },
  { name: "Yoga coaching", category: "Fitness", description: "Private yoga instruction for strength, flexibility, and balance.", price: 65, duration: 60 },
  { name: "Home organization consult", category: "Home Services", description: "A practical consultation to plan a calmer, more functional home.", price: 80, duration: 60 },
  { name: "Beginner piano lesson", category: "Lessons", description: "A friendly private lesson covering rhythm, notes, and simple songs.", price: 45, duration: 45 },
  { name: "Career coaching session", category: "Professional", description: "A focused session to clarify your next career move and action plan.", price: 110, duration: 60 },
  { name: "Resume review", category: "Professional", description: "Detailed feedback to make your resume clearer and more compelling.", price: 60, duration: 45 }
]

services.each do |attributes|
  service = profile.services.find_or_initialize_by(name: attributes[:name])
  service.update!(
    category: Category.find_by!(name: attributes[:category]),
    description: attributes[:description],
    price: attributes[:price],
    duration: attributes[:duration],
    status: :active
  )
end
