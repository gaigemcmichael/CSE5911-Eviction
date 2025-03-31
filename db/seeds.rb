# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

# Creating Users (Landlord, Tenant, Mediator, Admin)
landlord = User.create(
  Email: 'landlord@test.com',
  Password: 'test',
  FName: 'John',
  LName: 'Doe',
  Role: 'Landlord',
  CompanyName: 'Doe Property Management',
  TenantAddress: nil,
  PhoneNumber: '555-1234'
)

tenant = User.create(
  Email: 'tenant@test.com',
  Password: 'test',
  FName: 'Jane',
  LName: 'Smith',
  Role: 'Tenant',
  TenantAddress: '456 Elm St',
  PhoneNumber: '555-5678'
)

mediator = User.create(
  Email: 'mediator@test.com',
  Password: 'test',
  FName: 'Alice',
  LName: 'Johnson',
  Role: 'Mediator',
  PhoneNumber: '555-9876'
)

admin = User.create(
  Email: 'admin@test.com',
  Password: 'test',
  FName: 'Adam',
  LName: 'Admin',
  Role: 'Admin',
  PhoneNumber: '555-1111'
)

# Creating a Mediator
mediator_user = Mediator.create(
  UserID: mediator.UserID,
  Available: true,
  ActiveMediations: 0,
  MediationCap: 5
)

# Creating a File Draft
file_draft = FileDraft.create(
  CreatorID: tenant.UserID,
  FileName: 'test document',
  FileTypes: 'text/plain',
  FileURLPath: 'userFiles/testfile.txt'
)

landlord2 = User.create(
  Email: 'landlord2@test.com',
  Password: 'test',
  FName: 'Larry',
  LName: 'Lonald',
  Role: 'Landlord',
  CompanyName: 'Bofa Property Management',
  TenantAddress: nil,
  PhoneNumber: '740-565-3234'
)

tenant2 = User.create(
  Email: 'tenant2@test.com',
  Password: 'test',
  FName: 'Terry',
  LName: 'Terrel',
  Role: 'Tenant',
  TenantAddress: '456 Elm St',
  PhoneNumber: '614-455-5678'
)

mediator2 = User.create(
  Email: 'mediator2@test.com',
  Password: 'test',
  FName: 'Melony',
  LName: 'Marry',
  Role: 'Mediator',
  PhoneNumber: '816-695-9876'
)

admin2 = User.create(
  Email: 'admin2@test.com',
  Password: 'test',
  FName: 'Aaron',
  LName: 'Able',
  Role: 'Admin',
  PhoneNumber: '740-555-1321'
)

# Creating a Mediator
mediator_user2 = Mediator.create(
  UserID: mediator2.UserID,
  Available: true,
  ActiveMediations: 0,
  MediationCap: 5
)

puts "Seed data created successfully! - 8 users (one of each type) and a sample file (already in the system)"
