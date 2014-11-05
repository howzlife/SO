class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  field :body, type: String

  validates_presence_of :body

  embedded_in :purchase_order


end
