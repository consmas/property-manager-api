# frozen_string_literal: true

ActiveRecord::Base.transaction do
  owner = User.find_or_initialize_by(email: "owner@propertymanager.local")
  owner.assign_attributes(
    full_name: "Platform Owner",
    phone: "+12025550100",
    role: :owner,
    password: "Password123!",
    password_confirmation: "Password123!"
  )
  owner.save!

  manager = User.find_or_initialize_by(email: "manager@propertymanager.local")
  manager.assign_attributes(
    full_name: "Main Property Manager",
    phone: "+12025550101",
    role: :property_manager,
    password: "Password123!",
    password_confirmation: "Password123!"
  )
  manager.save!

  accountant = User.find_or_initialize_by(email: "accountant@propertymanager.local")
  accountant.assign_attributes(
    full_name: "Finance Officer",
    phone: "+12025550102",
    role: :accountant,
    password: "Password123!",
    password_confirmation: "Password123!"
  )
  accountant.save!

  tenant_user = User.find_or_initialize_by(email: "tenant.one@propertymanager.local")
  tenant_user.assign_attributes(
    full_name: "Tenant One",
    phone: "+12025550103",
    role: :tenant,
    password: "Password123!",
    password_confirmation: "Password123!"
  )
  tenant_user.save!

  property = Property.find_or_initialize_by(code: "SUNSET001")
  property.assign_attributes(
    name: "Sunset Apartments",
    address_line_1: "450 Market Street",
    city: "San Francisco",
    state: "CA",
    country: "US",
    postal_code: "94105"
  )
  property.save!

  [
    [manager, :property_manager],
    [accountant, :accountant],
    [tenant_user, :tenant]
  ].each do |user, role|
    membership = PropertyMembership.find_or_initialize_by(user: user, property: property)
    membership.role = role
    membership.active = true
    membership.save!
  end

  unit_a = Unit.find_or_initialize_by(property: property, unit_number: "A-101")
  unit_a.assign_attributes(
    name: "A Block 101",
    unit_type: :two_bedroom_self_contain,
    status: :occupied,
    monthly_rent_cents: 185_000
  )
  unit_a.save!

  tenant = Tenant.find_or_initialize_by(property: property, email: "tenant.one@propertymanager.local")
  tenant.assign_attributes(
    user: tenant_user,
    full_name: "Tenant One",
    phone: "+12025550103",
    status: :active
  )
  tenant.save!

  lease = Lease.find_or_initialize_by(property: property, unit: unit_a, tenant: tenant, start_date: Date.current.beginning_of_month)
  lease.assign_attributes(
    end_date: Date.current.beginning_of_month.advance(months: 12),
    plan_months: 12,
    status: :active,
    rent_cents: unit_a.monthly_rent_cents,
    security_deposit_cents: 185_000
  )
  lease.save!

  Leases::GenerateRentSchedule.call(lease: lease) if lease.rent_installments.empty?

  reading = MeterReading.find_or_initialize_by(
    property: property,
    unit: unit_a,
    meter_type: :water,
    reading_date: Date.current.end_of_month
  )
  reading.assign_attributes(
    previous_reading: 120.5,
    current_reading: 132.75,
    rate_cents_per_unit: 1500,
    status: :finalized
  )
  reading.save!

  payment = Payment.find_or_initialize_by(reference: "PMT-SEED-001")
  payment.assign_attributes(
    property: property,
    tenant: tenant,
    received_by_user: accountant,
    payment_method: :bank_transfer,
    status: :posted,
    amount_cents: 185_000,
    unallocated_cents: 185_000,
    paid_at: Time.current,
    notes: "Seed payment"
  )
  payment.save!

  Payments::AllocateToInvoices.call(payment: payment) if payment.payment_allocations.empty?

  maintenance_request = MaintenanceRequest.find_or_initialize_by(property: property, title: "Kitchen tap leaking")
  maintenance_request.assign_attributes(
    unit: unit_a,
    tenant: tenant,
    reported_by_user: tenant_user,
    description: "The kitchen tap has a steady drip.",
    priority: :medium,
    status: :open,
    requested_at: Time.current
  )
  maintenance_request.save!
end

puts "Seed data loaded: owner@propertymanager.local / Password123!"
