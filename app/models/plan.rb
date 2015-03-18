class Plan
  include Mongoid::Document
  include Mongoid::Enum
  enum :type, [:trial, :basic_plan, :better_plan]
  field :effective_date, type: Date
  field :max_po_trial, type: Integer
  field :max_po_basic_plan, type: Integer
  field :max_po_better_plan, type: Integer
  field :max_vendor_trial, type: Integer
  field :max_vendor_basic_plan, type: Integer
  field :max_vendor_better_plan, type: Integer
  field :expires_at, type: Date
  belongs_to :subscription
  after_create :set_variables

  def set_variables
  	update_attribute(:max_po_trial, 50)
  	update_attribute(:max_po_basic_plan, 100)
  	update_attribute(:max_po_better_plan, 200)
  	update_attribute(:max_vendor_trial, 5)
  	update_attribute(:max_vendor_basic_plan, 30)
  	update_attribute(:max_vendor_better_plan, 50)
  	update_attribute(:effective_date, Date.today)
  end

end
