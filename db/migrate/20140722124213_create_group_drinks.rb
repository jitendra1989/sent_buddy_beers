class CreateGroupDrinks < ActiveRecord::Migration
  def self.up
    create_table :group_drinks do |t|
      t.integer :recipient_id
      t.string :recipient_name
      t.string :recipient_email
      t.string :recipient_phone
      t.integer :quantity
      t.integer :price_id
      t.string :special_message
      t.integer :iou_id
      t.integer :beverage_id

      t.timestamps
    end
  end

  def self.down
    drop_table :group_drinks
  end
end
