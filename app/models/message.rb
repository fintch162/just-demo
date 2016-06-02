class Message < ActiveRecord::Base
  extend Filterable
  self.per_page = 20
  belongs_to :coordinator
  validates :unique_message_id, uniqueness: true
  def per_page
    20
  end
  def self.last_page_number(conditions=nil)
    total = count :all, :conditions => conditions
    [((total - 1) / per_page) + 1, 1].max
  end

  # def self.import_f(file)
  #   filename = file.path
  #   options = {:key_mapping => {:unwanted_row => nil, :old_row_name => :new_name}}
    
  #   Message.benchmark('create 100 message with activerecord-import gem') do
  #     columns = [ :time_created, :from_number, :to_number, :contact_name, :message_description, :message_type, :direction, :status, :starred, :labels, :contact_id, :unique_message_id ]
  #     values = []
  #     CSV.foreach(file.path, headers: true) do |row|
  #       values << [DateTime.parse(row['created_at']).change(:offset => "+0800"), row['from_number'], row['to_number'], row['contact_name'], row['message_description'], row['message_type'], row['direction'], row['status'], row['starred'], row['labels'], row['contact_id'], row['unique_message_id'] ]
  #     end
  #     Message.import(columns, values, validate: true)
  #   end
  # end
end
