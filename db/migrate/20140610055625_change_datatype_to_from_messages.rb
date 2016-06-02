class ChangeDatatypeToFromMessages < ActiveRecord::Migration
  def change
    change_column :messages, :to, :string, limit: 15
  end
end
