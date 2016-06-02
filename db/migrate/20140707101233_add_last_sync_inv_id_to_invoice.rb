class AddLastSyncInvIdToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :last_sync_inv_id, :string
  end
end
