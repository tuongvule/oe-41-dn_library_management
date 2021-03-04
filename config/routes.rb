Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    get "borrowing_book/index"
    root to: "static_pages#home"
    post "send_request_to_borrow_book", to: "borrowing_book#send_request"
    post "destroy_request", to: "borrowing_book#destroy_request"

    namespace :admin do
       root to: "dash_board#home"
    end
  end
end
