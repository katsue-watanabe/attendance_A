class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :employee_number
      t.integer :uid
      t.datetime :designated_work_start_time
      t.datetime :designated_work_end_time
      
      t.timestamps
    end
  end
end
