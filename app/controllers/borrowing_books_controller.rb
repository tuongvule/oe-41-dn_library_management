class BorrowingBooksController < ApplicationController
  before_action :load_book, :check_quantity_zero, only: :new

  before_action :check_book, :check_quantity_book, :borrowed_book,
                :book_out_of_date, only: :create

  def new
    @borrowing_book = @current_user.borrowing_books.new
  end

  def index
    @borrowing_books =
      @current_user.borrowing_books.includes(:book).where(deleted: 0)
                   .order_by_created_date
                   .paginate(page: params[:page],
                   per_page: Settings.borrowing_book_controller.per_page)
  end

  def create
    @borrowing_book = @current_user.borrowing_books.new borrowing_book_params
    sent_request_success
  end

  private

  def check_quantity_book
    return if @current_user.borrowing_books.where(deleted: 0).count < 5

    flash[:danger] = t "over_quantity_to_borrow"
    redirect_to root_path
  end

  def borrowed_book
    return unless @current_user.borrowing_books.where(deleted: 0)
                               .pluck(:book_id)
                               .include? params[:borrowing_book][:book_id].to_i

    flash[:danger] = t "borrowed_book"
    redirect_to root_path
  end

  def load_book
    @book = Book.find_by id: params[:id]
    return if @book

    flash[:danger] = t "error_find_book"
    redirect_to root_path
  end

  def book_out_of_date
    @current_user.borrowing_books.each do |b|
      if b.expiration_date < Date.current + 1.day
        flash[:danger] = t "book_out_of_date"
        redirect_to root_path
      end
    end
  end

  def check_book
    @book = Book.find_by id: params[:borrowing_book][:book_id]
    return if @book

    flash[:danger] = t "error_find_book"
    redirect_to root_path
  end

  def sent_request_success
    ActiveRecord::Base.transaction do
      @borrowing_book.save!
      @book.update_quantity(@book.quantity - 1)
      flash[:success] = t "request_sent_successfully"
      redirect_to root_path
    end
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = t "request_sent_failed"
    render :new
  end

  def borrowing_book_params
    params.require(:borrowing_book).permit :borrowed_date,
                                           :expiration_date, :book_id
  end

  def check_quantity_zero
    return unless @book.quantity.zero?

    flash[:warning] = "book_out_of_stock"
    redirect_to root_path
  end
end
