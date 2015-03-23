class Plan
  include Mongoid::Document
  include Mongoid::Enum
  field :name, type: String
  field :max_monthly_po_count, type: Integer
  field :max_vendor_count, type: Integer

end
