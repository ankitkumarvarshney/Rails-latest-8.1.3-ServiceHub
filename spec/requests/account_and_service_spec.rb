require "rails_helper"

RSpec.describe "accounts and services" do
  it "registers customers and handles successful and failed sign in" do
    get new_registration_path
    expect(response).to have_http_status(:ok)

    post registrations_path, params: { user: { name: "New Customer", email: "new@example.test", password: "password123", password_confirmation: "password123", role: "customer" } }
    expect(response).to redirect_to(root_path)

    delete session_path
    post session_path, params: { email: "new@example.test", password: "wrong" }
    expect(response).to have_http_status(:unprocessable_entity)

    post session_path, params: { email: "new@example.test", password: "password123" }
    expect(response).to redirect_to(root_path)
  end

  it "lists services and lets providers manage their own services" do
    provider = create_user(role: :provider)
    service = create_service(provider: provider)

    get services_path, params: { q: "Massage", category_id: service.category_id }
    expect(response).to have_http_status(:ok)

    sign_in(provider)
    get new_service_path
    expect(response).to have_http_status(:ok)

    post services_path, params: { service: { name: "Consultation", description: "A practical consultation.", category_id: service.category_id, price: 50, duration: 30, status: "active" } }
    expect(response).to redirect_to(Service.last)

    patch service_path(service), params: { service: { name: "Updated massage" } }
    expect(response).to redirect_to(service)

    delete service_path(service)
    expect(response).to redirect_to(services_path)
  end
end
