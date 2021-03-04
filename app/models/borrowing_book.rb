class BorrowingBook < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum status: {pending: 0, approved: 1, canceled: 2, rejected: 3}

  scope :order_by_created_date, ->{order :created_at}

  scope :where_cur_user_deleted, ->(id){where(user_id: id).where(deleted: 0)}

  class << self
    def statuses_i18n
      statuses.each_with_object({}) do |(k, _), obj|
        obj[I18n.t("borrowing_book.status.#{k}")] = k
      end
    end
  end

  def status_i18n
    I18n.t("borrowing_book.status.#{status}")
  end

  def update_deleted
    update_column :deleted, 1
  end
end
