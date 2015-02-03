class Fax
  include Mongoid::Document
  field :recipient_name, type: String
  field :company_name, type: String
  field :fax_number, type: String
  field :subject, type: String
  field :content, type: String

  belongs_to :user
end
