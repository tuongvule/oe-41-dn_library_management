module SessionsHelper
  def log_in
    session[:user_id] = 2
  end

  def current_users
    user_id = session[:user_id]
    @current_user = User.find_by id: user_id
  end

  # check whether the borrowed book is pending status
  def status_pending? book_id
    @current_user.borrowing_books.find_by(book_id: book_id).pending?
  end
end
