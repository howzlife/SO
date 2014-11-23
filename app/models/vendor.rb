class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, (options[:message] || "is not an email") unless
      value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end
end

class Vendor
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :name, type: String
  field :email, type: String
  field :contact, type: String
  field :telephone, type: String
  field :fax, type: String
  include ActiveModel::Validations

  validates_presence_of :name

  validates :email, email: true, :allow_blank => true

  #for embedded documents, this will only check that the field is unique within...
  #the context of the parent document, not the entire database. 
  #We are setting this as unique within the company so we can use it to search for the right
  #vendor to add to the PO when a new PO is created.
  validates_uniqueness_of :name

  embedded_in :vendorable, polymorphic: true



end
