class BorrowingBook < ApplicationRecord
  belongs_to :user
  belongs_to :book
  delegate :name, to: :user, prefix: :user
  delegate :title, to: :book, prefix: :book

  validates :borrowed_date, :expiration_date, presence: true

  validate :expiration_date_range

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

  private

  def expiration_date_range
    return if expiration_date.blank?

    if expiration_date < borrowed_date
      errors.add :expiration_date, I18n.t("must_be_after_borrowed_date")
    elsif expiration_date > borrowed_date + 30.days
      errors.add :expiration_date,
                 I18n.t("not_more_than_30_days_from_the_borrowed_date")
    end
  end

  def update_deleted
    update_column :deleted, 1
  end
end
