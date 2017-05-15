Rails.application.routes.draw do
  root 'welcome#index'

  get 'welcome/index' => "welcome#index"

  # user authentication
  get 'users/signup' => 'users#signup_form', as: :signup
  post 'users/signup' => 'users#signup'
  get 'users/signin' => 'users#signin_form', as: :signin
  post 'users/signin' => 'users#signin'
  post 'users/signout' => 'users#signout', as: :signout
  get 'users/:id' => 'users#show', as: :show_user

  # item type
  get 'item_types/list' => 'item_types#list', as: :list_item_types
  get 'item_types/get_children' => 'item_types#get_children'
  post 'item_types/:id/delete' => 'item_types#delete', as: :delete_item_type
  get 'item_types/:id/show' => 'item_types#show', as: :show_item_type
  patch 'item_types/:id/edit' => 'item_types#edit', as: :edit_item_type
  get 'item_types/suggestions'

  # tags
  get 'tags/suggestions'
  get 'tags/list' => 'tags#list', as: :list_tags
  post 'tags/:id/delete' => 'tags#delete', as: :delete_tag
  post 'tags/:id/edit' => 'tags#edit', as: :edit_tag

  # expense entry
  get 'expense_entries/create' => 'expense_entries#create_form',
    as: :create_expense_entry
  post 'expense_entries/create' => 'expense_entries#create'
  get 'expense_entries/:id/show' =>  'expense_entries#show',
    as: :show_expense_entry
  patch 'expense_entries/:id/edit' => 'expense_entries#edit',
    as: :edit_expense_entry
  get 'expense_entries/list' => 'expense_entries#list',
    as: :list_expense_entries
  post 'expense_entries/:id/delete' => 'expense_entries#delete',
    as: :delete_expense_entry

  # expense report
  get 'expense_reports/criteria_form' => 'expense_reports#criteria_form',
    as: :expense_report_form
  get 'expense_reports/create' => 'expense_reports#create',
    as: :create_expense_report

  get 'expense_reports/create_v2' => 'expense_reports#create_v2'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
