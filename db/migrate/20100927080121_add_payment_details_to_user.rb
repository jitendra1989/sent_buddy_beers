class AddPaymentDetailsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :paypal_email, :string
    add_column :users, :bank_account_name, :string
    add_column :users, :bank_account_number, :string
    add_column :users, :bank_account_bank_code, :string #BLZ
    add_column :users, :bank_name, :string
    add_column :users, :bank_address, :text
    add_column :users, :bank_account_iban, :string
    add_column :users, :bank_account_bic_swift, :string #BIC/SWIFT Code:
  end

  def self.down
    remove_column :users, :paypal_email
    remove_column :users, :bank_account_name
    remove_column :users, :bank_account_number
    remove_column :users, :bank_account_bank_code
    remove_column :users, :bank_name
    remove_column :users, :bank_address
    remove_column :users, :bank_account_iban
    remove_column :users, :bank_account_bic_swift
  end
end
