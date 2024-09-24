class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :code
      t.string :name
      t.string :dollar_off
      t.decimal :percent_off
      t.string :status
      t.references :merchant, null: false

      t.timestamps
    end
  end
end
