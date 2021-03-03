module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  def sign_up; end

  def current_user
    @current_user ||= User.find_by id: session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  # check whether the borrowed book is pending status
  def status_pending? book_id
    @current_user.borrowing_books.find_by(book_id: book_id).pending?
  end
end
