class BorrowingBookController < ApplicationController
  before_action :log_in
  before_action :current_user
  before_action :load_book, only: %i(send_request destroy_request)
  before_action :check_condition_borrow, only: :send_request
  before_action :borrowed_book, only: :send_request
  before_action :book_out_of_date, only: :send_request

  def index

    @borrowing_books = BorrowingBook.where_cur_user_deleted(@current_user.id)
                                    .order_by_created_date
                                    .page(params[:page]).per(1)

  end

  # If the book are on a pending status (be requested but not yet received the
  # book), so you can cancel the request for borrowing book. and then you must
  # update again the field: deleted = 1, and return the book to the book stock.
  def destroy_request
    borrowing_book = @current_user.borrowing_books
                                  .find_by(book_id: params[:book_id])

    borrowing_book.update_deleted
    update_quantity = @book.quantity + 1
    @book.update_quantity_book(update_quantity)

    flash[:success] = "destroy_request_successfully"
    redirect_to borrowing_book_index_path
  end

  # check whether the book is still in the warehouse; and sent_request_success
  def send_request
    if @book.quantity.zero?
      flash[:warning] = "book_out_of_stock"
      redirect_to root_path
    else
      sent_request_success
    end
  end

  private

  # Each user can only borrow up to 5 books.
  def check_condition_borrow
    return if @current_user.borrowing_books.count < 5

    flash[:danger] = t "over_quantity_to_borrow"
    redirect_to root_path
  end

  # Each user can only borrow 1 book per title.
  def borrowed_book
    return unless BorrowingBook.where_cur_user_deleted(@current_user.id)
                               .pluck(:book_id).include? params[:book_id].to_i

    flash[:danger] = t "borrowed_book"
    redirect_to root_path
  end

  # load_book before send_request and destroy_request
  def load_book
    @book = Book.find_by id: params[:book_id]
    return if @book

    flash[:danger] = t "error_find_book"
    redirect_to root_path
  end

  # each user must return the expired books before borrowing a new book
  def book_out_of_date
    BorrowingBook.where_cur_user_deleted(@current_user.id).each do |b|
      if b.expiration_date > Date.current + 1.day
        flash[:danger] = t "book_out_of_date"
        redirect_to root_path
      end
    end
  end

  # include: 1, create a new borrowing book with a term of 90 days.
  #          2, update quantiy of book to 1.
  def sent_request_success
    @borrowing_book = BorrowingBook
                      .create(borrowed_date: Date.current + 1.day,
                      expiration_date: Date.current + 91.days,
                      book_id: params[:book_id],
                      user_id: @current_user.id)
    update_quantity = @book.quantity - 1
    @book.update_quantity_book(update_quantity)

    flash[:success] = t "request_sent_successfully"
    redirect_to borrowing_book_index_path
  end
end
