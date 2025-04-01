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
  FileName: 'test document1',
  FileTypes: 'text/plain',
  FileURLPath: 'userFiles/TestDocument1.pdf'
)

puts "Seed data set 1 created successfully! - 4 users (one of each type) and a sample file (already in the system)"

landlord2 = User.create(
  Email: 'landlord2@test.com',
  Password: 'test',
  FName: 'John2',
  LName: 'Doe2',
  Role: 'Landlord',
  CompanyName: 'Doe2 Property Management 2',
  TenantAddress: nil,
  PhoneNumber: '111-1234'
)

tenant2 = User.create(
  Email: 'tenant2@test.com',
  Password: 'test',
  FName: 'Jane2',
  LName: 'Smith2',
  Role: 'Tenant',
  TenantAddress: '456 Elm St 2',
  PhoneNumber: '111-4321'
)

mediator2 = User.create(
  Email: 'mediator2@test.com',
  Password: 'test',
  FName: 'Alice2',
  LName: 'Johnson2',
  Role: 'Mediator',
  PhoneNumber: '555-3333'
)

admin2 = User.create(
  Email: 'admin2@test.com',
  Password: 'test',
  FName: 'Adam2',
  LName: 'Admin2',
  Role: 'Admin',
  PhoneNumber: '555-2222'
)

# Creating a Mediator
mediator_user2 = Mediator.create(
  UserID: mediator2.UserID,
  Available: true,
  ActiveMediations: 0,
  MediationCap: 5
)

# Creating a File Draft
file_draft2 = FileDraft.create(
  CreatorID: landlord.UserID,
  FileName: 'test document 2',
  FileTypes: 'text/plain',
  FileURLPath: 'userFiles/testfile2.txt'
)

puts "Seed data set 2 created successfully! - 4 users (one of each type) and a sample file (already in the system)"
