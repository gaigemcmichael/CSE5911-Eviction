# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 0) do
  create_table "ConversationMediators", primary_key: "MediatedConversationID", id: :integer, force: :cascade do |t|
    t.integer "MediatorID"
    t.integer "ConversationID"
    t.integer "AssignedByAdminID"
    t.datetime "AssignedAt", precision: nil, default: -> { "getdate()" }
  end

  create_table "FileAttachments", primary_key: ["FileID", "MessageID"], force: :cascade do |t|
    t.integer "FileID", null: false
    t.integer "MessageID", null: false
  end

  create_table "FileDrafts", primary_key: "FileID", id: :integer, force: :cascade do |t|
    t.integer "CreatorID"
    t.string "FileName", limit: 255, null: false
    t.string "FileTypes", limit: 100, null: false
    t.string "FileURLPath", limit: 500, null: false
    t.datetime "CreatedAt", precision: nil, default: -> { "getdate()" }
    t.datetime "UserDeletedAt", precision: nil
  end

  create_table "Mediators", primary_key: "UserID", id: :integer, default: nil, force: :cascade do |t|
    t.boolean "Available", null: false
    t.integer "ActiveMediations", default: 0
    t.integer "MediationCap", null: false
  end

  create_table "MessageStrings", primary_key: "ConversationID", id: :integer, force: :cascade do |t|
    t.datetime "CreatedAt", precision: nil, default: -> { "getdate()" }
    t.datetime "LastMessageSentDate", precision: nil
    t.varchar "Role", limit: 20
    t.check_constraint "[Role]='Side' OR [Role]='Primary'", name: "CK__MessageStr__Role__36470DEF"
  end

  create_table "Messages", primary_key: "MessageID", id: :integer, force: :cascade do |t|
    t.integer "ConversationID"
    t.integer "SenderID"
    t.datetime "MessageDate", precision: nil, default: -> { "getdate()" }
    t.text "Contents", null: false
    t.boolean "RequiresMediatorReview", default: false
  end

  create_table "PrimaryMessageGroups", primary_key: "ConversationID", id: :integer, default: nil, force: :cascade do |t|
    t.integer "TenantID"
    t.integer "LandlordID"
    t.datetime "CreatedAt", precision: nil, default: -> { "getdate()" }
    t.integer "LandlordScreeningID"
    t.integer "TenantScreeningID"
    t.boolean "GoodFaith", default: false
    t.boolean "MediatorRequested", default: false
    t.boolean "MediatorAssigned", default: false
    t.integer "MediatorID"
    t.boolean "EndOfConversationGoodFaithLandlord", default: false
    t.boolean "EndOfConversationGoodFaithTenant", default: false
  end

  create_table "ScreeningQuestions", primary_key: "ScreeningID", id: :integer, force: :cascade do |t|
    t.integer "UserID"
    t.boolean "InterpreterNeeded", null: false
    t.string "InterpreterLanguage", limit: 50
    t.boolean "DisabilityAccommodation", null: false
    t.text "DisabilityExplanation"
    t.boolean "ConflictOfInterest", null: false
    t.boolean "SpeakOnOwnBehalf", null: false
    t.boolean "NeedToConsult", null: false
    t.text "ConsultExplanation"
    t.text "RelationshipToOtherParty"
    t.boolean "Unsafe", null: false
    t.text "UnsafeExplanation"
  end

  create_table "SideMessageGroups", primary_key: ["UserID", "MediatorID", "ConversationID"], force: :cascade do |t|
    t.integer "UserID", null: false
    t.integer "MediatorID", null: false
    t.integer "ConversationID", null: false
  end

  create_table "UserActivityLogs", primary_key: "LogID", id: :integer, force: :cascade do |t|
    t.integer "UserID"
    t.integer "ReferenceID"
    t.string "ActionType", limit: 100, null: false
    t.string "ReferenceTable", limit: 100, null: false
    t.datetime "TimeStamp", precision: nil, default: -> { "getdate()" }
    t.string "IPAddress", limit: 50, null: false
  end

  create_table "Users", primary_key: "UserID", id: :integer, force: :cascade do |t|
    t.string "Email", limit: 255, null: false
    t.string "Password", limit: 255, null: false
    t.string "FName", limit: 100, null: false
    t.string "LName", limit: 100, null: false
    t.varchar "Role", limit: 20
    t.datetime "CreatedAt", precision: nil, default: -> { "getdate()" }
    t.string "CompanyName", limit: 255
    t.string "TenantAddress", limit: 255
    t.index ["Email"], name: "UQ__Users__A9D105341E486B7A", unique: true
    t.check_constraint "[Role]='Landlord' OR [Role]='Tenant' OR [Role]='Mediator' OR [Role]='Admin'", name: "CK__Users__Role__2EA5EC27"
  end

  add_foreign_key "ConversationMediators", "MessageStrings", column: "ConversationID", primary_key: "ConversationID", name: "FK__Conversat__Conve__3DE82FB7", on_delete: :cascade
  add_foreign_key "ConversationMediators", "Users", column: "AssignedByAdminID", primary_key: "UserID", name: "FK__Conversat__Assig__3EDC53F0"
  add_foreign_key "ConversationMediators", "Users", column: "MediatorID", primary_key: "UserID", name: "FK__Conversat__Media__3CF40B7E"
  add_foreign_key "FileAttachments", "FileDrafts", column: "FileID", primary_key: "FileID", name: "FK__FileAttac__FileI__5E54FF49"
  add_foreign_key "FileAttachments", "Messages", column: "MessageID", primary_key: "MessageID", name: "FK__FileAttac__Messa__5F492382"
  add_foreign_key "FileDrafts", "Users", column: "CreatorID", primary_key: "UserID", name: "FK__FileDraft__Creat__5A846E65", on_delete: :cascade
  add_foreign_key "Mediators", "Users", column: "UserID", primary_key: "UserID", name: "FK__Mediators__UserI__39237A9A", on_delete: :cascade
  add_foreign_key "Messages", "MessageStrings", column: "ConversationID", primary_key: "ConversationID", name: "FK__Messages__Conver__54CB950F", on_delete: :cascade
  add_foreign_key "Messages", "Users", column: "SenderID", primary_key: "UserID", name: "FK__Messages__Sender__55BFB948", on_delete: :cascade
  add_foreign_key "PrimaryMessageGroups", "MessageStrings", column: "ConversationID", primary_key: "ConversationID", name: "FK__PrimaryMe__Conve__477199F1", on_delete: :cascade
  add_foreign_key "PrimaryMessageGroups", "ScreeningQuestions", column: "LandlordScreeningID", primary_key: "ScreeningID", name: "FK__PrimaryMe__Landl__4B422AD5"
  add_foreign_key "PrimaryMessageGroups", "ScreeningQuestions", column: "TenantScreeningID", primary_key: "ScreeningID", name: "FK__PrimaryMe__Tenan__4C364F0E"
  add_foreign_key "PrimaryMessageGroups", "Users", column: "LandlordID", primary_key: "UserID", name: "FK__PrimaryMe__Landl__4959E263"
  add_foreign_key "PrimaryMessageGroups", "Users", column: "MediatorID", primary_key: "UserID", name: "FK__PrimaryMe__Media__5006DFF2", on_delete: :nullify
  add_foreign_key "PrimaryMessageGroups", "Users", column: "TenantID", primary_key: "UserID", name: "FK__PrimaryMe__Tenan__4865BE2A"
  add_foreign_key "ScreeningQuestions", "Users", column: "UserID", primary_key: "UserID", name: "FK__Screening__UserI__32767D0B", on_delete: :cascade
  add_foreign_key "SideMessageGroups", "MessageStrings", column: "ConversationID", primary_key: "ConversationID", name: "FK__SideMessa__Conve__44952D46", on_delete: :cascade
  add_foreign_key "SideMessageGroups", "Users", column: "MediatorID", primary_key: "UserID", name: "FK__SideMessa__Media__43A1090D"
  add_foreign_key "SideMessageGroups", "Users", column: "UserID", primary_key: "UserID", name: "FK__SideMessa__UserI__42ACE4D4"
  add_foreign_key "UserActivityLogs", "Users", column: "UserID", primary_key: "UserID", name: "FK__UserActiv__UserI__6225902D", on_delete: :cascade
end
