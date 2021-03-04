class Book < ApplicationRecord
  belongs_to :category
  belongs_to :publisher
  belongs_to :author

  has_many :borrowing_books, dependent: :nullify

  def update_quantity_book update_quantity
    update_column :quantity, update_quantity
  end
end
