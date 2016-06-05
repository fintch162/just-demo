Rails.application.routes.draw do

  resources :bank_details

  resources :api_settings
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resource :welcome
  get "/auth/:action/callback", :to => "instructor/synchronize_contacts", :constraints => { :action => /twitter|google_oauth2/ }

  # match "/lightning-risk" => "welcome#global_lightning_risk", as: :global_lightning_risk, via: [ :get ]

  # match "/lightning-risk/:location" => "welcome#pool_info", as: :pool_info, via: [:get]
  # resources :live_notifications
  get 'live_notifications' => 'live_notifications#index'
  root :to => redirect('/manage')

  match "/sms"=>"welcome#instructors_sms",:as=> :instructors_sms,:via=>[:get]

  match '/do-payment' => "paypal_payments#connection", :as => :connection, via: [ :get ]
  match '/job/:id/:u_sec_number' => "welcome#success", :as => :success, via: [ :get ]
  match '/create-connection' => "paypal_payments#create", :as => :create, via: [ :get ]
  

  match "/swimming-lessons-registration" => "embed_registration_forms#new", :as => :embed_registration_form, via: [ :get ]

  match "/swimming-lessons-registration/generator" => "embed_registration_forms#generator", via: [ :get ]

  match "/swimming-lesson-registration/:id" => "embed_registration_forms#show", :as => :embed_registration_detail, via: [ :get ]  

  resources :payment_notifications
  match "/create_payment_notifications" => "payment_notifications#create_payment_notifications", :as => :create_payment_notifications, :via => [ :post ]
  match "/notify" => "payment_notifications#get_notification", :as => :get_notification, :via => [ :post ]
  match "/instructor_notify" => "payment_notifications#instructor_notification", :as => :instructor_notification, :via => [ :post ] 
  match "/sms_notification" => "payment_notifications#sms_status", :as => :sms_status_notificaion, :via => [:post] 
  match "/inst_sms_notification" => "payment_notifications#inst_sms_status", :as => :inst_sms_status_notificaion, :via => [:post] 
  match "/red_dot_notification" => "payment_notifications#red_dot_notification", :as => :red_dot_notification, :via => [:post]

  get '/red_dot/return_response_reddot_payment_red_dot'=> "payment_notifications#return_response_reddot_payment_red_dot", as: :red_dot_return_response
  get '/red_dot/return_response_reddot_payment_enets'=> "payment_notifications#return_response_reddot_payment_enets", as: :enets_return_response
 
  get "/profile/:name" => "instructor_publicly_visible#publicly_visible_inst_profile", :as => :public_instructor, via: :get


  namespace :manage do
    root "home#index"
   
    match "/swimming-lessons-registration/generator" => "generate_forms#generator", via: [ :get ]
    match '/jobs/:job_id/send_feedback_sms' => "jobs#send_feedback_sms", :as => :send_feedback_sms ,via: [ :get ]
    match '/jobs/:job_id/add/:payment_notification_id' => "jobs#add_payment_status", :as => :add_payment_status ,via: [ :get ]
    match '/jobs/:job_id/add_manual_payment' => "jobs#add_manual_payment", :as => :add_manual_payment ,via: [ :POST ]
    match '/jobs/:gc_id/:id/apply_group_class' => "jobs#apply_group_class", :as => :apply_group_class ,via: [ :get ]
    
    match "/send_msg_preview_manage" => "coordinator_messages#send_msg_preview_manage", :as => :send_msg_preview_manage, via: [:post]
 
    match '/student/:student/send_student_a_link_manage'=> "coordinator_messages#send_student_a_link_manage", :as=> :send_student_a_link_manage, via: [:post]
    
    match "/group_award_message_manage" => "coordinator_messages#group_award_message_manage", :as => :group_award_message_manage, via: [:post]
    
    # ----------------- JOB SHOW PAGE : ROUTE FOR ADD PAYMENT FROM JOB SHOW PAGE FOR PARTICULAR INVOICE ------------------- 
        # match "/get_freshbook_invoice" => "invoices#get_freshbook_invoice", :as => :get_freshbook_invoice, via: [:get]
    # ----------------- JOB SHOW PAGE : ROUTE FOR ADD PAYMENT FROM JOB SHOW PAGE FOR PARTICULAR INVOICE ------------------- 

    resources :coordinator, :only => [:edit ,:update] 
    resources :job_feedbacks, :only => [:index,:destroy] 

    match "/setting" => "home#api_list", :as => :setting, via: [:get]
    match "/filter-data" => "home#get_dashboard_data_filter", :as => :get_dashboard_data_filter, via: [ :get ]
    match "/update_api" => "home#update_api", :as => :update_api, via: [:post]
    
    match "/update/payment_info" => "online_payments#update_notification", :as => :update_notification, via: [:patch, :put]
    match "/create/payment_info" => "online_payments#create_notification", :as => :create_notification, via: [:post]
   
    resources :identity_cards
    resources :instructor_identities
    resources :rewards
    match "/find_instructor" => "rewards#find_instructor", :as => :find_instructor, via: [ :get ]

    resources :terms_and_conditions, :path => 'trems-and-conditions'

    resources :awards do
      collection { post :sort }
    end
    

    resources :canned_responses
    match "/get_canned_tmp" => "canned_responses#get_canned_tmp", via: [:post], :as => :get_canned_tmp
    resources :template_formulas
    resources :home, only: :index
    resources :venues
    resources :levels
    resources :payments
    resources :instructor_job_applications, only: [:destroy]
    resources :instructors do
      member do
        get :unlock_edit_mode
        get :lock_edit_mode
      end
    end

    match "/instructors/:id/job-taken" => "instructors#instructor_job_taken", :as => :instructor_job_taken , :via => [:get]

    resources :age_groups
    resources :reports
    resources :online_payments, :path => "/transactions"

    match "/date_wise_jobs" => "reports#date_wise_jobs", :as => :date_wise_jobs , :via => [:post]
    match "/detailed_view" => "reports#detailed_view", :as => :detailed_view , :via => [:get]
    match "/date_wise_started_jobs" => "reports#date_wise_started_jobs", :as => :date_wise_started_jobs , :via => [:post]

    match "job/new-lead" => "registration#new", :as => :swimming_lesson_registration, :via => [ :get ]
    match "job/edit-lead/:id" => "registration#edit", :as => :edit_lead, via: [:get]

    match "/award_tests" => "award_tests#index", :as => :award_tests, via: [:get]
    match "/award_test/new" => "award_tests#new", :as => :new_award_test , via: [:get]
    match "/create_award_test" => "award_tests#create", :as => :create_award_test, via: [:post]
    match "/award_test/:id" => "award_tests#show", :as => :award_test, via: [:get]
    match "/award_test/edit/:id"=> "award_tests#edit", :as => :edit_award_test, via: [:get]
    match "/award_test/update/:id" => "award_tests#update", :as => :update_award_test, via: [:patch, :put]
    match '/award_test/destroy/:id' => "award_tests#destroy", :as => :delete_award_test, via: [:delete]
    match '/award_test/transfer_student' => "award_tests#transfer_student", :as => :transfer_student, via: [:post]
    match '/award_test/remove_student/:id' => "award_tests#remove_student", :as => :remove_student, via: [:delete]
    match '/award_test/award_test_list/:id' => "award_tests#award_test_list", :as => :award_test_list, via: [:get]
    match '/award_test/award_test_list_bulk/:id' => "award_tests#award_test_list_bulk", :as => :award_test_list_bulk, via: [:get,:post]
    match "/award_test/confirm_student/:id/:value" => "award_tests#confirm_student", :as => :confirm_student, via: [:get]
    match "/search_by_nric" => "award_tests#search_student", :as => :search_by_nric, via: [:get]
    match "/add_award/:award_test/:studdent_id" => "award_tests#add_student_award", :as => :add_student_award, via: [:get]
    match "/search_classes/" => "group_classes#search_classes_instructor_wise", :as => :search_classes_instructor_wise, via: [:post]
    match "/search_beta" => "group_classes#group_class_beta_search", :as => :group_class_beta_search, via: [:post,:get]
    match "/group_class_beta" => "group_classes#group_class_beta", :as => :group_class_beta, via: [:get]
    match "/gorup_classes_by_venue" => "group_classes#gorup_classes_by_venue", :as => :gorup_classes_by_venue, via: [:get]
    match "/group_class_info/:id" => "group_classes#group_class_info", :as => :group_class_info, via: [:get]
    match "/destroy_from_edit/:id" => "group_classes#destroy_from_edit", :as => :destroy_from_edit, via: [:get]
    match "/change_booking_status/:id" => "group_classes#change_booking_status", :as => :change_booking_status, via: [:get]
    match "/book_group_class/:id" => "group_classes#book_group_class", :as => :book_group_class, via: [:get]

    resources :invoices do
      get "/update-invoice/:job" => :update_invoice, as: :update_invoice
    end
    
    match '/create_invoice/:id' => "invoices#create", :as => :invoice_create, via: [:get]
    match '/reset_invoice_time_popup/:id' => "invoices#reset_invoice_time_popup", :as => :reset_invoice_time_popup, via: [:get]
    match '/reset_invoice_time/:id' => "invoices#reset_invoice_time", :as => :reset_invoice_time, via: [:get]
    match '/clear_invoice_time/:id' => "invoices#clear_invoice_time", :as => :clear_invoice_time, via: [:get]
    match "/invoice" => "invoices#freshbook_invoice", :as => :freshbook_invoice, via: [:get]
    # match "/jobs/:id/c-invoice" => "invoices#job_create_invoice", :as => :job_create_invoice, via: [:get]

    resources :jobs
    match "/send_message_as_mail" => "jobs#send_message_as_mail", as: :send_message_as_mail, :via => [ :post ]
    match '/confirm_jobs' => "jobs#confirm_job", :as => :confirm_job, via: [:get]
    match '/confirm_job_invoice/:id' => "jobs#confirm_job_invoice", :as => :confirm_invoice, via: [:get]
    match '/job/group_search' => "jobs#group_search_venue_age_group", :as => :group_search, via: [:get]
    match '/:id/payment/:u_sec_number' => "jobs#sms_payment", :as => :sms_payment, via: [:get]
    # match '/:id/send-payment-info' => "jobs#s_sms_payment_link", :as => :s_sms_payment_link, via: [:get]
    get "/instructor_load_more_message" => "jobs#instructor_load_more_message", :as => :instructor_load_more_message
    get "/customer_load_more_message" => "jobs#customer_load_more_message", :as => :customer_load_more_message
    

    post ":job/generate_pdf" => "jobs#generate_pdf_job", :as => :generate_pdf_job
    get ":job/print-details" => "jobs#print_details", :as => :print_details


    resources :message_templates do
      collection { get :get_invoice_note }
    end
    match "/webhook" => "message_templates#webhook", :as => :webhook, via: [:get]
    match "/get_template_on_generate_sms" => "message_templates#get_template_on_generate_sms" , :as => :get_template_on_generate_sms , via: [:get]
    match "/instructor_take_job" => "jobs#instructor_take_job", :as => :instructor_take_job, via: [:get]
    
    get 'sandbox' => "sandbox#sandbox"


    match '/freshbooks_inoivce' => 'freshbooks#index', :as => :freshbooks_invoice, via: [:get]
    match '/invoice_next_page' => "freshbooks#manage_invoice_next", :as => :invoice_next_page, via: [:get]
    match '/manage_invoice_prev' => "freshbooks#manage_invoice_prev", :as => :invoice_prev_page, via: [:get]
    
    resources :messages, except: [:destroy]  do
      collection { post :import }
      collection do
        delete :remove_all
      end
    end
    get "conversations-messages/search" => "coordinator_messages#search"
    match "/disconnect" => "db_messages#disconnect_telerivet_account", :as => :disconnect_telerivet_account, via: [:get]

    get "db_messages/incoiming_mesg_from_db_json"
    get "db_messages/outgoing_mesg_from_db_json"

    match "/send_new_message_from_conversation" => "db_messages#send_new_message_from_conversation", :as => :send_new_message_from_conversation, via: [:post]
    match "/message/incoming_messages" => "db_messages#incoiming_mesg_from_db", :as => :db_incoming_message, via: [:get]
    match "/message/outgoing_messages" => "db_messages#outgoing_mesg_from_db", :as => :db_outgoing_message, via: [:get]
    match "/message/job_view_message_conversation" => "db_messages#job_view_message_conversation", :as => :job_view_message_conversation, via: [:get]
    match "/message/job_view_customer_conversation" => "db_messages#job_view_customer_conversation", :as => :job_view_customer_conversation, via: [:get]
    match "/message/conversation/:phone_number" => "db_messages#conversation_message", :as => :conversation_message, via: [:get]
    match "/set_unread/:id" => "db_messages#set_unread", :as => :set_unread, via: [:get]

    match "/load_more_messages" => "messages#load_more_messages" , :as => :load_more_messages , via: [ :get ]
    match "/cust_load_msg" => "messages#cust_load_msg" , :as => :cust_load_msg , via: [ :get ]
    match "/load_msg" => "messages#load_msg" , :as => :load_msg , via: [ :get ]
    match "/next_conversation" => "messages#next_page" , :as => :next_page , via: [ :get ]
    match "/prev_conversation" => "messages#prev_page" , :as => :prev_page , via: [ :get ]
    match "/job_conversation" => "messages#job_conversation" , :as => :job_conversation , via: [ :get ]
    match "/customer_job_conversation" => "messages#customer_job_conversation" , :as => :customer_job_conversation , via: [ :get ]
    match "/job_message_send" => "messages#job_message_send" , :as => :job_message_send , via: [ :get ]
    match "/outgoing_messages" => "messages#outgoing_messages" , :as => :outgoing_messages , via: [:get]
    match "/incoming_messages" => "messages#incoming_messages" , :as => :incoming_messages , via: [:get]
    match "/unread_messages" => "messages#unread_messages" , :as => :unread_messages , via: [:get]
    match "/individual_message/:to_number" => "messages#individual_message" , :as => :individual_message , via: [:get]
    match "/get_instructor" => "messages#get_instructor" , :as => :get_instructor , via: [:get]
    match "conversastion/:to_number" => "messages#conversastions_messages" , :as => :conversastions_messages , via: [:get]


    resources :group_classes do
      collection do
        get "group_classes/add_new_class"
        post '/apply-group-class-detail-to-job' => 'group_classes#apply_group_class_detail_to_job'
        post '/remove-group-class-detail-from-job' => 'group_classes#remove_group_class_detail_from_job'
      end
    end

    match "/search" => "group_classes#group_classes_search", :as => :group_classes_search, via: [:post]

    match ':online_payment/make-payment' => "online_payments#make_payment_for_invoice", as: :make_payment_for_invoice, via: [ :get ]
  
    resources :manual_payments do
      collection { 
        post :sort
      }
      member do 
        get :add_payment
        get :remove_payment
      end
    end
    match ':payment_id/save-online-payments-to-manual-payments' => "online_payments#save_online_payments_to_manual_payments", as: :save_online_payments_to_manual_payments, via: [ :get ]

    resources :award_tests do
      collection { post :sort }
      member do 
        post :sort_student
        post :bulck_confirm
        post :bulck_pass
        post :bulk_fail
        post :bulk_delete
      end
    end

    match "/manual-payments/uncommitted" => "manual_payments#uncommitted_payments", via: [ :get ], as: :uncommitted_manual_payments
    match "/manual-payments/:payment_desc" => "manual_payments#manual_payments_filter", via: [ :get ], as: :manual_payments_filter
    match "/find-manual-payment-by-date" => "manual_payments#find_manual_payment_by_date", via: [ :get ], as: :find_manual_payment_by_date
  end
  
  match "/booking_schedule_search" => "welcome#booking_schedule_search", :as => :booking_schedule_search, via: [:get]
  match "/booking-schedule" => "welcome#booking_schedule", :as => :booking_schedule, via: [:get]
  match "/feedback/:id" => "job_feedbacks#new", :as => :feedback, via: [:get]
  resources :job_feedbacks, :only => [:create]
  
  match 'jobs/:id/:u_sec_number' => "welcome#view_pa", :as => :view_pa, via: [ :get ]
  match 'student/:secret_token/payment_options/:id' => "welcome#view_payment_option_student", :as => :payment_options, via: [ :get ]
  match 'student/:secret_token/current_month_fee' => "welcome#current_month_fee", :as => :current_month_fee, via: [ :get ]
  match 'student/:secret_token/award_test_payment_options/:id' => "welcome#view_payment_option_award_test_student", :as => :award_test_payment_options, via: [ :get ]
  match 'jobs/:id/bank_transferred' => "welcome#bank_transferred", :as => :bank_transferred, via: [ :post ]
  
  match 'student/:secret_token' => "welcome#student_public_link", :as => :student_public_link, via: [:get]
  match 'student/gallery/:secret_token' => "welcome#student_public_gallery", :as => :student_public_gallery, via: [:get]
  match 'student/:secret_token/edit' => "welcome#edit_student", :as => :edit_student, via: [:get]
  match 'update_student' => "welcome#update_student", :as => :update_student, via: [:patch]
  match '/student/:secret_token/test-registration' => "welcome#test_registration", :as => :test_registration, via: [ :get ]
  # match "/public_studetn_profile/id" => "welcome#profile_upload", via: [:post]
  
  namespace :instructor do
    get '/red_dot/return_response_reddot_card'=> "fee_payment_notifications#return_response_reddot_card", as: :fee_red_dot_return_response
    get '/red_dot/return_response_eNets'=> "fee_payment_notifications#return_response_eNets", as: :fee_eNets_return_response
    resources :fee_payment_notifications, only: [:index,:show]
    resources :award_test_payment_notifications, only: [:index]
    match "/fee_red_dot_notification" => "fee_payment_notifications#fee_red_dot_notification", :as => :fee_red_dot_notification, :via => [:post]
    match "/check_payment_status" => "fee_payment_notifications#check_payment_status", :as => :check_payment_status, :via => [:get]
    match '/update_instructor_student_award' => 'home#update_instructor_student_award_status', as: :update_student_award_status, via: [ :put, :get, :post ]
    match '/remove_instructor_student_award' => 'home#remove_training_instructor_student_award', as: :remove_student_award, via: [:get]
    match '/synchronize_contacts_list' => 'synchronize_contacts#index', as: :synchronize_contacts_list, via: [:get]
    match '/synchronize_contact/:id' => 'synchronize_contacts#synchronize_contact', as: :synchronize_contact, via: [:get]

    match '/synchronize_contacts' => 'synchronize_contacts#synchronize_contacts', as: :synchronize_contacts, via: [:get, :post]

    match '/automatically_synchronize_contacts' => 'synchronize_contacts#automatically_synchronize_contacts', as: :automatically_synchronize_contacts, via: [:get, :post]

    match '/remove_synchronized_contacts' => 'synchronize_contacts#remove_synchronized_contacts', as: :remove_synchronized_contacts, via: [:get, :post]
    match '/update_contact_on_google/:id' => 'synchronize_contacts#update_contact_on_google', as: :update_google_contact, via: [:get]
    match '/update_student_contacts' => 'synchronize_contacts#update_student_contacts_after_login', as: :update_student_contacts, via: [:get]
    root "home#dashboard"
   
    resources :group_classes, only: [:destroy] do
      member do
        put :update_slot_vacancy
      end
      match  '/get_fee_data/:student_id' => 'home#get_fee_data', :as => :get_fee_data, via: [ :get ]
    end

    # patch '/update_instructor_student_award' => 'home#update_instructor_student_award_status', as: :update_student_award_status 
    match  '/remove-fee/:fee' => 'home#remove_fee', :as => :remove_fee, via: [ :get ]
    match  '/group_classes_deatil_print' => 'home#group_classes_deatil_print', :as => :group_classes_deatil_print, via: [ :get ]
    match  '/transfer-student/:transfer' => 'home#transfer_modal', :as => :transfer_modal, via: [ :get ]
    match  '/edit-per-course-fee/:fee' => 'home#edit_per_course_fee', :as => :edit_per_course_fee, via: [ :get ]

    match  '/transfer-in' => 'home#transfer_student_in', :as => :transfer_student_in, via: [ :post ]
    match  '/:transfer/transfer-reject' => 'home#reject_transfer_student', :as => :reject_transfer_student, via: [ :get ]

    resources :groups
    resources :student_identities, :only => [:destroy]
    match  '/sort' => 'groups#sort', :as => :group_sort, via: [:post]

    match "/:instructor/create_company" => "company_details#create_company", :as => :create_company, via: [ :get ]

    resources :home, only: [:new, :create, :edit, :update, :destroy, :show]
    match "save-font-size" => "home#save_font_size", :as => :save_font_size, via: [ :get ]

    match "/group-class" => "home#index", :as => :group_classes_index, via: [:get]
    resources :award_tests do
      member do 
        match '/remove_student/:student_id' => "award_tests#remove_student", :as => :remove_student_from_award_test, via: [:delete]
        match '/paid_remove_popup/:student_award_id' => "award_tests#paid_remove_popup", :as => :award_test_paid_remove_popup, via: [:get]
        match '/make_payment_in_cash/:student_id' => "award_tests#make_payment_in_cash", :as => :award_test_cash_payment, via: [:get]
      end
    end
    match '/award_test/return_response_reddot_card' => "award_tests#return_response_reddot_card", :as => :return_response_reddot_card_award_test, via: [:get]
    match '/award_test/return_response_eNets' => "award_tests#return_response_eNets", :as => :return_response_reddot_eNets_award_test, via: [:get]
    match '/award_test_red_dot_notification' => "award_tests#award_test_red_dot_notification", :as => :award_test_red_dot_notification, via: [:post]

    match "/search" => "instructor_students#search_result", :as => :search_result, via: [:get]
    match "/bulk_remove" => "instructor_students#bulk_remove", :as => :bulk_remove, via: [:get]

    resources :instructor_student_photos
    match "/instructor_student_photos/add_tags" => "instructor_student_photos#add_tags", :as => :add_tags, via: [:post]
    match "/instructor_student_photos/tagging_form/:id" => "instructor_student_photos#tagging_form", :as => :tagging_form, via: [:post,:get]
    resources :instructor_students do
      resources :galleries do 
          resources :photos
          resources :videos
      end

      resources :fees, only: [:new, :create, :edit, :update, :destroy]
      collection { 
        post :sort
      }
      member do 
        get :restore_student
      end 
    end
    resources :instructor_messages, only: [:index]
    match "/quick-add-fee" => "fees#quick_add_fee", :as => :quick_add_fee, via: [:get]
    match "/bulk_invoice_month_selection" => "fees#bulk_invoice_month_selection", :as => :bulk_invoice_month_selection, via: [:get]
    match "/bulk_invoice_detail" => "fees#bulk_invoice_detail", :as => :bulk_invoice_detail, via: [:get,:post]
    match "/set_bulk_invoice" => "fees#set_bulk_invoice", :as => :set_bulk_invoice, via: [:get,:post]
    
    match ":id/save_additional_description_about_student" => "instructor_students#save_additional_description_about_student", :as => :save_additional_description_about_student, via: [:post]
    match "/filter-by-selected-award" => "instructor_students#filter_instructor_students_by_selected_award", :as => :filter_instructor_students_by_selected_award, via: [:get]

    match "instructor-students/add-more-months-fee" => "instructor_students#add-more-months-fee", as: :add_more_months_fee, via: [ :get ]

    get 'dashboard' => "home#dashboard"
    post 'add_student_from_dashboard' => 'instructor_students#add_student_from_dashboard'
    
    match '/instructor_messages/set_sms_unread/:id'=> "instructor_messages#set_sms_unread", :as=> :set_sms_unread, via: [:get]
    match '/instructor_messages/inst_send_message'=> "instructor_messages#inst_send_message", :as=> :send_sms, via: [:post]
    match '/instructor_messages/inst_conversation_sms/:id'=> "instructor_messages#inst_conversation_messages", :as=> :conversation, via: [:get]
    match '/instructor_messages/unread_conversations'=> "instructor_messages#unread_conversations", :as=> :unread_conversations, via: [:get]
    match '/instructor_messages/outgoing'=> "instructor_messages#inst_outgoing_messages", :as=> :instructor_outing_messages, via: [:get]
    match '/instructor_messages/incoming'=> "instructor_messages#inst_incoming_messages", :as=> :instructor_incoming_messages, via: [:get]
    match '/student/:student/send_student_a_link'=> "instructor_messages#send_student_a_link", :as=> :send_student_a_link, via: [:post]

    match '/check_for_message_telerivet_sms_settings'=> "instructor_messages#check_for_message_telerivet_sms_settings", :as=> :check_for_message_telerivet_sms_settings, via: [:get]

    match 'instructor_student/transfer' => "instructor_students#tansfer_out", :as => :transfer_student, via: [:post]
    resources :fees, only: [:index, :show]
      match 'profile' => "instructor_profile#edit", :as => :profile, :via => [ :get]
      match 'profile/edit' => "instructor_profile#update", :via => [ :put, :patch ], :as => :update_profile
      match 'export' => "instructor_profile#export", :as => :export_data, :via => [ :get]
      match 'update_daily_backup_email_setting' => "instructor_profile#update_daily_backup_email_setting", :as => :update_daily_backup_email_setting, :via => [ :get]
    match "/opportunity" => "home#opportunity", :as => :opportunity, via: [:get]

    match "/:id/add-to-group-class" => "group_classes#add_to_group_class", :as => :add_to_group_class, via: [:get]

    match "/referrals" => "home#referrals", :as => :referrals, via: [:get]
    match "/student/:id/award/:award_id/get-register-award-test" => "home#register_for_test", :as => :register_for_test, via: [:get]
    match "/student/:id/award/:award_id/get-unregister-award-test" => "home#unregister_for_test", :as => :unregister_for_test, via: [:get]
    
    post "home/get_registered_for_test"
    
    match "/check_availablity_for_test/:id" => "home#check_availablity_for_test" , :as => :check_availablity_for_test, via: [:get]
    match "/apply_for_job" => "home#apply_for_job", :as => :apply_for_job , via: [:post]
    match "/add_student_to_gp" => "group_classes#add_student_to_gp", :as => :add_student_to_gp , via: [ :post ]

    # match "/group_class/:id" => "home#show", :as => :group_class_view, via: [:get]
    match "/unpaid_fee_student" => "home#unpaid_fee_student", as: :unpaid_fee_student, via: [ :get ,:post ]
    match "/unregistered_students" => "home#unregistered_students", as: :unregistered_students, via: [ :get ,:post ]
    match "/add-more-months-fee-gp/:id" => "home#group_class_view_add_more_months", :as => :group_class_view_add_more_months, via: [:get, :post]
    match "/:group_class/mark-present/:student/:attendance_date" => "home#mark_present", :as => :mark_present, via: [:get]
    match "/:group_class/mark-absent/:student/:attendance_date" => "home#mark_absent", :as => :mark_absent, via: [:get]
    match "/:group_class/remove-attendance/:student/:attendance_date" => "home#remove_attendance", :as => :remove_attendance, via: [:get]

    # match "/lightning-risk" => "home#whether_information", :as => :whether_information, via: [:get]
    match '/countries'=> "instructor_students#countries", :as=> :countries, via: [:get]
    match '/instructor_student/:id/change_class_details' => "instructor_students#change_class_details", :as => :change_class_details, via: [:post]
    match '/instructor_student/:id/change_student_name' => "instructor_students#change_student_name", :as => :change_student_name, via: [:post]
    match '/instructor_student/:id/change_student_details' => "instructor_students#change_student_details", :as => :change_student_details, via: [:post]
    match '/instructor_student/:id/change_contact_details' => "instructor_students#change_contact_details", :as => :change_contact_details, via: [:put, :patch]
    match '/instructor_student/:id/change_award_details' => "instructor_students#change_award_details", :as => :change_award_details, via: [:put, :patch]
    match 'instructor_students/:id/awards-certificates'=> "instructor_students#edit_awards_certificates", :as=> :edit_awards_certificates, via: [:get]
    match '/sort_student/:id' => "home#sort_student", :as => :sort_student, via: [ :get ]
    match '/remove/group/:id' => "home#remove_group_from_group_class", :as => :remove_group_from_group_class, via: [ :delete ]
    match "/set_attended/:id" => "home#set_attended", :as => :set_attended, via: [ :get ]

    match "/student_profile/:id" => "instructor_students#profile_upload", via: [:post]
    match "/student_identity/:id" => 'student_identities#identity_upload', via: [:post]
   
    match "/group_message" => "instructor_messages#group_message", :as => :group_message, via: [:post]
    match "/group_award_message" => "instructor_messages#group_award_message", :as => :group_award_message, via: [:post]

    match "/send_msg_preview" => "instructor_messages#send_msg_preview", :as => :send_msg_preview, via: [:post]

    match "/print-student-list" => "instructor_students#print_student_list", :as => :print_student, via: [:get]

    match "/disconnect-account" => "instructor_profile#disconnect_telerivet_account", :as => :disconnect_telerivet_account, via: [:get]
    match "/instructor-features" => "instructor_profile#instructor_features", :as => :instructor_features, via: [:post]
    
    match "/set-columns" => "hide_show_columns#update_columns", :as => :update_columns, via: [ :post ]

    resources :instructor_student_timings
    match "/instructor_student/student_timing/:id" => "instructor_students#student_timing", :as => :student_timing, via: [ :get ]
    match "/instructor_student/cancle_student_award/:id" => "instructor_students#cancle_student_award", :as => :cancle_student_award, via: [ :get ]
  end

  namespace :accountant do
    resources :home
    root 'home#index'
    match "/payments" => "home#payments", as: :payments, via: [:get,:post]
    match "/reports" => "home#reports", as: :reports, via: [:get,:post]
    match "/coordinator" =>"transaction#coordinator", as: :coordinator, via: [:get,:post]
    match "/instructor_fee" =>"transaction#instructor_fee", as: :instructor_fee, via: [:get,:post]
    match "/instructor_test" =>"transaction#instructor_test", as: :instructor_test, via: [:get,:post]
  end


  namespace :api do
    get 'student_public_link/:secret_token' =>'lightning_informations#student_public_link_api', defaults: { format: :json }
    # # For messages api call
    # match "v1/messages/" => "v1/messages#index", as: :messages, via: :get
    # match "v1/messages/view/:phone_number" => "v1/messages#view_conversation", as: :view_conversation, via: :get
    # match "v1/send-message" => "v1/messages#create", as: :send_message, via: :post
    # match "v1/reply-message" => "v1/messages#reply", as: :reply, via: :post
    # match "v1/load-more-message/:page" => "v1/messages#load_more_message", as: :api_load_more_message, via: :get
    # match "v1/unread-notification" => "v1/messages#count_unread_notification", as: :count_unread_notification, via: :get
    # match "v1/mark-conversation-as-unread" => "v1/messages#mark_conversation_as_unread", as: :mark_conversation_as_unread, via: :get

    # match "v1/logout" => "v1/logout#logout", as: :logout, via: :get

    # Device registration api call
    match "v1/register_mobile_device" => "v1/mobile_devices#create", as: :register_mobile_device, via: :get
    match "v1/register-user-by-device" => "v1/mobile_devices#register_user_by_device_registration_id", as: :register_user_by_device_registration, via: :get
    devise_for :admin_users, :controllers => { :sessions => "api/v1/sessions"}
    devise_scope :admin_user do
      # post 'v1/create_auth' => 'v1/sessions#create_auth'
      get 'v1/create_auth' => 'v1/sessions#create_auth', defaults: { format: :json }
    end

    namespace :v1 do
      resources :venus, only: [:index,:show]
      resources :age_groups, only: [:index]
      resources :instructors, only: [:index,:show,:update]
      resources :fee_types, only: [:index]
      resources :coordinator_classes
      resources :messages
      resources :jobs
      resources :instructor_job_applications
      resources :instructor_identities
      resources :identity_cards ,only: [:show]
      
      get 'set_unread/:id' => 'messages#set_unread', defaults: {format: :json}
      get 'load_more_message/:id' => 'messages#load_more_message', defaults: {format: :json}
      get 'incoming_messages/:id' => 'messages#incoming_messages', defaults: {format: :json}
      get 'outgoing_messages/:id' => 'messages#outgoing_messages', defaults: {format: :json}
      get 'checkStatus/:id' => 'messages#checkStatus', defaults: {format: :json}

      get 'coordinator_classes_filter' => 'coordinator_classes#filter', defaults: { format: :json }
      get 'instructor_classes_filter/:id' => 'coordinator_classes#instructor_filter', defaults: { format: :json }
      get 'venue_count/:id' => 'venus#venue_count', defaults: { format: :json }
      post 'job_status' => 'jobs#change_job_status'
      get 'job_receipt/:id' => 'jobs#job_receipt', defaults: { format: :json }
    end
  end

  
  namespace :api do
    get 'lightning_information' => 'lightning_informations#lightning_information'
  end
  resources :embed_registration_forms, :except => [ :new ]
  

  get "/student/:instructor_student_award_id/cancel" => "welcome#cancel",  as: :student_cancel_booking
  get '*unmatched_route', :to => 'application#render_404'

    
end