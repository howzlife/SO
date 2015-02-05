class Fax
  include Mongoid::Document
  field :recipient_name, type: String
  field :company_name, type: String
  field :fax_number, type: String
  field :subject, type: String
  field :content, type: String
  field :status, type: String

  validates_presence_of :recipient_name, :company_name, :fax_number, :subject, :content

  belongs_to :user
end
